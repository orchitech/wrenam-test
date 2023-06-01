#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Set test user's "pwdReset" attribute to force password change on next authentication
exec_ldap bash -c "ldapmodify -D $ADMIN_DN -w $ADMIN_PASSWORD <<< '
dn: '$TEST_USER_DN'
changetype: modify
replace: pwdReset
pwdReset: TRUE
'" > /dev/null

clear_cookies

# Authenticate with current password
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

# Change password
AUTH_RESPONSE=$(
	authentication_request "realm=$TEST_REALM" <<< "$AUTH_REQUEST" \
	| assert_response_status \
	| assert_response_body '.stage == "LDAP2"'
)

TEST_USER_NEW_PASSWORD="password$(date +%s)"

AUTH_REQUEST=$(
	get_response_body "$AUTH_RESPONSE" \
	| jq ".callbacks[0].input[0].value = \"$TEST_USER_PASSWORD\"" \
	| jq ".callbacks[1].input[0].value = \"$TEST_USER_NEW_PASSWORD\"" \
	| jq ".callbacks[2].input[0].value = \"$TEST_USER_NEW_PASSWORD\""
)

authentication_request "realm=$TEST_REALM" <<< "$AUTH_REQUEST" \
	| assert_response_status \
	| assert_response_body '.tokenId != null' \
	| assert_response_body ".realm == \"$TEST_REALM\"" \
	> /dev/null

# Authenticate with new password
AUTH_RESPONSE=$(
	authentication_request "realm=$TEST_REALM" < /dev/null \
	| assert_response_status \
	| assert_response_body '.stage == "LDAP1"'
)

AUTH_REQUEST=$(
	get_response_body "$AUTH_RESPONSE" \
	| jq ".callbacks[0].input[0].value = \"$TEST_USER_USERNAME\"" \
	| jq ".callbacks[1].input[0].value = \"$TEST_USER_NEW_PASSWORD\""
)

authentication_request "realm=$TEST_REALM" <<< "$AUTH_REQUEST" \
	| assert_response_status \
	| assert_response_body '.tokenId != null' \
	| assert_response_body ".realm == \"$TEST_REALM\"" \
	> /dev/null
