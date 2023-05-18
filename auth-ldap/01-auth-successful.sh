#!/bin/bash

instance_id=1

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

AUTH_STATUS=$(source "$(dirname "${BASH_SOURCE[0]}")/../.authenticate.sh" $instance_id "John Doe" password)
[ "$AUTH_STATUS" == "200" ] || fail_test "Authentication ended with HTTP status code $AUTH_STATUS instead of expected 200."

log_message "Test case successful."
