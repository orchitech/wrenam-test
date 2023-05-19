#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

INSTANCE_ID=1

AUTH_AUDIT_FILE="/srv/wrenam/auth/log/authentication.csv"

read_audit_file() {
  exec_am $INSTANCE_ID bash -c "cat $AUTH_AUDIT_FILE"
}

empty_audit_file() {
  exec_am $INSTANCE_ID bash -c "echo "$AUTH_AUDIT_FILE_HEADER" > $AUTH_AUDIT_FILE"
  check_audit_file_len 1
}

get_audit_file_len() {
  read_audit_file | wc -l | tr -d '\r'
}

check_audit_file_len() {
  local expected="$1"
  local actual=$(get_audit_file_len)
  [ $expected == $actual ] || fail_test "Audit file has $actual lines instead of expected $expected.\nActual content: $(read_audit_file)"
}

# Check that audit file contains expected content
check_audit_file_content() {
  local expected="$1"
  local actual=$(read_audit_file)
  $(echo "$actual" | grep -e $expected > /dev/null) || fail_test "Audit file's content does not match '$expected'.\nActual content: $actual"
}

configure_global_csv_handler() {
  local buffering_enabled="$1"
  local buffering_auto_flush="$2"

  exec_ssoadm $INSTANCE_ID \
    set-sub-cfg \
      --adminid amadmin \
      --password-file pwd.txt \
      --servicename AuditService \
      --subconfigname "Global CSV Handler" \
      --operation set \
      --attributevalues "bufferingEnabled=$buffering_enabled"
  exec_ssoadm $INSTANCE_ID \
    set-sub-cfg \
      --adminid amadmin \
      --password-file pwd.txt \
      --servicename AuditService \
      --subconfigname "Global CSV Handler" \
      --operation set \
      --attributevalues "bufferingAutoFlush=$buffering_auto_flush"
}

restore_global_csv_handler_configuration() {
  log_message "Restoring Global CSV Handler configuration..."
  configure_global_csv_handler true false
}

AUTH_AUDIT_FILE_HEADER="$(read_audit_file | head -n 1)"
AUTH_CHAIN_MODULES=1
