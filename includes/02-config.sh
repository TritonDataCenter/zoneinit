#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

log "determine machine parameters and configuration"

# Little helper to overcome the problem that mdata-get doesn't use stderr
mdata() {
	set -o pipefail
	output=$(mdata-get "$1" 2>/dev/null) && echo -e "${output}" || return 1
}

mdata-nics() {
	mdata sdc:nics \
		| json -d '|' -e 'this.ips = this.ips && this.ips.join(",")' \
		-a interface ip ips nic_tag
}

log "checking for duplicate IPs"

if ifconfig -a | grep DUP >/dev/null ; then
	log "provisioned with IP already in use, shutting down."
	halt
fi

declare -A PUBLIC_IPS PRIVATE_IPS INTERFACE_IPS

ZONENAME=$(mdata sdc:zonename)
HOSTNAME=$(mdata sdc:hostname || echo "$ZONENAME")
DOMAINNAME=$(mdata sdc:dns_domain || echo "local")

RAM_IN_BYTES=$(("$(mdata sdc:max_physical_memory)" * 1024 * 1024))
SWAP_IN_BYTES=$(("$(mdata sdc:max_swap)" * 1024 * 1024))
TMPFS=$(mdata sdc:tmpfs || echo "$((RAM_IN_BYTES/1024/1024))")m

# We want to fail if anything in the pipe fails during this step
set -o pipefail
while IFS='|' read -r IFACE IP IPS NIC_TAG; do
	[[ -z $IPS ]] && IPS=$IP

	OLDIFS=$IFS
	IFS=','
	for this_ip in $IPS; do
		# strip prefix length and only use valid IPv4 addresses
		[[ "${this_ip%/*}." =~ ^(([01]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){4}$ ]] || continue
		INTERFACE_IPS[$IFACE]=$this_ip
		case $NIC_TAG in
			external)
				PUBLIC_IPS+=("$this_ip")
				;;
			*)
				PRIVATE_IPS+=("$this_ip")
				;;
		esac
	done
	IFS=$OLDIFS
done < <(mdata-nics)
set +o pipefail

# Pick a valid IP for either of the public/private vars, fall back to localhost
PUBLIC_IP=${PUBLIC_IPS[0]}
PRIVATE_IP=${PRIVATE_IPS[0]}
LOCAL_IP=$(ifconfig lo0 | awk '{if ($1=="inet") print $2}')

# Use mdata-get to retrieve passwords for users needed by the image
# put them in respective variables (e.g. for 'admin' use $ADMIN_PW)
# This works on 1st gen metadata platforms too (SDC 6.5.x).

: ${USERS=admin root}
USERS=(${USERS})

declare -A PASSWORDS

for user in ${USERS[@]}; do
	PASS_VAR_LOWER=${user}_pw
	PASS_VAR_UPPER=$(echo "$PASS_VAR_LOWER" | tr '[[:lower:]]' '[[:upper:]]')

	user_pw=$(mdata "$PASS_VAR_LOWER")
	if [[ -n $user_pw ]]; then
		PASSWORDS[$PASS_VAR_UPPER]=$user_pw
	fi
done
