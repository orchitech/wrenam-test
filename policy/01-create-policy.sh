#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Authenticate as admin
TEST_USER_USERNAME=amadmin
TEST_USER_PASSWORD=password

TOKEN=$(authenticate "/")

# Create policy set
TEST_POLICY_SET_DATA='{
  "name": "'$TEST_POLICY_SET_ID'",
  "displayName": "'$TEST_POLICY_SET_ID'",
  "resourceTypeUuids": [
    "UrlResourceType"
  ],
  "realm": "'$TEST_REALM'",
  "applicationType": "iPlanetAMWebAgentService",
  "conditions": [
    "AMIdentityMembership",
    "AND",
    "AuthLevel",
    "AuthenticateToRealm"
  ],
  "subjects": [
    "AND",
    "AuthenticatedUsers",
    "Identity",
    "NONE"
  ],
  "entitlementCombiner": "DenyOverride"
}'
post_request "applications" "create" <<< "$TEST_POLICY_SET_DATA" \
  | assert_response_status 201 \
  > /dev/null

# Create policy 1
TEST_POLICY_1_DATA='{
  "name": "Test policy",
  "active": true,
  "description": "Test policy description",
  "applicationName": "'$TEST_POLICY_SET_ID'",
  "resourceTypeUuid": "UrlResourceType",
  "actionValues": {
    "POST": true,
    "GET": false
  },
  "resources": [
    "'$TEST_POLICY_1_RESOURCE'"
  ],
  "subject": {
    "type": "AuthenticatedUsers"
  },
  "condition": {
    "type": "AuthenticateToRealm",
    "authenticateToRealm": "'$TEST_REALM'"
  },
  "resourceAttributes": [
    {
      "type": "User",
      "propertyName": "dn",
      "propertyValues": []
    },
    {
      "type": "Static",
      "propertyName": "foo",
      "propertyValues": ["bar"]
    }
  ]
}'
post_request "policies" "create" <<< "$TEST_POLICY_1_DATA" \
  | assert_response_status 201 \
  > /dev/null

# Create policy 2
TEST_POLICY_2_DATA='{
  "name": "Test policy 2",
  "active": true,
  "description": "Test policy 2 description",
  "applicationName": "'$TEST_POLICY_SET_ID'",
  "resourceTypeUuid": "UrlResourceType",
  "actionValues": {
    "HEAD": false
  },
  "resources": [
    "'$TEST_POLICY_2_RESOURCE'"
  ],
  "subject": {
    "type": "AuthenticatedUsers"
  },
  "condition": {
    "type": "AuthenticateToRealm",
    "authenticateToRealm": "/different-realm"
  },
  "resourceAttributes": [
    {
      "type": "User",
      "propertyName": "cn",
      "propertyValues": []
    }
  ]
}'
post_request "policies" "create" <<< "$TEST_POLICY_2_DATA" \
  | assert_response_status 201 \
  > /dev/null
