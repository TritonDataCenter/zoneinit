#!/usr/bin/env bash
#
# Copyright 2013, Joyent. Inc. All rights reserved.
# Copyright 2026 Edgecast Cloud LLC.

log "cleaning up"

svccfg -s zoneinit 'setprop application/done = true'
svcadm refresh zoneinit

# Ensure the completion flag is set before we reboot, otherwise there is a
# potential chance that we will repeat provisioning on the next boot.
retries=30
until [[ "$(svcprop -s running -p application/done zoneinit)" == true ]]; do
    if (( retries == 0 )); then
        log "timed out waiting for application/done"
        return 1
    fi
    sleep 1
    retries=$((retries - 1))
done

rm -f ${ZONECONFIG}

log "scheduling an immediate reboot"
echo "reboot >/dev/null" | at now >/dev/null
