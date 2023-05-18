#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/.common.sh"

instance_id="$1"

# Basic test parameters
AM_BASE_URL="http://wrenam$instance_id.wrensecurity.local:8080/auth"
AM_USERNAME="$2"
AM_PASSWORD="$3"

# Remaining script parameters
HEADER_OPTS=(-H 'Accept: application/json' -H 'Content-Type: application/json' -H 'Accept-API-Version: protocol=1.0,resource=2.0')
ANONYMOUS_OPTS=(-H 'X-Password: anonymous' -H 'X-Username: anonymous')
CURL_OPTS=("${HEADER_OPTS[@]}" "${ANONYMOUS_OPTS[@]}")

COOKIE_FILE="./cookies"
COOKIE_STRING=""

#
# STEP 0: Start authentication process as enduser
#   + get authentication challenge
#   + get server instance LB cookie
#
log_message "Starting authentication process..."

AUTH_0_URL="$AM_BASE_URL/json/authenticate"
AUTH_0_RES=$(curl -sfk "${CURL_OPTS[@]}" -c "$COOKIE_FILE" "$AUTH_0_URL" -X POST)

LB_COOKIE=$(grep amlbcookie "$COOKIE_FILE" | sed -r 's/.*amlbcookie\t([0-9]*$)/\1/')

COOKIE_STRING="amlbcookie=$LB_COOKIE"

log_message "Authenticating with username and password..."

#
# STEP 1: Submit username and password as enduser
#   + get SSO session identifier
#
AUTH_1_URL="$AM_BASE_URL/json/authenticate"
AUTH_1_REQ=$(echo "$AUTH_0_RES" |
    jq ".callbacks[0].input[0].value = \"$AM_USERNAME\"" |
    jq ".callbacks[1].input[0].value = \"$AM_PASSWORD\"")
AUTH_1_STATUS=$(curl -sk "${CURL_OPTS[@]}" -o /dev/null -w "%{http_code}" -b "$COOKIE_STRING" "$AUTH_1_URL" -X POST -d "$AUTH_1_REQ")

# Return HTTP status code
echo $AUTH_1_STATUS
