#
# The contents of this file are subject to the terms of the Common Development and
# Distribution License (the License). You may not use this file except in compliance with the
# License.
#
# You can obtain a copy of the License at legal/CDDLv1.1.txt. See the License for the
# specific language governing permission and limitations under the License.
#
# When distributing Covered Software, include this CDDL Header Notice in each file and include
# the License file at legal/CDDLv1.1.txt. If applicable, add the following below the CDDL
# Header, with the fields enclosed by brackets [] replaced by your own identifying
# information: "Portions copyright [year] [name of copyright owner]".
#
# Copyright 2025 Orchitech
#

# Start Wren:AM instance
#
# Arguments:
#   [INSTANCE_ID] - instance identifier
start_am() {
  local instance_id=${1:-1}
  docker compose up -d "wrenam"$instance_id
  wait_am $instance_id
  log_message "Wren:AM test instance $instance_id started..."
}


check_am() {
  local instance_id=${1:-1}
  local expect_alive=${2:-1}
  local status
  status=$(exec_am $instance_id curl -s http://localhost:8080/auth/isAlive.jsp)
  [ $? -eq 0 ] || return 1
  [ $expect_alive -ne 1 ] || $(echo "$status" | grep "Server is ALIVE:" > /dev/null)
}