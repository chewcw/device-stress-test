#!/usr/bin/env bash

# Run this script on laptop connected to the device via Ethernet.
DEVICE_IP=""
PING_REPORT_FILE="/tmp/device_ping_report.txt"

if [ -z "$DEVICE_IP" ]; then
    echo "Please set the DEVICE_IP variable to the IP address of the device."
    exit 1
fi

echo "Waiting for device at $DEVICE_IP to shutdown..."
while ping -c1 $DEVICE_IP &>/dev/null; do
    sleep 1
done

echo "Device is down. Waiting for it to come back online..."
START=$(date "+%Y-%m-%d %H:%M:%S")

while ! ping -c1 $DEVICE_IP &>/dev/null; do
    sleep 1
done

END=$(date "+%Y-%m-%d %H:%M:%S")
BOOT_TIME=$((END - START))
echo "Device is back online. Boot time: $BOOT_TIME seconds" | tee -a $PING_REPORT_FILE
