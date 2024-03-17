#
# Copyright (C) 2024 BlissLabs
#
# License: GNU Public License v2 or later
#

function set_property()
{
	setprop "$1" "$2"
	[ -n "$DEBUG" ] && echo "$1"="$2" >> /dev/x86.prop
}

function set_prop_if_empty()
{
	[ -z "$(getprop $1)" ] && set_property "$1" "$2"
}

function init_misc()
{
	# Tell vold to use ntfs3 driver instead of ntfs-3g
    if [ "$USE_NTFS3" -ge "1" ] || [ "$VOLD_USE_NTFS3" -ge 1 ]; then
        set_property ro.vold.use_ntfs3 true
    fi
}

function init_loop_links()
{
    # Setup partitions loop
	if [ "$(cat /proc/cmdline | grep androidboot.slot_suffix)" ]; then
        mkdir -p /dev/block/by-name
        for part in kernel initrd system; do
            for suffix in _a _b; do
                loop_device=$(losetup -a | grep "$part$suffix" | cut -d ":" -f1)
                loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
                if [ ! -z "$loop_device_num" ]; then
                    mknod "/dev/block/by-name/$part$suffix" b 7 $loop_device_num
                fi
            done
        done
        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/misc" b 7 $loop_device_num
        loop_device=$(losetup -a | grep recovery | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/recovery" b 7 $loop_device_num
        loop_device=$(losetup -a | grep kernel_a | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot_a" b 7 $loop_device_num
        loop_device=$(losetup -a | grep kernel_b | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot_b" b 7 $loop_device_num
    else
        mkdir -p /dev/block/by-name
        for part in kernel initrd system; do
                loop_device=$(losetup -a | grep "$part" | cut -d ":" -f1)
                loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
                if [ ! -z "$loop_device_num" ]; then
                    mknod "/dev/block/by-name/$part" b 7 $loop_device_num
                fi
        done
        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/misc" b 7 $loop_device_num
        loop_device=$(losetup -a | grep recovery | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/recovery" b 7 $loop_device_num
        loop_device=$(losetup -a | grep kernel | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot" b 7 $loop_device_num
    fi

    # Insert /data to recovery.fstab
    if [ "$(getprop sys.recovery.data_is_part)" ] && [ "$(getprop sys.recovery.data_part)" ]; then
        data_part=$(getprop sys.recovery.data_part)
        if [ "$(toybox blkid /dev/block/$data_part | grep ext4)" ]; then
            echo "/dev/block/$data_part     /data    ext4    rw,noatime       defaults" >> /etc/recovery.fstab
        elif [ "$(toybox blkid /dev/block/$data_part | grep f2fs)" ]; then
            echo "/dev/block/$data_part     /data    f2fs    rw,noatime       defaults" >> /etc/recovery.fstab
        fi
    fi
    if [ "$(getprop sys.recovery.data_is_part)" ] && [ "$(getprop sys.recovery.data_is_img)" ]; then
        loop_device=$(losetup -a | grep data | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/userdata
        echo "/dev/block/by-name/userdata     /data   ext4    defaults        defaults" >> /etc/recovery.fstab
    fi

    # Insert /system into recovery.fstab
    ab_slot=$(getprop ro.boot.slot_suffix)
    if [ "$ab_slot" = "_a" ]; then
        echo "/dev/block/by-name/system_a     /system   ext4    defaults        defaults" >> /etc/recovery.fstab
    elif [ "$ab_slot" = "_b" ]; then
        echo "/dev/block/by-name/system_b     /system   ext4    defaults        defaults" >> /etc/recovery.fstab
    else
        echo "/dev/block/by-name/system     /system   ext4    defaults        defaults" >> /etc/recovery.fstab
    fi
}

function do_netconsole()
{
	modprobe netconsole netconsole="@/,@$(getprop dhcp.eth0.gateway)/"
}

function do_init()
{
    init_misc
	init_loop_links
}

case "$1" in
	netconsole)
		[ -n "$DEBUG" ] && do_netconsole
		;;
	init|"")
		do_init
		;;
esac

return 0
