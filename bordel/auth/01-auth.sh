#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

log_message "Sign in to application..."

login_wren_am amadmin password

log_message "User successfully signed in to aplication."

logout_wren_am

log_message  "User sign out from application"