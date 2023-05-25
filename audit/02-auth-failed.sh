#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "$SCRIPT_DIR/.support.sh"

TEST_USER_USERNAME=amadmin
TEST_USER_PASSWORD=wrong_password

clear_cookies
set_lb_cookie

# Store audit file initial length before authenticating
AUDIT_FILE_LATEST_LEN="$(get_audit_file_len)"

AUTH_RESPONSE=$(
  authentication_request < /dev/null \
  | assert_response_status \
  | assert_response_body '.stage == "DataStore1"'
)

AUTH_REQUEST=$(
  get_response_body "$AUTH_RESPONSE" \
  | jq ".callbacks[0].input[0].value = \"$TEST_USER_USERNAME\"" \
  | jq ".callbacks[1].input[0].value = \"$TEST_USER_PASSWORD\""
)

authentication_request <<< "$AUTH_REQUEST" \
  | assert_response_status 401 \
  > /dev/null

# Assert audit file changes
EXPECTED_INCREMENT=$(($AUTH_CHAIN_MODULES + 1)) # 1 entry for each chain module + 1 entry for login completed
assert_audit_file_increment $AUDIT_FILE_LATEST_LEN $EXPECTED_INCREMENT
assert_audit_file_content $EXPECTED_INCREMENT "AM-LOGIN-MODULE-COMPLETED.*FAILED"
assert_audit_file_content $EXPECTED_INCREMENT "AM-LOGIN-COMPLETED.*FAILED"
