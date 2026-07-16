#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" >&2
	exit 1
fi

action=${1:?Usage: $0 start|stop|status}
[[ "$action" == "start" || "$action" == "stop" || "$action" == "status" ]] || {
	echo "Invalid action: $action" >&2
	exit 1
}

log() { echo "$(date +%Y%m%d-%H:%M:%S) $*"; }
err() { log "$*" >&2; }
active() { systemctl is-active --quiet "$1"; }

services=(v2ray nginx x-ui sing-box)

for svc in "${services[@]}"; do
	if ! systemctl cat "$svc" &>/dev/null; then
		[[ "$action" == "status" ]] && log "$svc: not installed."
		continue
	fi

	case "$action" in
	start)
		active "$svc" && continue
		log "Starting $svc..."
		if systemctl start "$svc"; then
			log "$svc started."
		else
			err "ERROR: Failed to start $svc."
		fi
		;;
	stop)
		active "$svc" || continue
		log "Stopping $svc..."
		if systemctl stop "$svc"; then
			log "$svc stopped."
		else
			err "ERROR: Failed to stop $svc."
		fi
		;;
	status)
		if active "$svc"; then
			log "$svc: running."
		else
			log "$svc: not running."
		fi
		;;
	esac
done
