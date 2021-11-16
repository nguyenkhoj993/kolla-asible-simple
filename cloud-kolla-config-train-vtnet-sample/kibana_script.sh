#!/bin/bash

# Script get all kibana dashboards
# author: duclh3
PARENT_DIR='dashboards'
DASH_DIR="${1:-kibana_dashboard}"
KIBANA_HOST="${2:-http://10.255.77.1:8601}"
ELASTICSEARCH_HOST="${3:-http://10.255.77.1:9200}"
KEY="${4:-gDnZNIRMQWyqvuYsZO8PA0LHKM3zQOx6x99slKt5}"

if [ ! -d "${PARENT_DIR}" ]; then
	mkdir "${PARENT_DIR}"
fi

if [ ! -d "${DASH_DIR}" ]; then
	mkdir "${PARENT_DIR}/${DASH_DIR}"
fi

for dash in $(curl ''$ELASTICSEARCH_HOST'/.kibana/_search?q=type:dashboard&size=1000' | jq '.hits.hits[] | ._id'); do
	dashboard_id=$(echo $dash | awk 'BEGIN {FS=":"}{print $2}' | awk 'BEGIN {FS="\""}{print $1}')
	echo $dashboard_id
	dashboard_json=$(curl --user kibana:$KEY -XGET $KIBANA_HOST/api/kibana/dashboards/export\?dashboard\=$dashboard_id)
	dashboard_title=$(echo $dashboard_json | jq '.objects[-1].attributes.title' | sed -r 's/["\/]+//g')
	curl --user kibana:$KEY -XGET $KIBANA_HOST/api/kibana/dashboards/export\?dashboard\=$dashboard_id > "${PARENT_DIR}/$DASH_DIR/$dashboard_title.json"
done
