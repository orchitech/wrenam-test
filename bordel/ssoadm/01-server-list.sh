#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

login_wren_am amadmin password
# Get server information
curl http://localhost:8080/auth/json/serverinfo