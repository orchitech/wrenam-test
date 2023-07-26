# Wren:AM System Test Resources

Resources for performing Wren:AM system tests.

## Test Categories

* audit - Configuring audit and publishing audit events
* auth - _TODO_
* auth-adaptive - _TODO_
* auth-ad - _TODO_
* auth-anonymous - _TODO_
* auth-application - _TODO_
* auth-cert - _TODO_
* auth-datastore - Datastore authentication module features
* auth-deviceid - _TODO_
* auth-hotp - _TODO_
* auth-basic - _TODO_
* auth-jdbc - _TODO_
* auth-ldap - LDAP authentication module features
* auth-membership - _TODO_
* auth-msisdn - _TODO_
* auth-oath - _TODO_
* auth-oauth2 - _TODO_
* auth-oicd - _TODO_
* auth-cookie - _TODO_
* auth-push - _TODO_
* auth-radius - _TODO_
* auth-saml2 - _TODO_
* auth-scripted - _TODO_
* auth-securid - _TODO_
* auth-winsso - _TODO_
* cts - _TODO_
* federation - _TODO_
* ha - High-Availability features
* monitoring - _TODO_
* notification - _TODO_
* oauth2 - OAuth2 server features (including OIDC)
* plugin - _TODO_
* policy - Entitlements, access policies and their evaluation
* radius - _TODO_
* rest - _TODO_
* selfservice - _TODO_
* session - _TODO_
* snmp - _TODO_
* ssoadm - SSO Administration Tools CLI
* ssoconf - _TODO_
* sts - _TODO_
* ui-admin - _TODO_
* ui-login - _TODO_
* uma - _TODO_

## Running Tests

Tests can be run manually by executing shell scripts in alphabetical order in their
respective test category folder.

Use `run.sh` shell script to run the whole test suite:

```console
$ ./run.sh
```

Note that the whole test suite finishes successfully (without an error), the platform containers will be shutdown.
In case of a failed test, the platform won't be shutdown to allow for easier debugging.

Tests are based on docker image of Wren:AM named `wrenam`. This image name can be overriden
with `WRENAM_IMAGE` environment variable:

```console
$ WRENAM_IMAGE=wrenam-local ./run.sh
```

Failed tests can be resumed from a specific category with `RESUME_FROM` environment variable
(be sure to cleanup leftover docker containers before resuming):

```console
$ RESUME_FROM=replication ./run.sh
```
