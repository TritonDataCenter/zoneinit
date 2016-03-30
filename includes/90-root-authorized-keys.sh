#!/bin/bash
# Configure root ssh authorized_keys file if available via mdata

if mdata-get root_authorized_keys 1>/dev/null 2>&1; then
  install --directory --mode=700 /root/.ssh
  echo "# This file is managed by mdata-get root_authorized_keys" \
    > /root/.ssh/authorized_keys
  mdata-get root_authorized_keys >> /root/.ssh/authorized_keys
  chmod 644 /root/.ssh/authorized_keys
fi
