#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/.common.sh"

HEADER_OPTS=(-H 'Accept: application/json' -H 'Content-Type: application/json' -H 'Accept-API-Version: protocol=1.0,resource=2.0')
ANONYMOUS_OPTS=(-H 'X-Password: anonymous' -H 'X-Username: anonymous')
CURL_OPTS=("${HEADER_OPTS[@]}" "${ANONYMOUS_OPTS[@]}")

basic_authentication() {
  local INSTANCE_ID="$1"
  local REALM="${4:-}"

  local AM_BASE_URL="http://wrenam$INSTANCE_ID.wrensecurity.local:8080/auth"
  local AM_USERNAME="$2"
  local AM_PASSWORD="$3"
  local AM_EXTRA_QUERY="realm=%2F$REALM"

  local COOKIE_FILE="./cookies"
  local COOKIE_STRING=""

  #
  # STEP 0: Start authentication process as enduser
  #   + get authentication challenge
  #   + get server instance LB cookie
  #
  log_message "Starting basic authentication process..."

  AUTH_0_URL="$AM_BASE_URL/json/authenticate?$AM_EXTRA_QUERY"
  AUTH_0_RES=$(curl -sfk "${CURL_OPTS[@]}" -c "$COOKIE_FILE" "$AUTH_0_URL" -X POST)

  LB_COOKIE=$(grep amlbcookie "$COOKIE_FILE" | sed -r 's/.*amlbcookie\t([0-9]*$)/\1/')

  COOKIE_STRING="amlbcookie=$LB_COOKIE"

  log_message "Authenticating with username and password..."

  #
  # STEP 1: Submit username and password as enduser
  #   + get SSO session identifier
  #
  AUTH_1_URL="$AM_BASE_URL/json/authenticate?$AM_EXTRA_QUERY"
  AUTH_1_REQ=$(echo "$AUTH_0_RES" |
      jq ".callbacks[0].input[0].value = \"$AM_USERNAME\"" |
      jq ".callbacks[1].input[0].value = \"$AM_PASSWORD\"")
  # Send the request and store response body and HTTP status code on separate lines (<response>\n<http status code>)
  AUTH_1_RES=$(curl -sk "${CURL_OPTS[@]}" -o - -w "\n%{http_code}" -b "$COOKIE_STRING" "$AUTH_1_URL" -X POST -d "$AUTH_1_REQ")

  # Output final response details
  echo "$AUTH_1_RES"
}

parse_response_body() {
  local response=$1
  echo "$response" | tail -n 2 | head -n 1
}

parse_response_status() {
  local response=$1
  echo "$response" | tail -n 1
}

check_response_status() {
  local expected=$1
  local response=$2
  AUTH_STATUS=$(parse_response_status "$response")
  [ "$AUTH_STATUS" == "$expected" ] || fail_test "Authentication ended with HTTP status code $AUTH_STATUS instead of expected $expected."
}
