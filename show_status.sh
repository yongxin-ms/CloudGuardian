#!/bin/bash

# Check if v2ray is running
if ! systemctl is-active --quiet v2ray; then
    echo "$(date +%Y%m%d-%H:%M:%M) v2ray is running."
else
    echo "$(date +%Y%m%d-%H:%M:%M) v2ray is not running."
fi

# Check if nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "$(date +%Y%m%d-%H:%M:%M) nginx is running."
else
    echo "$(date +%Y%m%d-%H:%M:%M) nginx is not running."
fi

# Check if x-ui is running
if ! systemctl is-active --quiet x-ui; then
    echo "$(date +%Y%m%d-%H:%M:%M) x-ui is running."
else
    echo "$(date +%Y%m%d-%H:%M:%M) x-ui is not running."
fi