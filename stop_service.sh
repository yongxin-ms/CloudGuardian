#!/bin/bash

# Check if v2ray is running
if systemctl is-active --quiet v2ray; then
    echo "$(date +%Y%m%d-%H:%M:%M) Stopping v2ray..."
    systemctl stop v2ray
    echo "$(date +%Y%m%d-%H:%M:%M) v2ray stopped."
fi

# Check if nginx is running
if systemctl is-active --quiet nginx; then
    echo "$(date +%Y%m%d-%H:%M:%M) Stopping nginx..."
    systemctl stop nginx
    echo "$(date +%Y%m%d-%H:%M:%M) nginx stopped."
fi
