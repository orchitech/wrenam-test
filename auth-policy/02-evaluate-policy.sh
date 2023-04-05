#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

login_wren_am amadmin password

log_message "Evaluating policy..."

curl \
 --request POST \
 --header "Content-Type: application/json" \
 --header "iPlanetDirectoryPro: AQIC5wM2LY4SfcySvYraAXlWUZAO2U7173pjYz4eRJxTVto.*AAJTSQACMDEAAlNLABQtMTAzODQxODU0MzczNDg4MTI5MgACUzEAAA..*" \
 --data '{
    "subject": {
      "ssoToken": "AQIC5wM2LY4SfcySvYraAXlWUZAO2U7173pjYz4eRJxTVto.*AAJTSQACMDEAAlNLABQtMTAzODQxODU0MzczNDg4MTI5MgACUzEAAA..*" },
    "resources": [
        "http://www.example.com:80/"
    ],
    "application": "iPlanetAMWebAgentService"
 }' \
 http://localhost:8080/auth/json/policies?_action=evaluate

log_message "Policy evaluated!"

log_message "User logged out!"

curl \
 --request POST \
 --header "iplanetDirectoryPro: AQIC5wM2LY4SfcySvYraAXlWUZAO2U7173pjYz4eRJxTVto.*AAJTSQACMDEAAlNLABQtMTAzODQxODU0MzczNDg4MTI5MgACUzEAAA..*" \
 http://localhost:8080/auth/json/sessions/?_action=logout