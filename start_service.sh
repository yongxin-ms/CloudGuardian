#!/bin/bash

# Check if v2ray is running
if ! systemctl is-active --quiet v2ray; then
	echo "$(date +%Y%m%d-%H:%M:%M) Starting v2ray..."
	systemctl start v2ray
	echo "$(date +%Y%m%d-%H:%M:%M) v2ray started."
fi

# Check if nginx is running
if ! systemctl is-active --quiet nginx; then
	echo "$(date +%Y%m%d-%H:%M:%M) Starting nginx..."
	systemctl start nginx
	echo "$(date +%Y%m%d-%H:%M:%M) nginx started."
fi

# Check if x-ui is running
if ! systemctl is-active --quiet x-ui; then
	echo "$(date +%Y%m%d-%H:%M:%M) Starting x-ui..."
	systemctl start x-ui
	echo "$(date +%Y%m%d-%H:%M:%M) x-ui started."
fi

# Check if sing-box is running
if ! systemctl is-active --quiet sing-box; then
	echo "$(date +%Y%m%d-%H:%M:%M) Starting sing-box..."
	systemctl start sing-box
	echo "$(date +%Y%m%d-%H:%M:%M) sing-box started."
fi
