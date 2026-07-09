#!/bin/bash
set -euo pipefail

log() { echo "$(date +%Y%m%d-%H:%M:%S) $*"; }
die() {
	log "$*" >&2
	exit 1
}

if [[ $EUID -ne 0 ]]; then
	die "This script must be run as root" >&2
fi

# Check dependencies
command -v jq &>/dev/null || die "jq could not be found. Please install jq to run this script."

# Load environment
[[ -f .env ]] || die ".env not found. Please create a .env file."
set -a
source .env
set +a

# Validate required vars
: "${NIC:?NIC is not set in .env}"
: "${TX_BYTES_LIMIT:?TX_BYTES_LIMIT is not set in .env}"

NET_OUT=$(<"/sys/class/net/${NIC}/statistics/tx_bytes")

# Initialize data.json if missing
if [[ ! -f data.json ]]; then
	log "data.json not found. Creating a new one."
	jq -n --argjson now "$(date +%s)" --argjson current "$NET_OUT" \
		'{last_update: $now, current: $current, addup: 0}' >data.json
fi

# Load state
LAST_UPDATE=$(jq '.last_update' data.json)
TIME_NOW=$(date +%s)
CURRENT=$(jq '.current' data.json)
ADD_UP=$(jq '.addup' data.json)

# New day: reset addup and restart services
if [[ $(date -d "@$LAST_UPDATE" +%Y%m%d) != $(date +%Y%m%d) ]]; then
	log "New day, resetting addup and starting services."
	ADD_UP=0
	LAST_UPDATE=$TIME_NOW
	./services.sh start
fi

# Update traffic delta
if ((NET_OUT > CURRENT)); then
	delta=$((NET_OUT - CURRENT))
	ADD_UP=$((ADD_UP + delta))
	log "Addup updated: +${delta} bytes (total: ${ADD_UP})."
else
	log "NET_OUT <= CURRENT, NIC may have restarted. Resetting current."
fi
CURRENT=$NET_OUT

# Stop services if limit exceeded
if ((ADD_UP > TX_BYTES_LIMIT)); then
	log "Traffic limit exceeded (${ADD_UP} > ${TX_BYTES_LIMIT}). Stopping services."
	./services.sh stop
fi

# Persist state
jq --argjson last_update "$LAST_UPDATE" \
	--argjson current "$CURRENT" \
	--argjson addup "$ADD_UP" \
	'.last_update = $last_update | .current = $current | .addup = $addup' \
	data.json >tmp.json && mv tmp.json data.json
