#
# Copyright (C) 2013-2018 The Android-x86 Open Source Project
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

function rmmod_if_exist()
{
	for m in $*; do
		[ -d /sys/module/$m ] && rmmod $m
	done
}

function init_misc()
{
	# a hack for USB modem
	lsusb | grep 1a8d:1000 && eject

	# in case no cpu governor driver autoloads
	[ -d /sys/devices/system/cpu/cpu0/cpufreq ] || modprobe acpi-cpufreq

	# enable sdcardfs if /data is not mounted on tmpfs or 9p
	#mount | grep /data\ | grep -qE 'tmpfs|9p'
	#[ $? -eq 0 ] && set_prop_if_empty ro.sys.sdcardfs false

	# remove wl if it's not used
	local wifi
	if [ -d /sys/class/net/wlan0 ]; then
		wifi=$(basename `readlink /sys/class/net/wlan0/device/driver`)
		[ "$wifi" != "wl" ] && rmmod_if_exist wl
	fi

	# disable virt_wifi by default, only turn on when user set VIRT_WIFI=1
	local eth=`getprop net.virt_wifi eth0`
	if [ -d /sys/class/net/$eth -a "$VIRT_WIFI" -gt "0" ]; then
		if [ -n "$wifi" -a "$VIRT_WIFI" -ge "1" ]; then
			rmmod_if_exist iwlmvm $wifi
		fi
		if [ ! -d /sys/class/net/wlan0 ]; then
			ifconfig $eth down
			ip link set $eth name wifi_eth
			ifconfig wifi_eth up
			ip link add link wifi_eth name wlan0 type virt_wifi
		fi
	fi

	##mgLRU tweak
    echo y > /sys/kernel/mm/lru_gen/enabled
    echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms

	##WIP: Enable USB as device support
    modprobe roles
    modprobe xhci-hcd
    modprobe xhci-pci
    modprobe dwc3
    modprobe dwc3-pci
}

function init_hal_audio()
{
	case "$PRODUCT" in
		VirtualBox*|Bochs*)
			[ -d /proc/asound/card0 ] || modprobe snd-sb16 isapnp=0 irq=5
			;;
		TS10*)
			set_prop_if_empty hal.audio.out pcmC0D2p
			;;
	esac
	
	# choose the first connected HDMI port on card 0 or 1
	pcm=$(alsa_ctl store -f - 0 2>/dev/null| grep "CARD" -A 2 | grep "value true" -B 1 | grep "HDMI.*pcm" | head -1 | sed -e's/.*pcm=\([0-9]*\).*/\1/')
	[ -z "${pcm##*[!0-9]*}" ] || set_prop_if_empty hal.audio.out "pcmC0D${pcm}p"
	pcm=$(alsa_ctl store -f - 1 2>/dev/null| grep "CARD" -A 2 | grep "value true" -B 1 | grep "HDMI.*pcm" | head -1 | sed -e's/.*pcm=\([0-9]*\).*/\1/')
	[ -z "${pcm##*[!0-9]*}" ] || set_prop_if_empty hal.audio.out "pcmC1D${pcm}p"
}

