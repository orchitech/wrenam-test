#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "$SCRIPT_DIR/../.common.sh"
. "$SCRIPT_DIR/.support.sh"

# Setup configuration

# Delete the realm if it already exists
exec_ssoadm $TEST_INSTANCE_ID delete-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" > /dev/null || :

# Create new realm
exec_ssoadm $TEST_INSTANCE_ID create-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" \
  > /dev/null

# Create OAuth2 Provider Service
#
# Special settings different from defaults:
#   * Allow clients to skip consent: enabled
#   * Issue refresh tokens: enabled
#
OAUTH_SVC_DATAFILE="oauth2-svc.properties"

# Create the service
docker cp "$SCRIPT_DIR/cfg/$OAUTH_SVC_DATAFILE" "wrenam-test$TEST_INSTANCE_ID:/opt/ssoadm/auth/$OAUTH_SVC_DATAFILE"
exec_ssoadm $TEST_INSTANCE_ID add-svc-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" \
  --servicename OAuth2Provider \
  --datafile $OAUTH_SVC_DATAFILE \
  > /dev/null

# Create OAuth 2.0 agent
#
# Special settings different from defaults:
#   * Redirect URIs: $OAUTH_AGENT_REDIRECT_URI
#   * Scopes: openid, profile
#   * Implied consent: enabled
#
OAUTH_AGENT_DATAFILE="oauth2-agent.properties"

# Replace placeholders in datafile and copy it to the container
TEST_INSTANCE_ID=$TEST_INSTANCE_ID \
TEST_REALM=$TEST_REALM \
REDIRECT_URI=$OAUTH_AGENT_REDIRECT_URI \
AGENT_PASSWORD=$OAUTH_AGENT_SECRET \
envsubst < "$SCRIPT_DIR/cfg/$OAUTH_AGENT_DATAFILE" \
  | docker exec -i "wrenam-test"$TEST_INSTANCE_ID bash -c "cat > /opt/ssoadm/auth/$OAUTH_AGENT_DATAFILE"

# Create the agent
exec_ssoadm $TEST_INSTANCE_ID create-agent \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" \
  --agenttype OAuth2Client \
  --agentname $OAUTH_AGENT_ID \
  --datafile $OAUTH_AGENT_DATAFILE \
  > /dev/null
