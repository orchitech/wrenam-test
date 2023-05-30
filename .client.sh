#!/bin/bash

#
# Remove all session cookies by deleting the cookie file.
#
# Supported environment variables:
#
#   AUTH_SESSION_NAME - name of the session cookie file (defaults to 'default')
#
clear_cookies() {
  local cookie_file="./.cookies/${AUTH_SESSION_NAME:-default}"
  [ -f "$cookie_file" ] && rm "$cookie_file" || :
}

#
# Read cookie fields from stdin and write them to cookie file.
#
# Supported environment variables:
#
#   AUTH_SESSION_NAME - name of the session cookie file (defaults to 'default')
#
set_cookies() {
  local cookie_file="./.cookies/${AUTH_SESSION_NAME:-default}"
  cat > $cookie_file
}

#
# Perform authentication request against /json/authenticate endpoint.
# Reads request body from stdin, prints response headers and body to stdout.
#
# Usage: authentication_request <extra_query>
#
# Supported environment variables:
#
#   AUTH_SESSION_NAME - name of the session cookie file (defaults to 'default')
#
authentication_request() {
  local extra_query="${1:-}"

  local cookie_file=./.cookies/${AUTH_SESSION_NAME:-default}
  mkdir -p "$(dirname "$cookie_file")"

  # Add `--trace-ascii %` option to print out HTTP traffic
  cat | curl -si \
      -X POST \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -H 'Accept-API-Version: protocol=1.0,resource=2.0' \
      -c "$cookie_file" \
      -b "$cookie_file" \
      -d @- \
      --connect-to wrenam.wrensecurity.local:443:10.0.0.11:443 \
      "http://wrenam.wrensecurity.local/auth/json/authenticate?$extra_query"
}

#
# Get response body from request passed through stdin or as a function argument.
#
get_response_body() {
  local input=${1:-}
  if [ "$input" == "-" ]; then
    input=$(cat)
  fi
  echo -n "$input" | sed -r '0,/^[\r\n]+/d'
}

#
# Get response status code from request passed through stdin or as a function argument.
#
get_response_status() {
  local input=${1:-}
  if [ "$input" == "-" ]; then
    read -r input
  fi
  echo -n "$input" | head -n 1 | cut -d' ' -f2
}

#
# Assert response status code value.
#
assert_response_status() {
  local expected_status=${1:-200}

  local response=$(cat)
  local response_status=$(get_response_status "$response")

  [ "$response_status" -eq "$expected_status" ] || fail_test "Invalid response code" "$response"
  echo -n "$response"
}

#
# Assert JSON response body content.
#
# Usage: assert_response_body <jq_expression>
#
assert_response_body() {
  local expression="$1"

  local response=$(cat)
  local response_body=$(get_response_body "$response")

  [ -n "$response_body" ] || fail_test "Unable to test empty response with: $expression"

  echo -n "$response_body" | jq -e "$expression" > /dev/null \
    || fail_test "Failed matching response with: $expression" "$response_body"

  echo -n "$response"
}
