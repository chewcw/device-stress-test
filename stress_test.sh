#!/usr/bin/env bash

REPORT_FILE="/tmp/device_stress_report.txt"
TMP_LOG="/tmp/stress_tmp.log"
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")
DEVICE_NAME=$(hostname)

echo "Running stress-ng tests on: $DEVICE_NAME" | tee $REPORT_FILE
echo "Date: $DATE_NOW" | tee -a $REPORT_FILE
echo "----------------------------------------" | tee -a $REPORT_FILE

if ! command -v stress-ng >/dev/null; then
    echo "Error: stress-ng is not installed. Please install it with: sudo apt install stress-ng" | tee -a $REPORT_FILE
    exit 1
fi

run_test() {
    local title=$1
    shift
    echo "" | tee -a $REPORT_FILE
    echo "$title" | tee -a $REPORT_FILE
    stress-ng "$@" --metrics-brief > "$TMP_LOG" 2>&1

    grep -E -A2 'stressor|bogo ops' "$TMP_LOG" | tee -a $REPORT_FILE
}

CORES=$(nproc) # Number of CPU cores
VM_WORKERS=$((CORES / 2))

echo "" | tee -a $REPORT_FILE
echo "- Memory usage idle: " | tee -a $REPORT_FILE
free -h | tee -a $REPORT_FILE

run_test "- CPU Stress Test (${CORES} cores, 60s)" --cpu "$CORES" --timeout 60s
run_test "- Memory Stress Test (${VM_WORKERS} workers, 60s, 75% RAM)" --vm "$VM_WORKERS" --vm-bytes 75% --timeout 60s
run_test "- Disk I/O Test (512MB write, 60s)" --hdd 1 --hdd-bytes 512M --timeout 60s
run_test "- Combined Stress (CPU+VM+Disk, 2 mins)" --cpu 2 --vm 2 --hdd 1 --timeout 120s

echo "" | tee -a $REPORT_FILE
echo "- CPU Temperature:" | tee -a $REPORT_FILE
if command -v sensors >/dev/null; then
    sensors | tee -a $REPORT_FILE
else
    echo "  'sensors' command not found. Install with: sudo apt install lm-sensors" | tee -a $REPORT_FILE
fi

echo "" | tee -a $REPORT_FILE
echo "Test complete. Report saved at: $REPORT_FILE"

