#!/bin/bash

instance_id=1

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh" $instance_id

log_message "Configuring Global CSV Handler for this test..."
configure_global_csv_handler false true
