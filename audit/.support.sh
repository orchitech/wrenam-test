#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

instance_id="$1"

AUTH_AUDIT_FILE="/srv/wrenam/auth/log/authentication.csv"

read_audit_file() {
  # Sometimes duplicate entries are logged or they are logged out of order, sort them by timestamp and filter out duplicates
  exec_am $instance_id bash -c "cat $AUTH_AUDIT_FILE" | sort -t "," -k 2,2 | uniq
}

empty_audit_file() {
  exec_am $instance_id bash -c "echo "$AUTH_AUDIT_FILE_HEADER" > $AUTH_AUDIT_FILE"
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

  # Disable log buffering and enable auto flush so log file is updated immediately
  exec_ssoadm $instance_id \
    set-sub-cfg \
      --adminid amadmin \
      --password-file pwd.txt \
      --servicename AuditService \
      --subconfigname "Global CSV Handler" \
      --operation set \
      --attributevalues "bufferingEnabled=$buffering_enabled"
  exec_ssoadm $instance_id \
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
