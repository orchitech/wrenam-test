#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

log_message "Checking for server status..."

check_am

log_message "All tests were succesful."