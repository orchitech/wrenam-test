export OPENDJ_JAVA_ARGS=-Xmx256m

dsconfig \
  --verbose \
  --no-prompt \
  --trustAll \
  --port "$ADMIN_CONNECTOR_PORT" \
  --bindDN "$ROOT_USER_DN" \
  --bindPassword "$ROOT_USER_PASSWORD" \
  --batchFilePath "/dev/stdin" <<DSCONFIG_EOF


# Make UID attribute unique
set-plugin-prop \
  --plugin-name "UID Unique Attribute" \
  --set base-dn:ou=people,dc=sanomalearning,dc=com \
  --set enabled:true

# Create password complexity validator
create-password-validator \
  --validator-name "complexity" \
  --type character-set \
  --set enabled:true \
  --set character-set:1:abcdefghijklmnopqrstuvwxyz \
  --set character-set:1:ABCDEFGHIJKLMNOPQRSTUVWXYZ \
  --set character-set:1:0123456789 \
  --set allow-unclassified-characters:true \
  --set min-character-sets:3

# Create password length validator
create-password-validator \
  --validator-name minimum-length \
  --type length-based \
  --set enabled:true \
  --set min-password-length:8

# Configure combined log format
set-log-publisher-prop \
 --publisher-name File-Based\ Access\ Logger \
 --set log-format:combined

# Configure password policy
set-password-policy-prop \
  --policy-name "Default Password Policy" \
  --set lockout-failure-count:3 \
  --set password-history-count:5 \
  --set password-validator:minimum-length

DSCONFIG_EOF
