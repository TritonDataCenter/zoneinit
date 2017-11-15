#!/usr/bin/env bash
# Copyright (c) 2017, Joyent. Inc.

log "cleaning up"

svccfg -s zoneinit 'setprop application/done = true'
svcadm refresh zoneinit
rm -f ${ZONECONFIG}

if [[ $ZONE_SHOULD_REBOOT == 'true' ]]; then
	# Reboot the zone if features.reboot is true, or if the above call
	# fails to json.  This way, we are backwards-compatible with versions
	# of zoneinit that do not have zoneinit.json
	log "scheduling an immediate reboot"
	echo "reboot >/dev/null" | at now >/dev/null
fi
