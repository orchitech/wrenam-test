FROM osixia/openldap:1.5.0

COPY pwdchecker-1.1/check_password.so /usr/lib/ldap/check_password.so
COPY ldif/* /container/service/slapd/assets/config/bootstrap/ldif/custom/
