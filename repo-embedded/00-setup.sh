#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

EMBEDDED_DS_INSTANCE_ID=9

# Start Wren:AM with embedded DS repository
start_am $EMBEDDED_DS_INSTANCE_ID
exec_am $EMBEDDED_DS_INSTANCE_ID java -jar /opt/ssoconf/openam-configurator-tool.jar --file /srv/wrenam/config.properties
wait_am $EMBEDDED_DS_INSTANCE_ID

# Check whether Wren:AM is alive
check_am $EMBEDDED_DS_INSTANCE_ID

# Stop Wren:AM
stop_am $EMBEDDED_DS_INSTANCE_ID
