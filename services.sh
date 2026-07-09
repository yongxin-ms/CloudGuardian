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
		systemctl start "$svc" &&
			log "$svc started." ||
			err "ERROR: Failed to start $svc."
		;;
	stop)
		active "$svc" || continue
		log "Stopping $svc..."
		systemctl stop "$svc" &&
			log "$svc stopped." ||
			err "ERROR: Failed to stop $svc."
		;;
	status)
		active "$svc" &&
			log "$svc: running." ||
			log "$svc: not running."
		;;
	esac
done
