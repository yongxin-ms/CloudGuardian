#!/bin/bash

action=${1:?Usage: $0 start|stop|status}
[[ "$action" == "start" || "$action" == "stop" || "$action" == "status" ]] || {
	echo "Invalid action: $action"
	exit 1
}

timestamp() {
	date +%Y%m%d-%H:%M:%S
}

services=(v2ray nginx x-ui sing-box)

for svc in "${services[@]}"; do
	active=$(systemctl is-active --quiet "$svc" && echo yes || echo no)
	if [[ "$action" == "stop" && "$active" == "yes" ]]; then
		echo "$(timestamp) Stopping $svc..."
		systemctl stop "$svc"
		echo "$(timestamp) $svc stopped."
	elif [[ "$action" == "start" && "$active" == "no" ]]; then
		echo "$(timestamp) Starting $svc..."
		systemctl start "$svc"
		echo "$(timestamp) $svc started."
	elif [[ "$action" == "status" ]]; then
		if [[ "$active" == "yes" ]]; then
			echo "$(timestamp) $svc is running."
		else
			echo "$(timestamp) $svc is not running."
		fi
	fi
done
