#!/bin/bash

set -eu -o pipefail

trap "log_error Test failure!" ERR

TOKEN=""

log_message() {
  echo -e "\033[0;33m[TEST] $*\033[0m" >&2
}

log_error() {
  echo -e "\033[0;31m[ERROR] $*\033[0m" >&2
}

start_am() {
  log_message "Starting Wren:AM test instance..."
  docker run \
    -d --rm --name wrenam-test \
    -p 8080:8080 -h localhost \
    ${WRENDS_IMAGE:-wrenam}
  log_message "Wren:AM test instance started..."
}

stop_am() {
  # !!! TODO: Use dedicated Wren:AM tool to stop the server instance !!!
  log_message "Stopping Wren:AM test instance..."
  docker exec -it wrenam-test /usr/local/tomcat/bin/catalina.sh stop
  docker stop wrenam-test
  log_message "Wren:AM test instance succesfuly stopped..."
}

wait_for_start() {
  # !!! TODO: Check for am status !!!
  log_message "Waiting for Wren:AM test instance to start..."
  sleep 10
}

configure_server() {
  log_message "Setting up Wren:AM test instance..."
  docker cp ./ssoconf/data/config.properties wrenam-test:/opt/ssoconf
  docker exec -it -w /opt/ssoconf wrenam-test java -jar openam-configurator-tool-15.0.0-SNAPSHOT.jar --file config.properties
  log_message "Configuration completed..."
}

configure_ssoadm() {
  log_message "Setting up SSOADM tools..."
  docker exec -it -w /opt/ssoadm wrenam-test ./setup --path /srv/wrenam --debug /opt/ssoadm/debug --log /opt/ssoadm/log --acceptLicense
  log_message "Setup completed..."
}

check_ds() {
  local status=$(docker exec -it "wrenam-test" opends/bin/status -ns || :)
  return $(echo $status | grep "Server Run Status: Started" > /dev/null)
}

exec_am() {
  docker exec -w /opt/ssoadm/auth/bin/ "wrenam-test" "${}"
}

fail_test() {
  log_error "$@"
  exit 1
}

run_openldap() {
  docker compose up -d
}

# Log in to WrenAM XUI with username and password
login_wren_am() {
  local AM_USERNAME=$1
  local AM_PASSWORD=$2
  local AM_URL="http://localhost:8080/auth"

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

  COOKIE_FILE="./cookies.txt"

  log_message "Starting authentication..."

  AUTH_URL="${AM_URL}/json/realms/root/authenticate"
  AUTH_RES=$(curl -sfk "${CURL_OPTS[@]}" -c ${COOKIE_FILE} "$AUTH_URL" -X POST)

  LB_COOKIE=$(grep amlbcookie "$COOKIE_FILE" | sed -r 's/.*amlbcookie\t([0-9]*$)/\1/')
  log_message "Authentication session ID assigned on server $LB_COOKIE"

  COOKIE_STRING="amlbcookie=$LB_COOKIE"

  # Send form with username and password credentials

  AUTH_1_URL="${AM_URL}/json/realms/root/authenticate"

  AUTH_1_REQ=$(echo "$AUTH_RES" |
      jq ".callbacks[0].input[0].value = \"$AM_USERNAME\"" |
      jq ".callbacks[1].input[0].value = \"$AM_PASSWORD\"")

  if AUTH_1_RES=$(curl -sfk "${CURL_OPTS[@]}" -b "$COOKIE_STRING" "$AUTH_1_URL" -X POST -d "$AUTH_1_REQ")
  then
    TOKEN_ID=$(echo $AUTH_1_RES | jq -r ".tokenId")
    log_message "SSO session ID: $TOKEN_ID"
    log_message "Authentication for ${AM_USERNAME} completed!"
    echo $TOKEN_ID >> sso_token.txt
  else
    log_error "Authentication failed due to invalid password credentials!"
    $(rm -rf cookies.txt)
  fi
}

# Get sso token from logged user

sso_token() {
  TOKEN_ID=$(cat sso_token.txt)
  echo $TOKEN_ID
}

# Log out from WrenAM XUI

logout_wren_am() {
  TOKEN_ID=$(cat sso_token.txt)

  curl \
    --request POST \
    --header "iplanetDirectoryPro: $TOKEN_ID" \
  http://localhost:8080/auth/json/sessions/?_action=logout

  $(rm -rf sso_token.txt && rm -rf cookies.txt)
}