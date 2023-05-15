#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

log_message "Checking for server status..."

check_ds

log_message "Server status is checked"