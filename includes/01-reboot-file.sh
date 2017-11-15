#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

# A zone should reboot if features.reboot is true, or if the call to json
# fails. This way, we are backwards-compatible with versions of zoneinit that
# do not have zoneinit.json
shouldreboot=$(json -f "$ZONEINIT_DIR/zoneinit.json" features.reboot)
if [[ $shouldreboot == true ]] || (($? != 0)); then
	ZONE_SHOULD_REBOOT=true

	# create a temporary file that disappears on the first reboot
	touch /tmp/.FIRST_REBOOT_NOT_YET_COMPLETE
else
	ZONE_SHOULD_REBOOT=false
fi
