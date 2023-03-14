#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

AM_USERNAME="amadmin"
AM_PASSWORD="password"
AM_URL="http://localhost:8080/auth"

HEADER_OPTS=(
  -H "Accept: application/json"
  -H "Content-Type: application/json"
  -H "Accept-API-Version: protocol=2.0,resource=2.0"
)
ANONYMOUS_OPTS=(
  -H "X-Password: anonymous"
  -H "X-Username: anonymous"
)
CURL_OPTS=("${HEADER_OPTS[@]}" "${ANONYMOUS_OPTS[@]}")

COOKIE_FILE="./cookies"

log_message "Starting authentication..."

# Starting authentication as amadmin

AUTH_URL="${AM_URL}/json/realms/root/authenticate"
AUTH_RES=$(curl -sfk "${CURL_OPTS[@]}" -c ${COOKIE_FILE} "$AUTH_URL" -X POST)

LB_COOKIE=$(grep amlbcookie "$COOKIE_FILE" | sed -r 's/.*amlbcookie\t([0-9]*$)/\1/')
log_message "Authentication session ID assigned on server $LB_COOKIE"

COOKIE_STRING="amlbcookie=$LB_COOKIE"

# Send form with username and password with amadmin user

AUTH_1_URL="${AM_URL}/json/realms/root/authenticate"

AUTH_1_REQ=$(echo "$AUTH_RES" |
    jq ".callbacks[0].input[0].value = \"$AM_USERNAME\"" |
    jq ".callbacks[1].input[0].value = \"$AM_PASSWORD\"")

AUTH_1_RES=$(curl -sfk "${CURL_OPTS[@]}" -b "$COOKIE_STRING" "$AUTH_1_URL" -X POST -d "$AUTH_1_REQ")

TOKEN_ID=$(echo $AUTH_1_RES | jq -r ".tokenId")
log_message "SSO session ID: $TOKEN_ID"

log_message "Authentication for ${AM_USERNAME} completed!"