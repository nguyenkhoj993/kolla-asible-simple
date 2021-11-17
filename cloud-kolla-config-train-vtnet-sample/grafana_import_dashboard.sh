#!/bin/bash
#
# Script import all dashboard in DASHBOARD_FOLDER to grafana
# author: donghm
#

DASH_DIR="${1:-grafana_dashboard}"
#DASH_DIR="${1:-grafana_dashboard}"
HOST="${2:-http://10.255.77.1:55550}"
#KEY="${3:-eyJrIjoiVEN4SEc5cERiT2RTSllibEJRVHJkTWsyTnM4TTZjTUwiLCJuIjoiZWRpdG9yIiwiaWQiOjF9}" # editor
KEY="${3:-eyJrIjoiUThZOWZ5ZHZ0SlNocmd6aVg0OUc0eDJqbDFYVUxRbFEiLCJuIjoiYWRtaW4iLCJpZCI6MX0=}"  # admin
#KEY="${3:-eyJrIjoiOElLTjF0SlBVM3V3aU1zZktpNUZoNFVOTWJEb2gwMDgiLCJuIjoiZGFzaGJvYXJkIiwiaWQiOjF9}" # viewer

PARENT_DIR='dashboards'

if [ ! -d "${PARENT_DIR}" ]; then
  echo "Not found any folder dashboard!"
  exit
fi

if [ ! -d "${PARENT_DIR}/${DASH_DIR}" ]; then
  echo "Not found any dashboard!"
  exit
fi

if [[ $# -eq 0 ]]; then
    ARGS=(${PARENT_DIR}/${DASH_DIR}/*/*.json)
else
    ARGS=("$@")
fi

curl_wrap() {
    FILE=$1
    KEY=$2
    URL=$3
    echo $URL
    HTTP_VERB=POST
    curl --fail -k -X$HTTP_VERB -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $KEY" --data-binary $FILE $URL
}

import_file() {
    FILE="$1"
    KEY="$2"
    TYPE="$3"

    if ! [ -f "$FILE" ]; then
        echo "$FILE not found." >>/dev/stderr
        return
    fi

    echo "Processing $FILE file..."
    curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE"
    CURL_EXIT=$?
    echo

    if [[ ${CURL_EXIT} = 22 && $TYPE = "datasources" ]]; then
        echo "409 conflict error is normal. Retrying as update."
        id=$(basename $file .json)
        curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE/$id" PUT
    elif [[ ${CURL_EXIT} = 22 && $TYPE = "alert-notifications" ]]; then
        echo "500 server error is normal. Retrying as update."
        id=$(basename $file .json)
        curl_wrap "$FILE" "$KEY" "${HOST}/api/$TYPE/$id" PUT
    fi
}

for FILE in "${ARGS[@]}"; do
  import_file "$FILE" "$KEY" 'dashboards/db'
done
