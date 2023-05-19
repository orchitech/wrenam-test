#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

log_message "Configuring Global CSV Handler for this test..."
configure_global_csv_handler false true