function init_hal_bluetooth()
{
	for r in /sys/class/rfkill/*; do
		type=$(cat $r/type)
		[ "$type" = "wlan" -o "$type" = "bluetooth" ] && echo 1 > $r/state
	done

	case "$PRODUCT" in
		T100TAF)
			set_property bluetooth.interface hci1
			;;
		T10*TA|M80TA|HP*Omni*)
			BTUART_PORT=/dev/ttyS1
			set_property hal.bluetooth.uart.proto bcm
			;;
		MacBookPro8*)
			rmmod b43
			modprobe b43 btcoex=0
			modprobe btusb
			;;
		# FIXME
		# Fix MacBook 2013-2015 (Air6/7&Pro11/12) BCM4360 ssb&wl conflict.
		MacBookPro11* | MacBookPro12* | MacBookAir6* | MacBookAir7*)
			rmmod b43
			rmmod ssb
			rmmod bcma
			rmmod wl
			modprobe wl
			modprobe btusb
			;;
		*)
			for bt in $(toybox lsusb -v | awk ' /Class:.E0/ { print $9 } '); do
				chown 1002.1002 $bt && chmod 660 $bt
			done
			;;
	esac

	if [ -n "$BTUART_PORT" ]; then
		set_property hal.bluetooth.uart $BTUART_PORT
		chown bluetooth.bluetooth $BTUART_PORT
		start btattach
	fi
}

function init_hal_camera()
{
	case "$UEVENT" in
		*e-tabPro*)
			set_prop_if_empty hal.camera.0 0,270
			set_prop_if_empty hal.camera.2 1,90
			;;
		*LenovoideapadD330*)
			set_prop_if_empty hal.camera.0 0,90
			set_prop_if_empty hal.camera.2 1,90
			;;
		*)
			;;
	esac
}

function init_hal_gps()
{
	# TODO
	return
}

function set_drm_mode()
{
	case "$PRODUCT" in
		ET1602*)
			drm_mode=1366x768
			;;
		*)
			[ -n "$video" ] && drm_mode=$video
			;;
	esac

	[ -n "$drm_mode" ] && set_property debug.drm.mode.force $drm_mode
}

function init_uvesafb()
{
	UVESA_MODE=${UVESA_MODE:-${video%@*}}

	case "$PRODUCT" in
		ET2002*)
			UVESA_MODE=${UVESA_MODE:-1600x900}
			;;
		*)
			;;
	esac

	modprobe uvesafb mode_option=${UVESA_MODE:-1024x768}-32 ${UVESA_OPTION:-mtrr=3 scroll=redraw} v86d=/system/bin/v86d
}

function init_hal_gralloc()
{
	case "$(readlink /sys/class/graphics/fb0/device/driver)" in
		*virtio_gpu)
			HWC=${HWC:-drm_minigbm_celadon}
			GRALLOC=${GRALLOC:-minigbm_arcvm}
			#video=${video:-1280x768}
			;&
		*nouveau)
			GRALLOC=${GRALLOC:-gbm_hack}
			;&
		*i915)
			if [ "$(cat /sys/kernel/debug/dri/0/i915_capabilities | grep -e 'gen' -e 'graphics version' | awk '{print $NF}')" -gt 9 ]; then
				HWC=${HWC:-drm_minigbm_celadon}
				GRALLOC=${GRALLOC:-minigbm}
			fi
			;&
		*amdgpu)
			HWC=${HWC:-drm_minigbm_celadon}
			GRALLOC=${GRALLOC:-minigbm}
			;&
		*radeon|*vmwgfx*)
			if [ "$HWACCEL" != "0" ]; then
				set_property ro.hardware.hwcomposer ${HWC}
				set_property ro.hardware.gralloc ${GRALLOC:-gbm}
				set_drm_mode
			fi
			;;
		"")
			init_uvesafb
			;&
		*)
			export HWACCEL=0
			;;
	esac

	if [ "$GRALLOC4_MINIGBM" = "1" ]; then
		set_property debug.ui.default_mapper 4
		set_property debug.ui.default_gralloc 4
		case "$GRALLOC" in
			minigbm)
				start vendor.graphics.allocator-4-0
			;;
			minigbm_arcvm)
				start vendor.graphics.allocator-4-0-arcvm
			;;
			minigbm_gbm_mesa)
				start vendor.graphics.allocator-4-0-gbm_mesa
			;;
			*)
			;;
		esac
	else
		set_property debug.ui.default_mapper 2
		set_property debug.ui.default_gralloc 2
		start vendor.gralloc-2-0
	fi

	[ -n "$DEBUG" ] && set_property debug.egl.trace error
}

function init_egl()
{

	if [ "$HWACCEL" != "0" ]; then
		if [ "$ANGLE" == "1" ]; then
			set_property ro.hardware.egl angle
		else
			set_property ro.hardware.egl mesa
		fi
	else
		if [ "$ANGLE" == "1" ]; then
			set_property ro.hardware.egl angle
		else
			set_property ro.hardware.egl swiftshader
		fi
		set_property ro.hardware.vulkan pastel
		start vendor.hwcomposer-2-1
	fi

	# Set OpenGLES version
	case "$FORCE_GLES" in
        *3.0*)
    	    set_property ro.opengles.version 196608
            export MESA_GLES_VERSION_OVERRIDE=3.0
		;;
		*3.1*)
    		set_property ro.opengles.version 196609
			export MESA_GLES_VERSION_OVERRIDE=3.1
		;;
		*3.2*)
    		set_property ro.opengles.version 196610
			export MESA_GLES_VERSION_OVERRIDE=3.2
		;;
		*)
    		set_property ro.opengles.version 196608
		;;
	esac

	# Set RenderEngine backend
	if [ -z ${FORCE_RENDERENGINE+x} ]; then
		set_property debug.renderengine.backend threaded
	else
		set_property debug.renderengine.backend $FORCE_RENDERENGINE
	fi

	# Set default GPU render
	if [ -z ${GPU_OVERRIDE+x} ]; then
		echo ""
	else
		set_property gralloc.gbm.device /dev/dri/$GPU_OVERRIDE
		set_property vendor.hwc.drm.device /dev/dri/$GPU_OVERRIDE
		set_property hwc.drm.device /dev/dri/$GPU_OVERRIDE
	fi

}

function init_hal_hwcomposer()
{
	# TODO
	if [ "$HWACCEL" != "0" ]; then
		if [ "$HWC" = "" ]; then
			set_property debug.sf.hwc_service_name drmfb
			start vendor.hwcomposer-2-1.drmfb
		else
			set_property debug.sf.hwc_service_name default
			start vendor.hwcomposer-2-4

			if [[ "$HWC" == "drm_celadon" || "$HWC" == "drm_minigbm_celadon" ]]; then
				set_property vendor.hwcomposer.planes.enabling $MULTI_PLANE
				set_property vendor.hwcomposer.planes.num $MULTI_PLANE_NUM
				set_property vendor.hwcomposer.preferred.mode.limit $HWC_PREFER_MODE
				set_property vendor.hwcomposer.connector.id $CONNECTOR_ID
				set_property vendor.hwcomposer.mode.id $MODE_ID
				set_property vendor.hwcomposer.connector.multi_refresh_rate $MULTI_REFRESH_RATE
			fi
		fi
	fi
}

function init_hal_media()
{
	# Check if we want to use codec2
	if [ -z ${CODEC2_LEVEL+x} ]; then
		echo ""
	else
		set_property debug.stagefright.ccodec $CODEC2_LEVEL
	fi

	# Disable YUV420 planar on OMX codecs
	if [ "$OMX_NO_YUV420" -ge "1" ]; then
		set_property ro.yuv420.disable true
	else
		set_property ro.yuv420.disable false
	fi

#FFMPEG Codec Setup
## Turn on/off FFMPEG OMX by default
	if [ "$FFMPEG_OMX_CODEC" -ge "1" ]; then
	    set_property media.sf.omx-plugin libffmpeg_omx.so
    	set_property media.sf.extractor-plugin libffmpeg_extractor.so
	else
	    set_property media.sf.omx-plugin ""
    	set_property media.sf.extractor-plugin ""
	    set_property debug.ffmpeg-omx.disable 1
	fi

## Enable logging
    if [ "$FFMPEG_CODEC_LOG" -ge "1" ]; then
        set_property debug.ffmpeg.loglevel verbose
    fi	
## Disable HWAccel (currently only VA-API) and use software rendering
    if [ "$FFMPEG_HWACCEL_DISABLE" -ge "1" ]; then
        set_property media.sf.hwaccel 0
    else
        set_property media.sf.hwaccel 1
    fi
## Put c2.ffmpeg to the highest rank amongst the media codecs
    if [ "$FFMPEG_CODEC2_PREFER" -ge "1" ]; then
        set_property debug.ffmpeg-codec2.rank 0
    else
        set_property debug.ffmpeg-codec2.rank 4294967295
    fi
## FFMPEG deinterlace, we will put both software mode and VA-API one here
	if [ -z "${FFMPEG_CODEC2_DEINTERLACE+x}" ]; then
		echo ""
	else
		set_property debug.ffmpeg-codec2.deinterlace $FFMPEG_CODEC2_DEINTERLACE
	fi
	if [ -z "${FFMPEG_CODEC2_DEINTERLACE_VAAPI+x}" ]; then
		echo ""
	else
		set_property debug.ffmpeg-codec2.deinterlace.vaapi $FFMPEG_CODEC2_DEINTERLACE_VAAPI
	fi
## Handle DRM prime on ffmpeg codecs, we will disable by default due to 
## the fact that it doesn't work with gbm_gralloc yet
	if [ "$FFMPEG_CODEC2_DRM" -ge "1" ]; then
	    set_property debug.ffmpeg-codec2.hwaccel.drm 1
	else
	    set_property debug.ffmpeg-codec2.hwaccel.drm 0
	fi

}

function init_hal_vulkan()
{
	case "$(readlink /sys/class/graphics/fb0/device/driver)" in
		*i915)
			if [ "$(cat /sys/kernel/debug/dri/0/i915_capabilities | grep -e 'gen' -e 'graphics version' | awk '{print $NF}')" -lt 9 ]; then
				set_property ro.hardware.vulkan intel_hasvk
			else
				set_property ro.hardware.vulkan intel
			fi
			;;
		*amdgpu)
			set_property ro.hardware.vulkan radeon
			;;
		*virtio_gpu)
			set_property ro.hardware.vulkan virtio
			;;
		*)
			set_property ro.hardware.vulkan pastel
			;;
	esac
}

function init_hal_lights()
{
	chown 1000.1000 /sys/class/backlight/*/brightness
}

