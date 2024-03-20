#!/bin/bash
#
# Common functions that can be sourced in test scripts.
#

set -eu -o pipefail

trap "log_error Test failure!" ERR

log_message() {
  echo -e "\033[0;33m[TEST] $*\033[0m" >&2
}

log_error() {
  echo -e "\033[0;31m[ERROR] $*\033[0m" >&2
}

await_confirm() {
  echo -n "$1 (y/n)? "
  local answer
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo
  else
    log_error
    exit 1
  fi
}

fail_test() {
  log_error "${1:-}"
  if [ -n "${2:-}" ]; then
    echo "$2" >&2
  fi
  exit 1
}

init_platform() {
  # Start required services
  docker-compose up -d frontend ldap1
  # Start configuration store
  start_ds
  # Start AM servers
  for instance_id in {1..1}; do
    start_am $instance_id
    exec_am $instance_id java -jar /opt/ssoconf/openam-configurator-tool.jar --file /srv/wrenam/config.properties
    wait_am $instance_id
    docker-compose exec -w /opt/ssoadm "wrenam"$instance_id /opt/ssoadm/setup --path /srv/wrenam --acceptLicense
    docker-compose exec -w /opt/ssoadm "wrenam"$instance_id bash -c \
      "[ -f auth/pwd.txt ] || (umask 0377 && echo -n password > auth/pwd.txt)"
  done
}

shutdown_platform() {
  docker-compose down -v
}

start_am() {
  local instance_id=${1:-1}
  local expect_alive=${2:-0}
  docker-compose up -d "wrenam"$instance_id
  wait_am $instance_id $expect_alive
  log_message "Wren:AM test instance $instance_id started..."
}

wait_am() {
  local instance_id=${1:-1}
  local expect_alive=${2:-1}
  while true; do
    check_am $instance_id $expect_alive && break
    log_message "Waiting for the configuration to finish..."
    sleep 1
  done
}

stop_am() {
  local instance_id=${1:-1}
  log_message "Stopping Wren:AM test instance $instance_id..."
  docker-compose rm -fs "wrenam"$instance_id
  log_message "Wren:AM test instance $instance_id succesfuly stopped..."
}

exec_am() {
  local instance_id=$1
  docker-compose exec "wrenam"$instance_id "${@:2}"
}

exec_ssoadm() {
  local instance_id=$1
  docker-compose exec -w /opt/ssoadm/auth "wrenam"$instance_id ./bin/ssoadm "${@:2}"
}

check_am() {
  local instance_id=${1:-1}
  local expect_alive=${2:-1}
  local status
  status=$(exec_am $instance_id curl -s http://localhost:8080/auth/isAlive.jsp)
  [ $? -eq 0 ] || return 1
  [ $expect_alive -ne 1 ] || $(echo "$status" | grep "Server is ALIVE:" > /dev/null)
}

start_ds() {
  local instance_id=${1:-1}
  log_message "Starting Wren:DS test instance $instance_id..."
  docker-compose up -d "wrends"$instance_id
  while true; do
    check_ds $instance_id && break
    log_message "Waiting for the container to startup..."
    sleep 2
  done
  log_message "Wren:DS instance $instance_id started."
}

exec_ds() {
  local instance_id=$1
  docker exec -i "wrenam-wrends"$instance_id "${@:2}"
}

check_ds() {
  local instance_id=${1:-1}
  # Call standard status command
  local status=$(exec_ds $instance_id status -ns || :)
  $(echo $status | grep "Server Run Status: Started" > /dev/null) || return 1
  # Perform user backend search (it starts a bit later than the container)
  exec_ds $instance_id ldapsearch --port 1389 \
      --bindDN "cn=Directory Manager" --bindPassword password \
      --baseDN "ou=wrenam,dc=wrensecurity,dc=org" --searchScope one "(objectclass=*)" "dn" > /dev/null 2>&1
}

exec_ldap() {
  docker exec -i wrenam-ldap1 "$@" < /dev/stdin
}
