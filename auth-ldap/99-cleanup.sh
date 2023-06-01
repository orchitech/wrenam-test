#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Restore test user's original password
exec_ldap bash -c "ldapmodify -D $ADMIN_DN -w $ADMIN_PASSWORD <<< '
dn: '$TEST_USER_DN'
changetype: modify
replace: userPassword
userPassword: '$TEST_USER_PASSWORD'
'" > /dev/null
