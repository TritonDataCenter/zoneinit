#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

# Enable the mdata service that fetches the metadata user-script on each boot
log "enabling metadata agent"

if [[ $ZONE_SHOULD_REBOOT == 'true' ]]; then
	svcadm enable mdata:fetch
else
	svcadm enable -s mdata:fetch
fi
