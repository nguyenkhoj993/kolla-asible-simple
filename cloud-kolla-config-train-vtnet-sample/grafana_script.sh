#!/bin/bash
#
# Script get all gafana dashboards
# author: duclh3
#

DASH_DIR="${1:-grafana_dashboard}"
HOST="${2:-http://10.255.77.1:8550}"
#KEY="${3:-eyJrIjoia1hHV1FlWUZNeGhqOWpndXdic3lDMzk2ZGg4d1MyU3QiLCJuIjoiZHVjbGgzIiwiaWQiOjF9}"
KEY="${3:-eyJrIjoiZndLeFlUQUlMSTJHd1RRZkc0aWZpZlM1aG0xaG5FYmQiLCJuIjoiZ3JhZmFuYS1iYWNrdXAiLCJpZCI6MX0}"
PARENT_DIR='dashboards'

if [ ! -d "${PARENT_DIR}" ]; then
	mkdir -p "${PARENT_DIR}"
fi

if [ ! -d "${DASH_DIR}" ]; then
  mkdir -p "${PARENT_DIR}/${DASH_DIR}"
fi

for dashboard_uid in $(curl -sS -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& |tr ']{' '\n'| cut -d ':' -f3| cut -d ',' -f1| cut -d '"' -f2 | grep -Ev "(^$|\[)"); do 

   counter=$((counter + 1))
   dashboard_json="$(curl -sS -H "Authorization: Bearer $KEY" $HOST/api/dashboards/uid/$dashboard_uid | python -m json.tool)"
   dashboard_title="$(echo $dashboard_json | jq -r '.dashboard | .title')"
   folder_title="$(echo $dashboard_json | jq -r '.meta | .folderTitle')"

   mkdir -p "${PARENT_DIR}/$DASH_DIR/$folder_title"
   curl -sS -H "Authorization: Bearer $KEY" $HOST/api/dashboards/uid/$dashboard_uid | python -m json.tool > "${PARENT_DIR}/$DASH_DIR/$folder_title/${dashboard_title}.json"

done
