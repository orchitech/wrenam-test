#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

login_wren_am amadmin password

log_message "Evaluating policy..."

TOKEN_ID=$(sso_token)

curl \
 --request POST \
 --header "Content-Type: application/json" \
 --header "iPlanetDirectoryPro: $TOKEN_ID" \
 --data '{
    "subject": {
      "ssoToken": "'${TOKEN_ID}'" },
    "resources": [
        "http://www.example.com:80/"
    ],
    "application": "iPlanetAMWebAgentService"
 }' \
 http://localhost:8080/auth/json/policies?_action=evaluate

log_message "Policy evaluated!"

logout_wren_am

log_message "User logged out!"