#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Delete the realm if it already exists
exec_ssoadm $TEST_INSTANCE_ID delete-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm $TEST_REALM || : # ignore error exit code in case the realm does not exist

# Create new realm
exec_ssoadm $TEST_INSTANCE_ID create-realm \
  --adminid amadmin \
  --password-file pwd.txt \
  --realm $TEST_REALM
