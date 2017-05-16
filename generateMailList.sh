#!/bin/bash

HIERA=$(which hiera)

if [ -z "$HIERA" ]; then
  echo 'Missing the hiera-command. Exiting...'
  exit 1
fi

HIERAFILE1='/etc/puppet/hieradata/openstack.yaml'
HIERAFILE2='/etc/puppet/hieradata/common.yaml'
HIERACONFIG='/etc/puppet/hiera.yaml'
HIERACMD1="$HIERA -y $HIERAFILE1 -c $HIERACONFIG"
HIERACMD2="$HIERA -y $HIERAFILE2 -c $HIERACONFIG"
LOCALFILE="/root/scripts/skyhigh-mail.txt"
REMOTEFILE="monitor.skyhigh.hig.no:/var/www/html/skyhigh-mail.txt"
TODAY=$(date +%F)

AUTH_HOST=$($HIERACMD2 profile::api::keystone::admin::ip)

OS_PASSWORD=$($HIERACMD1 profile::keystone::admin_password)
OS_AUTH_URL="http://${AUTH_HOST}:5000/v3"

OSCMD="openstack --os-username admin --os-password $OS_PASSWORD --os-project-name admin --os-auth-url $OS_AUTH_URL --os-identity-api-version 3"

declare -a mails=()

# Fetch a list of uniqe users with a project role
users=$($OSCMD role assignment list -f value -c User | sort | uniq | egrep '\w{64}')

# Exit if we didn't get any users
if [[ -z $users ]]; then
	echo "[ERROR] Encountered problems while connecting to keystone, or no users with active roles!"
	exit 1
fi

# Iterate through the users to find e-mail
for user in $users; do
	details=$($OSCMD user show $user -f value -c email -c name)
	if [[ -z $details ]]; then
		echo "[WARNING] Found a deactivated user, skipping..."
		echo "-----------------------------------------"
	else
		# A student may not have e-mail exposed in AD, but we know that all students
		# have <username>@stud.ntnu.no
		if [[ $details =~ @ ]]; then
			mail=$(echo $details | cut -d' ' -f1)
		else
			echo "[WARNING] No mail address in AD, assuming student..."
			mail="${details}@stud.ntnu.no"
  	fi
		echo "Found $mail"
		mails=("${mails[@]}" "$mail")
		echo "-----------------------------------------"
	fi
done

if [ -f $LOCALFILE ]; then
	mv $LOCALFILE{,-$TODAY}
fi

echo ${mails[@]} | tr ' ' '\n' | sort | uniq > $LOCALFILE
scp $LOCALFILE $REMOTEFILE
