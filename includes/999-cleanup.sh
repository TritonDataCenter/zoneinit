# Copyright 2013, Joyent. Inc. All rights reserved.

log "cleaning up"

svccfg -s zoneinit 'setprop application/done = true'
rm -f ${ZONECONFIG}

log "scheduling an immediate reboot"
echo "reboot >/dev/null" | at now >/dev/null
