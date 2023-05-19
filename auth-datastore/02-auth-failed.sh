#!/bin/bash

instance_id=1

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.authentication.sh"

AUTH_RES=$(basic_authentication $instance_id amadmin wrong_password)
check_response_status 401 "$AUTH_RES"

log_message "Test case successful."
