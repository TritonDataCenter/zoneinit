#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

for _hashtool in /usr/lib/cryptpass $(type -p genbfpw); do
	if [[ -x $_hashtool ]]; then
		hashtool=${_hashtool/genbfpw/genbfpw -p}
		break
	fi
done

for passtool in $(type -p changepass); do
	if [[ -x $passtool ]]; then
		passtool=$passtool
		break
	fi
done

for user in "${USERS[@]}"; do
	log "setting system password for user '$user'"
	pass_var_lower=${user}_pw
	pass_var_upper=$(echo "$pass_var_lower" | tr '[[:lower:]]' '[[:upper:]]')
	user_pw=${PASSWORDS[$pass_var_upper]}

	if [[ -n $user_pw && -n $hashtool && -n $passtool ]]; then
		# Make sure it's blowfish-hashed
		[[ "$user_pw" =~ ^\$2a\$ ]] || user_pw=$("$hashtool" "$user_pw")

		if echo "$user:$user_pw" | changepass -e &>/dev/null; then
			SSH_ALLOW_PASSWORDS=true
		else
			log "system password change for '$user' failed"
			passwd -N "$user" >/dev/null
		fi
	else
		passwd -N "$user" >/dev/null
	fi
done
