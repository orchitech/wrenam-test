#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Authenticate as admin
TEST_USER_USERNAME=amadmin
TEST_USER_PASSWORD=password

TOKEN=$(authenticate "/")

# Authenticate as subject
TEST_USER_USERNAME="John Doe"
TEST_USER_PASSWORD=password
TEST_USER_DN="uid=john,ou=users,dc=example,dc=org"

SUBJECT_TOKEN=$(authenticate "$TEST_REALM")

# Evaluate policies
DATA='{
  "subject": {
    "ssoToken": "'$SUBJECT_TOKEN'"
  },
  "resources": [
    "'$TEST_POLICY_1_RESOURCE'",
    "'$TEST_POLICY_2_RESOURCE'"
  ],
  "application": "'$TEST_POLICY_SET_ID'"
}'
post_request "policies" "evaluate" <<< "$DATA" \
  | assert_response_status \
  | assert_response_body 'length == 2' \
  | assert_response_body '.[] | select(.resource == "'$TEST_POLICY_1_RESOURCE'") |
    .actions.POST == true and .actions.GET == false
    and .attributes.foo == ["bar"] and .attributes.dn == ["'$TEST_USER_DN'"]
    and .advices == {}
    and .ttl != null' \
  | assert_response_body '.[] | select(.resource == "'$TEST_POLICY_2_RESOURCE'") |
    .actions == {}
    and .attributes == {}
    and .advices.AuthenticateToRealmConditionAdvice != null
    and .ttl != null' \
  > /dev/null
