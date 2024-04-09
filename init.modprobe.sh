#
# Copyright (C) 2013-2018 The Android-x86 Open Source Project
#
# License: GNU Public License v2 or later
#

auto_detect()
{
	tmp=/tmp/dev2mod
	echo 'dev2mod() { while read dev; do case $dev in' > $tmp
	sort -r /system/lib/modules/`uname -r`/modules.alias | \
		sed -n 's/[()]/*/g; s/^alias  *\([^ ]*\)  *\(.*\)/\1)modprobe \2;;/p' >> $tmp
	echo 'esac; done; }' >> $tmp
	for f in $(grep -Eh /system/lib/modules/`uname -r`/modules.dep | cut -d. -f1); do
		sed -i "/$(basename $f | sed 's/-/_/g')/d" $tmp
	done
	source $tmp
	cat /sys/bus/*/devices/*/uevent | grep MODALIAS | sed 's/^MODALIAS=//' | awk '!seen[$0]++' | dev2mod
	cat /sys/devices/virtual/wmi/*/modalias | dev2mod
}

auto_detect
