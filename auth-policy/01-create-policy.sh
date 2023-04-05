#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

login_wren_am amadmin password

log_message "Creating policy..."

curl \
  --request POST \
  --header "Content-Type: application/json" \
  --header "iPlanetDirectoryPro: AQIC5wM2LY4SfcwE_DCGero850NVhiWq4cS2mQA6jXOXGts.*AAJTSQACMDEAAlNLABQtMzAzMTE5NzMzNjM5OTc0MzEzNwACUzEAAA.." \
  --data '{
      "name": "mypolicy",
      "active": true,
      "description": "My Policy.",
      "applicationName": "iPlanetAMWebAgentService",
      "actionValues": {
          "POST": true,
          "GET": true
      },
      "resources": [
          "http://www.example.com:80/",
          "http://www.example.com:80/"
      ],
      "subject": {
          "type": "Identity",
          "subjectValues": [
              "uid=demo,ou=People,dc=example,dc=com"
          ]
      },
      "resourceTypeUuid": "76656a38-5f8e-401b-83aa-4ccb74ce88d2"
  }' \
http://localhost:8080/auth/json/policies?_action=create

log_message "Policy created!"

curl \
 --request POST \
 --header "iplanetDirectoryPro: AQIC5wM2LY4SfcySvYraAXlWUZAO2U7173pjYz4eRJxTVto.*AAJTSQACMDEAAlNLABQtMTAzODQxODU0MzczNDg4MTI5MgACUzEAAA..*" \
 http://localhost:8080/auth/json/sessions/?_action=logout
