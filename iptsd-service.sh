#!/system/bin/sh
#
# Copyright (C) 2022 BlissLabs
#
before=1

while [ $before != NULL ]
do
hidraw_device=$(/system/vendor/bin/iptsd-find-hidraw)
if [[ $changed_device != $hidraw_device ]]; then
    echo "the device has been changed"
    changed_device=$hidraw_device
    stop iptsd
    setprop persist.ipts.device $changed_device
    start iptsd
    sleep 2
fi
done
