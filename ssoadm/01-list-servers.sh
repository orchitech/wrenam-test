#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

TEST_INSTANCE_ID=1

SERVERS=$(
  exec_ssoadm $TEST_INSTANCE_ID list-servers \
    --adminid amadmin \
    --password-file pwd.txt
)
grep "http://wrenam[1-2].wrensecurity.local:8080/auth" <<< "$SERVERS" \
  | [ $(wc -l) = 2 ] || fail_test "Output contains unexpected servers: $SERVERS"
