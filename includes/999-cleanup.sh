#!/usr/bin/env bash
# Copyright (c) 2017, Joyent. Inc.

log 'cleaning up'

svccfg -s zoneinit 'setprop application/done = true'
svcadm refresh zoneinit
rm -f "$ZONECONFIG"

if [[ $ZONE_SHOULD_REBOOT == 'true' ]]; then
	log 'scheduling an immediate reboot'
	echo 'reboot >/dev/null' | at now >/dev/null
fi
