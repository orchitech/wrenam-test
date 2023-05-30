#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

TEST_USER_USERNAME=amadmin
TEST_USER_PASSWORD=password

clear_cookies

# Authenticate against AM test instance 1
echo ".wrensecurity.local	TRUE	/	FALSE	0	amlbcookie	$TEST_INSTANCE_AMLBCOOKIE" | set_cookies

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

TOKEN=$(
  authentication_request <<< "$AUTH_REQUEST" \
  | assert_response_status \
  | assert_response_body '.tokenId != null' \
  | assert_response_body '.realm == "/"' \
  | get_response_body - \
  | jq -r ".tokenId"
)

# Stop AM test instance 1
docker stop wrenam-test1 > /dev/null

# Preserve AM test instance 1 amlbcookie, include obtained token
curl -si \
  -X POST \
  -H 'Accept: application/json' \
  -H 'Accept-API-Version: protocol=1.0,resource=2.0' \
  -b "amlbcookie=$TEST_INSTANCE_AMLBCOOKIE;iPlanetDirectoryPro=$TOKEN" \
  --connect-to wrenam.wrensecurity.local:443:10.0.0.11:443 \
  "http://wrenam.wrensecurity.local/auth/json/users?_action=idFromSession" \
| assert_response_status > /dev/null
