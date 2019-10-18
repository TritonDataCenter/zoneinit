#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

# Enable the mdata service that fetches the metadata user-script on each boot
log 'enabling metadata agent'

if [[ $ZONE_SHOULD_REBOOT == 'true' ]]; then
	# This service will not start if there is a reboot pending, so we
	# enable the service and move on immediately.
	svcadm enable mdata:fetch
else
	svcadm enable -s mdata:fetch
fi
