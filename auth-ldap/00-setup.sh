#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

TEST_INSTANCE_ID=1

# Delete the realm if it already exists
exec_ssoadm $TEST_INSTANCE_ID delete-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" || : # ignore error exit code in case the realm does not exist

# Create new realm
exec_ssoadm $TEST_INSTANCE_ID create-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM"

# Configure default LDAP module
exec_ssoadm $TEST_INSTANCE_ID update-auth-instance \
  --adminid amadmin \
  --password-file pwd.txt \
  --name LDAP \
  --realm "$TEST_REALM" \
  --datafile /srv/wrenam/LDAP.properties

# Configure default ldapService chain
exec_ssoadm $TEST_INSTANCE_ID update-auth-cfg-entr \
  --adminid amadmin \
  --password-file pwd.txt \
  --name ldapService \
  --realm "$TEST_REALM" \
  --entries "LDAP|REQUISITE|"
