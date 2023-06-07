#!/bin/bash

TEST_INSTANCE_ID=1
TEST_REALM="/policy-test"
TEST_POLICY_SET_ID="PolicyTestApplication"
TEST_POLICY_1_RESOURCE="http://policy-test:8080/*?_action=create"
TEST_POLICY_2_RESOURCE="http://policy-test:8080/*?_action=edit"

authenticate() {
  local realm=${1:-}

  clear_cookies

  AUTH_RESPONSE=$(
    authentication_request "realm=$realm" < /dev/null \
    | assert_response_status \
    | assert_response_body '.stage == "DataStore1"'
  )
  AUTH_REQUEST=$(
    get_response_body "$AUTH_RESPONSE" \
    | jq ".callbacks[0].input[0].value = \"$TEST_USER_USERNAME\"" \
    | jq ".callbacks[1].input[0].value = \"$TEST_USER_PASSWORD\""
  )
  authentication_request "realm=$realm" <<< "$AUTH_REQUEST" \
    | assert_response_status \
    | assert_response_body '.tokenId != null' \
    | assert_response_body ".realm == \"$realm\"" \
    | get_response_body - \
    | jq -r ".tokenId"
}

post_request() {
  local resource=$1
  local action=$2
  cat | curl -si \
    -X POST \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'Accept-API-Version: protocol=1.0,resource=2.0' \
    -H "iPlanetDirectoryPro: $TOKEN" \
    -d @- \
    --connect-to wrenam.wrensecurity.local:443:10.0.0.11:443 \
    "http://wrenam.wrensecurity.local/auth/json${TEST_REALM:+$TEST_REALM}/$resource?_action=$action"
}
