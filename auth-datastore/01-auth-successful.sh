#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

TEST_USER_USERNAME=amadmin
TEST_USER_PASSWORD=password

clear_cookies

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
  | assert_response_status \
  | assert_response_body '.tokenId != null' \
  | assert_response_body '.realm == "/"' \
  > /dev/null