function init_hal_power()
{
	for p in /sys/class/rtc/*; do
		echo disabled > $p/device/power/wakeup
	done

	# TODO
	case "$PRODUCT" in
		HP*Omni*|OEMB|Standard*PC*|Surface*3|T10*TA|VMware*)
			set_prop_if_empty sleep.state none
			;;
		e-tab*Pro)
			set_prop_if_empty sleep.state force
			;;
		*)
			;;
	esac
}

function init_hal_thermal()
{
	#thermal-daemon test, pulled from Project Celadon
	case "$(cat /sys/class/dmi/id/chassis_vendor | head -1)" in 
	QEMU)
		setprop vendor.thermal.enable 0
		;;
	*)
		setprop vendor.thermal.enable 1
		;;
	esac
}

function init_hal_sensors()
{
    if [ "$SENSORS_FORCE_KBDSENSOR" == "1" ]; then
        # Option to force kbd sensor
        hal_sensors=kbd
        has_sensors=true
    else
        # if we have sensor module for our hardware, use it
        ro_hardware=$(getprop ro.hardware)
        [ -f /system/lib/hw/sensors.${ro_hardware}.so ] && return 0

        local hal_sensors=kbd
        local has_sensors=true
        case "$UEVENT" in
            *MS-N0E1*)
                set_property ro.ignore_atkbd 1
                set_property poweroff.doubleclick 0
                setkeycodes 0xa5 125
                setkeycodes 0xa7 1
                setkeycodes 0xe3 142
                ;;
            *Aspire1*25*)
                modprobe lis3lv02d_i2c
                echo -n "enabled" > /sys/class/thermal/thermal_zone0/mode
                ;;
            *Aspire*SW5-012*)
                set_property ro.iio.accel.order 102
                ;;
            *LenovoideapadD330*)
                set_property ro.iio.accel.order 102
                set_property ro.ignore_atkbd 1
                ;&
            *LINX1010B*)
                set_property ro.iio.accel.x.opt_scale -1
                set_property ro.iio.accel.z.opt_scale -1
                ;;
            *i7Stylus*|*M80TA*)
                set_property ro.iio.accel.x.opt_scale -1
                ;;
            *LenovoMIIX320*|*ONDATablet*)
                set_property ro.iio.accel.order 102
                set_property ro.iio.accel.x.opt_scale -1
                set_property ro.iio.accel.y.opt_scale -1
                ;;
            *Venue*8*Pro*3845*)
                set_property ro.iio.accel.order 102
                ;;
            *ST70416-6*)
                set_property ro.iio.accel.order 102
                ;;
            *T*0*TA*|*M80TA*)
                set_property ro.iio.accel.y.opt_scale -1
                ;;
			*Akoya*P2213T*)
				set_property ro.iio.accel.order 102
				;;
            *TECLAST*X4*)
                set_property ro.iio.accel.order 102
                set_property ro.iio.accel.x.opt_scale -1
                set_property ro.iio.accel.y.opt_scale -1
                ;;
            *SwitchSA5-271*|*SwitchSA5-271P*)
                set_property ro.ignore_atkbd 1
                has_sensors=true
                hal_sensors=iio
                ;&
            *)
                has_sensors=false
                ;;
        esac

            # has iio sensor-hub?
            if [ -n "`ls /sys/bus/iio/devices/iio:device* 2> /dev/null`" ]; then
                toybox chown -R 1000.1000 /sys/bus/iio/devices/iio:device*/
                [ -n "`ls /sys/bus/iio/devices/iio:device*/in_accel_x_raw 2> /dev/null`" ] && has_sensors=true
                hal_sensors=iio
            elif [ "$hal_sensors" != "kbd" ] | [ hal_sensors=iio ]; then
                has_sensors=true
            fi
    fi

    set_property ro.iio.accel.quirks "no-trig,no-event"
    set_property ro.iio.anglvel.quirks "no-trig,no-event"
    set_property ro.iio.magn.quirks "no-trig,no-event"
    set_property ro.hardware.sensors $hal_sensors
    set_property config.override_forced_orient ${HAS_SENSORS:-$has_sensors}
}

