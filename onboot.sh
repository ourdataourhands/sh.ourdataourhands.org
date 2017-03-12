#!/bin/bash
#
# Our Data Our Hands onboot
#
# Runs using curl|bash in the rc.local file on boot.
#
# Report bugs here:
# https://github.com/ourdataourhands/sh.ourdataourhands.org
#

# Vars
log="/home/pi/boot.log"
rpath="/mnt/storage/docker"
riseup="$rpath/riseup.sh"
firstboot="/boot/firstboot"
username="/mnt/storage/username"

# Log the start
dt="$(date)"
echo "$dt" > $log

# Updates
echo "Running updates..." >> $log
sudo apt-get update -y >> $log
sudo apt-get dist-upgrade -y >> $log
sudo apt-get clean -y >> $log

# First boot install ODOH
echo "First boot...  " >> $log
if [[ -f "$firstboot" ]]; then
	echo "yes, install!" >> $log
	sudo rm -f $firstboot
	# Phone home
	curl -s http://sh.ourdataourhands.org/beacon.sh | bash -s firstboot
	# Install
	curl -s http://sh.ourdataourhands.org/install.sh | bash
	exit 1;
else
	echo "nope, continue..." >> $log
	# Phone home
	curl -s http://sh.ourdataourhands.org/beacon.sh | bash -s boot
fi

# Set hostname
if [[ -f "$username" ]]; then
	echo "Checking hostname... " >> $log
	un="$(sudo cat $username)"
	hn="$(sudo hostname)"
	echo "$hn" >> $log
	echo "$un" >> $log
	if [[ "$hn" != "$un" ]]; then
		hnchange="$(sudo hostname $un)"
		echo "$hnchange" >> $log
		curl -s http://sh.ourdataourhands.org/beacon.sh | bash -s $un
		echo "Change hostname to $un" >> $log
	else
		echo "Same" >> $log
	fi
fi

# Rise up!
echo "Rising up..." >> $log
if [[ -f "$riseup" ]]; then
	cd $rpath
	echo "Update..." >> $log
	git pull
	echo "Run $riseup..." >> $log
	curl -s http://sh.ourdataourhands.org/beacon.sh | bash -s riseup
	sudo bash $riseup purge
else
	echo "$riseup not found" >> $log
fi
