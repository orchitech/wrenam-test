#!/bin/bash

set -eu -o pipefail

trap "log_error Test failure!" ERR

function log_message {
  echo -e "\033[0;33m[TEST] $*\033[0m" >&2
}

function log_error {
  echo -e "\033[0;31m[ERROR] $*\033[0m" >&2
}

function start_am() {
  log_message "Starting Wren:AM test instance..."
  docker run \
  -d --rm --name wrenam-latest \
  -p 8080:8080 -h localhost \
  ${WRENDS_IMAGE:-wrenam}
  log_message "Wren:AM test instance started..."
}

function stop_am() {
  # !!! TODO: Use dedicated Wren:AM tool to stop the server instance !!!
  log_message "Stopping Wren:AM test instance..."
  docker exec -it wrenam-latest /usr/local/tomcat/bin/catalina.sh stop
  docker stop wrenam-latest
  log_message "Wren:AM test instance succesfuly stopped..."
}

function wait_for_start {
  # !!! TODO: Check for am status !!!
  log_message "Waiting for Wren:AM test instance to start..."
  sleep 10
}

function configure_server {
  log_message "Setting up Wren:AM test instance..."
  docker cp ./ssoconf/config.properties wrenam-latest:/opt/ssoconf
  docker exec -it -w /opt/ssoconf wrenam-latest java -jar openam-configurator-tool-15.0.0-SNAPSHOT.jar --file config.properties
  log_message "Configuration completed..."
}

function configure_ssoadm {
  log_message "Setting up SSOADM tools..."
  docker exec -it -w /opt/ssoadm wrenam-latest ./setup --path /srv/wrenam --debug /opt/ssoadm/debug --log /opt/ssoadm/log --acceptLicense
  log_message "Setup completed..."
}