function create_pointercal()
{
	if [ ! -e /data/misc/tscal/pointercal ]; then
		mkdir -p /data/misc/tscal
		touch /data/misc/tscal/pointercal
		chown 1000.1000 /data/misc/tscal /data/misc/tscal/*
		chmod 775 /data/misc/tscal
		chmod 664 /data/misc/tscal/pointercal
	fi
}

function init_tscal()
{
	case "$UEVENT" in
		*ST70416-6*)
			modprobe gslx680_ts_acpi
			;&
		*T91*|*T101*|*ET2002*|*74499FU*|*945GSE-ITE8712*|*CF-19[CDYFGKLP]*|*TECLAST:rntPAD*)
			create_pointercal
			return
			;;
		*)
			;;
	esac

	for usbts in $(lsusb | awk '{ print $6 }'); do
		case "$usbts" in
			0596:0001|0eef:0001|14e1:6000|14e1:5000)
				create_pointercal
				return
				;;
			*)
				;;
		esac
	done
}

function init_ril()
{
	case "$UEVENT" in
		*TEGA*|*2010:svnIntel:*|*Lucid-MWE*)
			set_property rild.libpath /system/lib/libhuaweigeneric-ril.so
			set_property rild.libargs "-d /dev/ttyUSB2 -v /dev/ttyUSB1"
			set_property ro.radio.noril no
			;;
		*)
			set_property ro.radio.noril yes
			;;
	esac
}

function init_cpu_governor()
{
	governor=$(getprop cpu.governor)

	[ $governor ] && {
		for cpu in $(ls -d /sys/devices/system/cpu/cpu?); do
			echo $governor > $cpu/cpufreq/scaling_governor || return 1
		done
	}
}

function set_lowmem()
{
	# 512 MB size in kB : https://source.android.com/devices/tech/perf/low-ram
	SIZE_512MB=2048000

	mem_size=`cat /proc/meminfo | grep MemTotal | tr -s ' ' | cut -d ' ' -f 2`

	if [ "$mem_size" -le "$SIZE_512MB" ]
	then
		setprop ro.config.low_ram true
	else
		setprop ro.config.low_ram false
	fi
}

function init_loop_links()
{
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

	ln -s /dev/block/by-name/kernel_a /dev/block/by-name/boot_a
	ln -s /dev/block/by-name/kernel_b /dev/block/by-name/boot_b
}

function do_init()
{
	init_misc
	set_lowmem
	init_hal_audio
	init_hal_bluetooth
	init_hal_camera
	init_hal_gps
	init_hal_gralloc
	init_hal_hwcomposer
	init_hal_media
	init_hal_vulkan
	init_hal_lights
	init_hal_power
	init_hal_thermal
	init_hal_sensors
	init_tscal
	init_ril
	init_loop_links
	post_init
}

function do_netconsole()
{
	modprobe netconsole netconsole="@/,@$(getprop dhcp.eth0.gateway)/"
}

function do_bootcomplete()
{
	hciconfig | grep -q hci || pm disable com.android.bluetooth

	init_cpu_governor

	[ -z "$(getprop persist.sys.root_access)" ] && setprop persist.sys.root_access 3

	lsmod | grep -Ehq "brcmfmac|rtl8723be" && setprop wlan.no-unload-driver 1

	case "$PRODUCT" in
		Surface*Go)
			echo on > /sys/devices/pci0000:00/0000:00:15.1/i2c_designware.1/power/control
			;;
		VMware*)
			pm disable com.android.bluetooth
			;;
		X80*Power)
			set_property power.nonboot-cpu-off 1
			;;
		*)
			;;
	esac

#	[ -d /proc/asound/card0 ] || modprobe snd-dummy
	for c in $(grep '\[.*\]' /proc/asound/cards | awk '{print $1}'); do
		f=/system/etc/alsa/$(cat /proc/asound/card$c/id).state
		if [ -e $f ]; then
			alsa_ctl -f $f restore $c
		else
			alsa_ctl init $c
			alsa_amixer -c $c set Master on
			alsa_amixer -c $c set Master 100%
			alsa_amixer -c $c set Headphone on
			alsa_amixer -c $c set Headphone 100%
			alsa_amixer -c $c set Speaker 100%
			alsa_amixer -c $c set Capture 80%
			alsa_amixer -c $c set Capture cap
			alsa_amixer -c $c set PCM 100% unmute
			alsa_amixer -c $c set SPO unmute
			alsa_amixer -c $c set IEC958 on
			alsa_amixer -c $c set 'Mic Boost' 1
			alsa_amixer -c $c set 'Internal Mic Boost' 1
		fi
	done

	# check wifi setup
	FILE_CHECK=/data/misc/wifi/wpa_supplicant.conf

	if [ ! -f "$FILE_CHECK" ]; then
	    cp -a /system/etc/wifi/wpa_supplicant.conf $FILE_CHECK
            chown 1010.1010 $FILE_CHECK
            chmod 660 $FILE_CHECK
	fi

	POST_INST=/data/vendor/post_inst_complete
	USER_APPS=/system/etc/user_app/*
	BUILD_DATETIME=$(getprop ro.build.date.utc)
	POST_INST_NUM=$(cat $POST_INST)

	if [ ! "$BUILD_DATETIME" == "$POST_INST_NUM" ]; then
		for apk in $USER_APPS
		do		
			pm install $apk
		done
		rm "$POST_INST"
		touch "$POST_INST"
		echo $BUILD_DATETIME > "$POST_INST"
	fi

	#Auto activate XtMapper
	#nohup env LD_LIBRARY_PATH=$(echo /data/app/*/xtr.keymapper*/lib/x86_64) \
	#CLASSPATH=$(echo /data/app/*/xtr.keymapper*/base.apk) /system/bin/app_process \
	#/system/bin xtr.keymapper.server.InputService > /dev/null 2>&1 &

	post_bootcomplete
}

PATH=/sbin:/system/bin:/system/xbin

DMIPATH=/sys/class/dmi/id
BOARD=$(cat $DMIPATH/board_name)
PRODUCT=$(cat $DMIPATH/product_name)
UEVENT=$(cat $DMIPATH/uevent)

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
				[ "$SETUPWIZARD" = "0" ] && set_property ro.setupwizard.mode DISABLED
			fi
			;;
	esac
done

[ -n "$DEBUG" ] && set -x || exec &> /dev/null

# import the vendor specific script
hw_sh=/vendor/etc/init.sh
[ -e $hw_sh ] && source $hw_sh

case "$1" in
	eglsetup)
		init_egl
		;;
	netconsole)
		[ -n "$DEBUG" ] && do_netconsole
		;;
	bootcomplete)
		do_bootcomplete
		;;
	init|"")
		do_init
		;;
esac

return 0
