#!/bin/bash

# Variables shared between multiple test files

INSTANCE_ID=1
REALM="oauth"

AM_BASE_URL="http://wrenam$INSTANCE_ID.wrensecurity.local:8080/auth"
AM_USERNAME="John Doe"
AM_PASSWORD="password"

OAUTH_AGENT_ID="test"
OAUTH_AGENT_SECRET="password"
OAUTH_AGENT_REDIRECT_URI="http://test.example.org"
