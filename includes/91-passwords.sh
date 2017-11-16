#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

for _HASHTOOL in /usr/lib/cryptpass $(type -p genbfpw); do
	if [[ -x $_HASHTOOL ]]; then
		HASHTOOL=${_HASHTOOL/genbfpw/genbfpw -p}
		break
	fi
done

for _PASSTOOL in $(type -p changepass); do
	if [[ -x $_PASSTOOL ]]; then
		PASSTOOL=$_PASSTOOL
		break
	fi
done

for user in "${USERS[@]}"; do
	log "setting system password for user '$user'"
	PASS_VAR_LOWER=${user}_pw
	PASS_VAR_UPPER=$(echo "$PASS_VAR_LOWER" | tr '[[:lower:]]' '[[:upper:]]')
	user_pw=${PASSWORDS[$PASS_VAR_UPPER]}

	if [[ -n $user_pw && -n $hashtool && $passtool ]]; then
		# Make sure it's blowfish-hashed
		[[ "${user_pw}" =~ ^\$2a\$ ]] || user_pw=$(${HASHTOOL} "${user_pw}")

		if echo "${user}:${user_pw}" | changepass -e > /dev/null 2>&1; then
			SSH_ALLOW_PASSWORDS=true
		else
			log "system password change for '$user' failed"
			passwd -N "$user" >/dev/null
		fi
	else
		passwd -N "$user" >/dev/null
	fi
done
