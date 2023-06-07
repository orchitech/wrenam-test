#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

clear_cookies

AUTH_RESPONSE=$(
  authentication_request "realm=$TEST_REALM" < /dev/null \
  | assert_response_status \
  | assert_response_body '.stage == "LDAP1"'
)

AUTH_REQUEST=$(
  get_response_body "$AUTH_RESPONSE" \
  | jq ".callbacks[0].input[0].value = \"$TEST_USER_USERNAME\"" \
  | jq ".callbacks[1].input[0].value = \"$TEST_USER_PASSWORD\""
)

authentication_request "realm=$TEST_REALM" <<< "$AUTH_REQUEST" \
  | assert_response_status \
  | assert_response_body '.tokenId != null' \
  | assert_response_body ".realm == \"$TEST_REALM\"" \
  > /dev/null
