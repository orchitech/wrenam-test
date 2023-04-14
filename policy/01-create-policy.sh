#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

login_wren_am amadmin password

log_message "Creating policy..."

curl \
  --request POST \
  --header "Content-Type: application/json" \
  --header "iPlanetDirectoryPro: $(sso_token)" \
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

logout_wren_am

log_message "User logged out!"