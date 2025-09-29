#!/bin/bash -eu
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

# Wren:AM server instance base URL (SERVER_URL configuration parameter)
WRENAM_SERVER_URL=${WRENAM_SERVER_URL:-http://wrenam1.wrensecurity.local:8080}

# Wren:AM servlet context path (DEPLOYMENT_URI configuration parameter)
WRENAM_DEPLOYMENT_URI=${WRENAM_DEPLOYMENT_URI:-/auth}

# Wren:AM base configuration directory (BASE_DIR configuration parameter)
WRENAM_BASE_DIR=${WRENAM_BASE_DIR:-/srv/wrenam}

# Path to configuration directory
WRENAM_INIT_PATH=${WRENAM_INIT_PATH:-$WRENAM_BASE_DIR/init}

# Fetch server status (content of the isAlive.jsp page)
check_am() {
  status=$(curl -s "http://$WRENAM_DEPLOYMENT_URI:8080/isAlive.jsp")
  [ $? -eq 0 ] || return 1
  echo "$status"
}

# Log initialization debug message
log_init() {
  echo "[INIT] $@"
}

# Initialize new server instance
init_am() {
  export CATALINA_PID="/tmp/catalina-setup.pid"

  log_init "Starting Tomcat server..."
  catalina.sh start
  while ! $(check_am > /dev/null); do
    log_init "Waiting Tomcat initialization..."
    sleep 2
  done

  log_init "Initializing Wren:AM instance..."
  cd /opt/ssoconf
  java \
    -jar ./openam-configurator-tool.jar \
    --file "$WRENAM_INIT_PATH/init.properties"
  while true; do
    $(check_am | grep "Server is ALIVE:" > /dev/null) && break
    log_init "Waiting Wren:AM initialization..."
    sleep 2
  done

  log_init "Configuring SSO Admin Tools..."
  cd /opt/ssoadm
  ./setup --path $WRENAM_BASE_DIR --acceptLicense

  log_init "Configuring Wren:AM services..."
  cd "$WRENAM_INIT_PATH"
  if [[ -f config.batch ]]; then
    /opt/ssoadm${WRENAM_DEPLOYMENT_URI}/bin/ssoadm \
      do-batch \
      --adminid amadmin \
      --password-file <(echo -n "password") \
      --batchfile "config.batch"
  fi

  log_init "Restarting Tomcat server..."
  catalina.sh stop 15 -force
}

if [ ! -d "$WRENAM_BASE_DIR$WRENAM_DEPLOYMENT_URI" ]; then
  if [ -f "$WRENAM_INIT_PATH/init.properties" ]; then
    log_init "First start..."
    init_am
  fi
fi

exec "$@"
