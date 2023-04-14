#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"

log_message "Start OpenLDAP"

log_message "Login to OpenLDAP"
docker exec -it openldap ldapsearch -w password -D cn=admin,dc=example,dc=org -b dc=example,dc=org

log_message "Connection to OpenLDAP completed!"

log_message "Creating realm...."

# docker exec -w /opt/ssoadm "wrenam-test" touch pwd.txt \
#   echo "password" > pwd.txt

# docker exec -w /opt/ssoadm/auth/bin/ "wrenam-test" ./ssoadm \
#   create-realm \
#   --adminid amadmin \
#   --password-file ../../pwd.txt \
#   --realm /foo \

# log_message "Realm created!"

log_message "Creating LDAP instance...."

docker exec -w /opt/ssoadm/auth/bin/ "wrenam-test" ./ssoadm \
  create-auth-instance \
  --adminid amadmin \
  --password-file ../../pwd.txt \
  --realm /fo \
  --name LDAPtest \
  --authtype LDAP

log_message "LDAP instance created!"

log_message "Creating chain enduser..."

docker exec -w /opt/ssoadm/auth/bin/ "wrenam-test" ./ssoadm \
  create-auth-cfg \
  --adminid amadmin \
  --password-file ../../pwd.txt \
  --realm /fo \
  --name enduser

log_message "Chain enduser created!"

docker exec -w /srv/wrenam/opends/bin/ "wrenam-test" ./ldapmodify \
  --port 389 \
  --bindDN "cn=admin" \
  --filename 01-data.ldif


# LDAP_USERNAME="admin"
# LDAP_PASSWORD="password"

# AM_USERNAME="admin"
# AM_PASSWORD="password"
# AM_URL="http://localhost:8080/auth"

# HEADER_OPTS=(
#   -H "Accept: application/json"
#   -H "Content-Type: application/json"
#   -H "Accept-API-Version: protocol=2.0,resource=2.0"
# )
# ANONYMOUS_OPTS=(
#   -H "X-Password: anonymous"
#   -H "X-Username: anonymous"
# )
# CURL_OPTS=("${HEADER_OPTS[@]}" "${ANONYMOUS_OPTS[@]}")

# COOKIE_FILE="./cookies"

# log_message "Starting authentication..."

# # Starting authentication as amadmin

# AUTH_URL="${AM_URL}/json/realms/root/authenticate"
# AUTH_RES=$(curl -sfk "${CURL_OPTS[@]}" -c ${COOKIE_FILE} "$AUTH_URL" -X POST)

# LB_COOKIE=$(grep amlbcookie "$COOKIE_FILE" | sed -r 's/.*amlbcookie\t([0-9]*$)/\1/')
# log_message "Authentication session ID assigned on server $LB_COOKIE"

# COOKIE_STRING="amlbcookie=$LB_COOKIE"

# # Send form with username and password with amadmin user

# AUTH_1_URL="${AM_URL}/json/realms/root/authenticate"

# AUTH_1_REQ=$(echo "$AUTH_RES" |
#     jq ".callbacks[0].input[0].value = \"$AM_USERNAME\"" |
#     jq ".callbacks[1].input[0].value = \"$AM_PASSWORD\"")

# AUTH_1_RES=$(curl -sfk "${CURL_OPTS[@]}" -b "$COOKIE_STRING" "$AUTH_1_URL" -X POST -d "$AUTH_1_REQ")

# TOKEN_ID=$(echo $AUTH_1_RES | jq -r ".tokenId")
# log_message "SSO session ID: $TOKEN_ID"

# log_message "Authentication for ${AM_USERNAME} completed!"