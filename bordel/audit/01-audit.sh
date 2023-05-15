#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

docker exec -w /opt/ssoadm/auth/bin/ "wrenam-test" ./ssoadm \
  set-attr-defs \
    --adminid amadmin \
    --password-file ../../password.txt \
    --servicename sunAMAuthADService \
    --schematype Global \
