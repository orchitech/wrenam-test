#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

# Wren:AM instance ID
TEST_INSTANCE_ID=1

# Number of modules in authentication chain
AUTH_CHAIN_MODULES=1

read_audit_file() {
  exec_am $TEST_INSTANCE_ID bash -c "cat /srv/wrenam/auth/log/authentication.csv"
}

get_audit_file_len() {
  read_audit_file | wc -l | tr -d '\r'
}

assert_audit_file_increment() {
  local latest_file_len="$1"
  local expected_increment="$2"

  local expected_len="$(($latest_file_len + $expected_increment))"
  local actual_len=$(get_audit_file_len)
  [ $expected_len == $actual_len ] || \
    fail_test "Audit file has $actual_len lines instead of expected $expected_len.\nActual content (last 5 lines):\n$(read_audit_file | tail -n 5)"
}

assert_audit_file_content() {
  local offset=$1
  local expected_pattern="$2"
  local actual=$(read_audit_file | tail -n $offset)
  $(echo "$actual" | grep -e "$expected_pattern" > /dev/null) || \
    fail_test "Audit file's content does not match '$expected_pattern'.\nActual content (last 5 lines):\n$(actual)"
}

set_lb_cookie() {
  local amlbcookie=$([ $TEST_INSTANCE_ID == 2 ] && echo "03" || echo "0$TEST_INSTANCE_ID")
  echo ".wrensecurity.local	TRUE	/	FALSE	0	amlbcookie	$amlbcookie" | set_cookies
}
