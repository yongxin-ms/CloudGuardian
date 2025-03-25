#!/bin/bash

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "$(date +%Y%m%d-%H:%M:%M) jq could not be found. Please install jq to run this script."
    exit
fi

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "$(date +%Y%m%d-%H:%M:%M) .env not found. Please create a .env file."
    exit
fi

NET_OUT=$(cat /sys/class/net/$NIC/statistics/tx_bytes)

# Check if data.json exists
if [ ! -f data.json ]; then
    echo "$(date +%Y%m%d-%H:%M:%M) data.json not found. Creating a new one."
    echo '{"last_update": '$(date +%s)', "current": '$NET_OUT', "addup": "0"}' >data.json
fi

# load all data from data.json
LAST_UPDATE=$(jq -r '.last_update' data.json)
TIME_NOW=$(date +%s)
CURRENT=$(jq -r '.current' data.json)
ADD_UP=$(jq -r '.addup' data.json)

# if last_update and time_now in different month, reset add_up
# if [ $(date --date="@$LAST_UPDATE" +%Y%m%d%H%M) -ne $(date +%Y%m%d%H%M) ]; then
if [ $(date --date="@$LAST_UPDATE" +%Y%m%d) -ne $(date +%Y%m%d) ]; then
    echo "$(date +%Y%m%d-%H:%M:%M) New day, reset addup and start the service."
    ADD_UP=0
    LAST_UPDATE=$TIME_NOW

    # invoke start_service.sh
    ./start_service.sh
fi

if [ $NET_OUT -gt $CURRENT ]; then
    echo "$(date +%Y%m%d-%H:%M:%M) Addup updated: $((NET_OUT - CURRENT)) bytes."
    ADD_UP=$((ADD_UP + (NET_OUT - CURRENT)))
    CURRENT=$NET_OUT
else
    echo "$(date +%Y%m%d-%H:%M:%M) Reset Current, NIC restarted?"
    CURRENT=$NET_OUT
fi

if [ $ADD_UP -gt $TX_BYTES_LIMIT ]; then
    # invoke stop_service.sh
    ./stop_service.sh
fi

jq --arg last_update "$LAST_UPDATE" --arg current "$CURRENT" --arg addup "$ADD_UP" \
    '.last_update = $last_update | .current = $current | .addup = $addup' data.json >tmp.json && mv tmp.json data.json
