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
        for part in kernel initrd system recovery; do
            for suffix in _a _b; do
                loop_device=$(losetup -a | grep "$part$suffix" | cut -d ":" -f1)
                loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
                if [ ! -z "$loop_device_num" ]; then
                    mknod "/dev/block/by-name/$part$suffix" b 7 $loop_device_num
                fi
            done
        done

        loop_device=$(losetup -a | grep kernel_a | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot_a" b 7 $loop_device_num
        loop_device=$(losetup -a | grep kernel_b | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot_b" b 7 $loop_device_num

        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/misc

        ln -s /dev/block/by-name/recovery_a /dev/block/by-name/ramdisk-recovery_a
        ln -s /dev/block/by-name/recovery_b /dev/block/by-name/ramdisk-recovery_b
    else
        mkdir -p /dev/block/by-name
        for part in kernel initrd system recovery; do
                loop_device=$(losetup -a | grep "$part" | cut -d ":" -f1)
                loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
                if [ ! -z "$loop_device_num" ]; then
                    mknod "/dev/block/by-name/$part" b 7 $loop_device_num
                fi
        done
        loop_device=$(losetup -a | grep kernel | cut -d ":" -f1)
        loop_device_num=$(echo $loop_device | cut -d '/' -f 4 | cut -d 'p' -f 2)
        mknod "/dev/block/by-name/boot" b 7 $loop_device_num

        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/misc
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
    if [ ! -z "$ab_slot" ]; then
        echo "/dev/block/by-name/system     /system   ext4    defaults        slotselect,first_stage_mount" >> /etc/recovery.fstab
    else
        echo "/dev/block/by-name/system     /system   ext4    defaults        defaults" >> /etc/recovery.fstab
    fi

    # Create /dev/block/bootdevice/by-name
    # because some scripts are dumb
    mkdir -p /dev/block/bootdevice
    ln -s /dev/block/by-name /dev/block/bootdevice/by-name
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

# import cmdline variables
for c in `cat /proc/cmdline`; do
	case $c in
		BOOT_IMAGE=*|iso-scan/*|*.*=*)
			;;
		nomodeset)
			HWACCEL=0
			;;
		*=*)
			eval $c
			if [ -z "$1" ]; then
				case $c in
					DEBUG=*)
						[ -n "$DEBUG" ] && set_property debug.logcat 1
						[ "$DEBUG" = "0" ] || SETUPWIZARD=${SETUPWIZARD:-0}
						;;
					DPI=*)
						set_property ro.sf.lcd_density "$DPI"
						;;
				esac
			fi
			;;
	esac
done

[ -n "$DEBUG" ] && set -x || exec &> /dev/null

case "$1" in
	netconsole)
		[ -n "$DEBUG" ] && do_netconsole
		;;
	init|"")
		do_init
		;;
esac

return 0
