#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "$SCRIPT_DIR/../.common.sh"
. "$SCRIPT_DIR/../.authentication.sh"
. "$SCRIPT_DIR/.support.sh"

handle_error() {
  restore_global_csv_handler_configuration
}

trap "handle_error" ERR

empty_audit_file

AUTH_RES=$(basic_authentication $INSTANCE_ID amadmin wrong_password)
check_response_status 401 "$AUTH_RES"

check_audit_file_len $(($AUTH_CHAIN_MODULES + 2)) # 1 entry for each chain module + 1 entry for login completed + 1 for header
check_audit_file_content "AM-LOGIN-MODULE-COMPLETED.*FAILED"
check_audit_file_content "AM-LOGIN-COMPLETED.*FAILED"

log_message "Test case successful."
