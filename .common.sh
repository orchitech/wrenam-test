#!/bin/bash

set -eu -o pipefail

trap "log_error Test failure!" ERR

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

check_am() {
  local status=$(docker exec -it "wrenam-test" opends/bin/status -ns || :)
  return $(echo $status | grep "Server Run Status: Started" > /dev/null)
}

fail_test() {
  log_error "$@"
  exit 1
}