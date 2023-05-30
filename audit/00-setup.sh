#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/.support.sh"

# Disable log buffering and enable auto flush so log file is updated immediately
log_message "Configuring Global CSV Handler for this test..."
exec_ssoadm $TEST_INSTANCE_ID set-sub-cfg \
  --adminid amadmin \
  --password-file pwd.txt \
  --servicename AuditService \
  --subconfigname "Global CSV Handler" \
  --operation set \
  --attributevalues "bufferingEnabled=false" "bufferingAutoFlush=true"
