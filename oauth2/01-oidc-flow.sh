#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.authentication.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

HEADER_OPTS=(-H 'Accept: application/json' -H 'Content-Type: application/json' -H 'Accept-API-Version: protocol=1.0,resource=2.0')
ANONYMOUS_OPTS=(-H 'X-Password: anonymous' -H 'X-Username: anonymous')
CURL_OPTS=("${HEADER_OPTS[@]}" "${ANONYMOUS_OPTS[@]}")

#
# Step 1: Basic authentication
#
AUTH_1_RES=$(basic_authentication $INSTANCE_ID "$AM_USERNAME" "$AM_PASSWORD" "$REALM")
AUTH_1_RES_BODY="$(echo -e "$AUTH_1_RES" | tail -n 2 | head -n 1)"

TOKEN_ID=$(echo $AUTH_1_RES_BODY | jq -r ".tokenId")
[ $TOKEN_ID != "null" ] || fail_test "Token ID is missing from the response!"

COOKIE_STRING="iPlanetDirectoryPro=$TOKEN_ID"

#
# STEP 2: Request OAuth authorization as enduser
#   + get authorization code parameter from redirect
#
log_message "Requesting OAuth authorization..."
AUTH_2_PARAMS=(
  "response_type=code"
  "client_id=$OAUTH_AGENT_ID"
  "redirect_uri=$OAUTH_AGENT_REDIRECT_URI"
  "scope=openid%20profile"
  "state=login"
)
AUTH_2_QUERY=$(IFS="&"; printf '%s' "${AUTH_2_PARAMS[*]}")
AUTH_2_URL="$AM_BASE_URL/oauth2/$REALM/authorize?$AUTH_2_QUERY"
AUTH_2_RES=$(curl -sfkI -X GET "${CURL_OPTS[@]}" -b "$COOKIE_STRING" "$AUTH_2_URL" )

AUTHORIZATION_CODE=$(echo "$AUTH_2_RES" | grep '^Location: ' | sed -r 's/.*\?code=([^&]*).*/\1/')
$(echo "$AUTHORIZATION_CODE" | grep "^Location: " > /dev/null) && \
  fail_test "Failed to parse authorization code from the response. Response:\n$AUTH_2_RES"

#
# STEP 3: Request OAuth tokens with authorization code as OIDC client
#
log_message "Requesting OAuth tokens..."
AUTH_3_PARAMS=(
  "grant_type=authorization_code"
  "code=$AUTHORIZATION_CODE"
  "redirect_uri=$OAUTH_AGENT_REDIRECT_URI"
)
AUTH_3_URL="$AM_BASE_URL/oauth2/$REALM/access_token"
AUTH_3_BODY=$(IFS="&"; printf '%s' "${AUTH_3_PARAMS[*]}")
AUTH_3_RES=$(curl -sfk -XPOST -u "$OAUTH_AGENT_ID":"$OAUTH_AGENT_SECRET" "$AUTH_3_URL" -d "$AUTH_3_BODY")

ACCESS_TOKEN=$(echo "$AUTH_3_RES" | jq -r ".access_token")
REFRESH_TOKEN=$(echo "$AUTH_3_RES" | jq -r ".refresh_token")
ID_TOKEN=$(echo "$AUTH_3_RES" | jq -r ".id_token")
[ $ACCESS_TOKEN != "null" ] || fail_test "Access token is missing from the response!"
[ $REFRESH_TOKEN != "null" ] || fail_test "Refresh token is missing from the response!"
[ $ID_TOKEN != "null" ] || fail_test "ID token is missing from the response!"

#
# STEP 4: Request access token information (introspect) as OIDC client
#
log_message "Requesting OAuth access token information..."
AUTH_4_URL="$AM_BASE_URL/oauth2/tokeninfo"
AUTH_4_RES=$(curl -sfk -H "Authorization: Bearer $ACCESS_TOKEN" -H "Accept: application/json" "$AUTH_4_URL")

TOKEN_EXPIRATION=$(echo "$AUTH_4_RES" | jq -r ".expires_in")
[ $TOKEN_EXPIRATION != "null" ] || fail_test "Expiration details are missing from the response!"

log_message "Test case successful."
