#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

log 'setting hostname, IPs and resolvers'

echo "$HOSTNAME" > /etc/nodename
/bin/hostname "$HOSTNAME"

sed '/^127\.0\.0\.1/s/$/ '${HOSTNAME}'/' /etc/inet/hosts > /etc/inet/hosts.tmp
mv /etc/inet/hosts{.tmp,}
