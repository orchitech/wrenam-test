#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

TEST_INSTANCE_ID=1

# Delete the realm if it already exists
exec_ssoadm $TEST_INSTANCE_ID delete-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" \
> /dev/null || :

# Create new realm
exec_ssoadm $TEST_INSTANCE_ID create-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm "$TEST_REALM" \
> /dev/null

# Configure default LDAP module
exec_ssoadm $TEST_INSTANCE_ID update-auth-instance \
  --adminid amadmin \
  --password-file pwd.txt \
  --name LDAP \
  --realm "$TEST_REALM" \
  --datafile /srv/wrenam/LDAP.properties \
> /dev/null

# Configure default ldapService chain
exec_ssoadm $TEST_INSTANCE_ID update-auth-cfg-entr \
  --adminid amadmin \
  --password-file pwd.txt \
  --name ldapService \
  --realm "$TEST_REALM" \
  --entries "LDAP|REQUISITE|" \
> /dev/null

# Make sure test user's password is what we expect
exec_ldap bash -c "ldapmodify -D $ADMIN_DN -w $ADMIN_PASSWORD <<< '
dn: '$TEST_USER_DN'
changetype: modify
replace: userPassword
userPassword: '$TEST_USER_PASSWORD'
'" > /dev/null
