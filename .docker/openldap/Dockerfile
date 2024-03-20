FROM osixia/openldap:1.5.0

EXPOSE 389 636

ADD schema/schema.schema /container/service/slapd/assets/config/bootstrap/schema/01-schema.schema

COPY pwdchecker-1.1/check_password.so /usr/lib/ldap/check_password.so
COPY ldif/* /container/service/slapd/assets/config/bootstrap/ldif/custom/
