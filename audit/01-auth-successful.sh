#!/bin/bash

instance_id=1

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh" $instance_id

handle_error() {
  log_error "Test failed"
  restore_global_csv_handler_configuration
}

trap "handle_error" ERR

# Successful login
log_message "Running successful login test case..."

empty_audit_file

AUTH_STATUS=$(source "$(dirname "${BASH_SOURCE[0]}")/../.authenticate.sh" $instance_id amadmin password)
[ "$AUTH_STATUS" == "200" ] || fail_test "Authentication ended with HTTP status code $AUTH_STATUS instead of expected 200."

check_audit_file_len $(($AUTH_CHAIN_MODULES + 2)) # 1 entry for each chain module + 1 entry for login completed + 1 for header
check_audit_file_content "AM-LOGIN-MODULE-COMPLETED.*SUCCESSFUL"
check_audit_file_content "AM-LOGIN-COMPLETED.*SUCCESSFUL"

log_message "Test case successful."
