#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/.common.sh"

start_am
wait_for_start
configure_server
configure_ssoadm
