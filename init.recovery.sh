#
# Copyright (C) 2024 BlissLabs
#
# License: GNU Public License v2 or later
#

function init_loop_links()
{
	if [ "$(cat /proc/cmdline | grep androidboot.slot_suffix)" ]; then
        mkdir -p /dev/block/by-name
        for part in kernel initrd system; do
            for suffix in _a _b; do
                loop_device=$(losetup -a | grep "$part$suffix" | cut -d ":" -f1)
                if [ ! -z "$loop_device" ]; then
                    ln -s $loop_device /dev/block/by-name/$part$suffix
                fi
            done
        done
        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/misc
        loop_device=$(losetup -a | grep recovery | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/recovery

        ln -s /dev/block/by-name/kernel_a /dev/block/by-name/boot_a
        ln -s /dev/block/by-name/kernel_b /dev/block/by-name/boot_b
    else
        mkdir -p /dev/block/by-name
        for part in kernel initrd system; do
                loop_device=$(losetup -a | grep "$part" | cut -d ":" -f1)
                if [ ! -z "$loop_device" ]; then
                    ln -s $loop_device /dev/block/by-name/$part
                fi
        done
        loop_device=$(losetup -a | grep misc | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/misc
        loop_device=$(losetup -a | grep recovery | cut -d ":" -f1)
        ln -s $loop_device /dev/block/by-name/recovery

        ln -s /dev/block/by-name/kernel /dev/block/by-name/boot
    fi
}

function do_netconsole()
{
	modprobe netconsole netconsole="@/,@$(getprop dhcp.eth0.gateway)/"
}

function do_init()
{
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
