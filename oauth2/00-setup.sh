#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "$SCRIPT_DIR/../.common.sh"
. "$SCRIPT_DIR/.support.sh"

# Setup configuration

# Delete the realm if it already exists
exec_ssoadm 1 \
  delete-realm \
    --adminid amadmin \
    --password-file pwd.txt \
    --realm $REALM > /dev/null || true # ignore error exit code in case the realm does not exist

# Create new realm
exec_ssoadm $INSTANCE_ID \
  create-realm \
    --adminid amadmin \
    --password-file pwd.txt \
    --realm $REALM

# Create OAuth2 Provider Service
#
# Special settings different from defaults:
#   * Allow clients to skip consent: enabled
#   * Issue refresh tokens: enabled
#
# Provided XML file with service configuration was obtained via "export-svc-cfg" ssoadm command
#
OAUTH_SVC_CFG="oauth2-svc-cfg.xml"

# Copy service configuration file to container and replace placeholders
docker cp "$SCRIPT_DIR/cfg/$OAUTH_SVC_CFG" "wrenam-test$INSTANCE_ID:/opt/ssoadm/auth/$OAUTH_SVC_CFG"
exec_am $INSTANCE_ID bash -c "sed -i -e "s/{{REALM}}/$REALM/" /opt/ssoadm/auth/$OAUTH_SVC_CFG"

# Create the service
exec_ssoadm $INSTANCE_ID \
  update-svc \
    --adminid amadmin \
    --password-file pwd.txt \
    --xmlfile $OAUTH_SVC_CFG

# Create OAuth 2.0 agent
#
# Special settings different from defaults:
#   * Redirect URIs: $OAUTH_AGENT_REDIRECT_URI
#   * Scopes: openid, profile
#   * Implied consent: enabled
#
# Provided datafile was obtained via "show-agent" ssoadm command
#
OAUTH_AGENT_DATAFILE="oauth2-agent.txt"

# Copy datafile to container and replace placeholders
docker cp "$SCRIPT_DIR/cfg/$OAUTH_AGENT_DATAFILE" "wrenam-test$INSTANCE_ID:/opt/ssoadm/auth/$OAUTH_AGENT_DATAFILE"
exec_am $INSTANCE_ID bash -c "sed -i \
  -e 's/{{INSTANCE_ID}}/$INSTANCE_ID/' \
  -e 's/{{REALM}}/$REALM/' \
  -e 's|{{REDIRECT_URI}}|$OAUTH_AGENT_REDIRECT_URI|' \
  -e 's/{{AGENT_PASSWORD}}/$OAUTH_AGENT_SECRET/' \
  /opt/ssoadm/auth/$OAUTH_AGENT_DATAFILE"

# Create the agent
exec_ssoadm $INSTANCE_ID \
  create-agent \
    --adminid amadmin \
    --password-file pwd.txt \
    --agenttype OAuth2Client \
    --agentname $OAUTH_AGENT_ID \
    --realm $REALM \
    --datafile $OAUTH_AGENT_DATAFILE
