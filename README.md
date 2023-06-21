# Wren:AM System Test Resources

Resources for performing Wren:AM system tests.

## Test Categories

* audit - Configuring audit and publishing audit events
* auth-datastore - Datastore authentication module features
* auth-ldap - LDAP authentication module features
* auth-radius - RADIUS authentication module features
* auth-winsso - Windows SSO authentication module features
* cts - Core Token Store features
* ha - High-Availability features
* oauth2 - OAuth2 server features (including OIDC)
* policy - Entitlements, access policies and their evaluation
* ssoadm - SSO Administration Tools CLI
* ssoconf - SSO Configurator Tools CLI

## Running Tests

Tests can be run manually by executing shell scripts in alphabetical order in their
respective test category folder.

Use `run.sh` shell script to run the whole test suite:

```console
$ ./run.sh
```

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
