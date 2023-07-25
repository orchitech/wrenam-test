#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

TEST_USER_USERNAME="John Doe"
TEST_USER_PASSWORD="password"
AM_HOST_MAPPING="wrenam.wrensecurity.local:80:10.0.0.11:80"
AM_BASE_URL="http://wrenam.wrensecurity.local/auth"

clear_cookies

#
# Step 1: Authenticate as test user and obtain session token
#
AUTH_RESPONSE=$(
  authentication_request "realm=${TEST_REALM:-}" < /dev/null \
  | assert_response_status \
  | assert_response_body '.stage == "DataStore1"'
)

AUTH_REQUEST=$(
  get_response_body "$AUTH_RESPONSE" \
  | jq ".callbacks[0].input[0].value = \"$TEST_USER_USERNAME\"" \
  | jq ".callbacks[1].input[0].value = \"$TEST_USER_PASSWORD\""
)
TOKEN_ID=$(
  authentication_request "realm=${TEST_REALM:-}" <<< "$AUTH_REQUEST" \
  | assert_response_status \
  | assert_response_body '.tokenId != null' \
  | assert_response_body ".realm == \"${TEST_REALM:-}\"" \
  | get_response_body - \
  | jq -r ".tokenId"
)

#
# STEP 2: Request OAuth authorization as enduser
#   + get authorization code parameter from redirect
#
AUTH_2_PARAMS=(
  "response_type=code"
  "client_id=$OAUTH_AGENT_ID"
  "redirect_uri=$OAUTH_AGENT_REDIRECT_URI"
  "scope=openid%20profile"
  "state=login"
)
AUTH_2_QUERY=$(IFS="&"; printf '%s' "${AUTH_2_PARAMS[*]}")
AUTH_2_RESPONSE=$(
  curl -sI \
    -X GET \
    -b "iPlanetDirectoryPro=$TOKEN_ID" \
    --connect-to "$AM_HOST_MAPPING" \
    "$AM_BASE_URL/oauth2$TEST_REALM/authorize?$AUTH_2_QUERY"
)

AUTHORIZATION_CODE=$(
  echo "$AUTH_2_RESPONSE" \
  | (grep "^location: .*code=[^&]*.*" || fail_test "Failed to parse authorization code from the response." "$AUTH_2_RESPONSE") \
  | sed -r 's/.*\?code=([^&]*).*/\1/'
)

#
# STEP 3: Request OAuth tokens with authorization code as OIDC client
#
AUTH_3_PARAMS=(
  "grant_type=authorization_code"
  "code=$AUTHORIZATION_CODE"
  "redirect_uri=$OAUTH_AGENT_REDIRECT_URI"
)
AUTH_3_BODY=$(IFS="&"; printf '%s' "${AUTH_3_PARAMS[*]}")
ACCESS_TOKEN=$(
  curl -si \
    -X POST \
    -u "$OAUTH_AGENT_ID":"$OAUTH_AGENT_SECRET" \
    -d "$AUTH_3_BODY" \
    --connect-to "$AM_HOST_MAPPING" \
    "$AM_BASE_URL/oauth2$TEST_REALM/access_token" \
  | assert_response_body ".access_token != null" \
  | assert_response_body ".refresh_token != null" \
  | assert_response_body ".id_token != null" \
  | get_response_body - \
  | jq -r ".access_token"
)

#
# STEP 4: Request access token information (introspect) as OIDC client
#
curl -si \
  -X GET \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  --connect-to "$AM_HOST_MAPPING" \
  "$AM_BASE_URL/oauth2/tokeninfo" \
| assert_response_body ".expires_in != null" \
| assert_response_body ".realm == \"$TEST_REALM\"" \
> /dev/null
