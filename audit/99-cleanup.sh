#!/bin/bash

instance_id=1

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/.support.sh" $instance_id

restore_global_csv_handler_configuration
