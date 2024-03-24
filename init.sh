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

	#Set CPU name into a property
	setprop ro.bliss.cpuname "$(grep "model name" /proc/cpuinfo | sort -u | cut -d : -f 2 | cut -c2-)"

	# Tell vold to use ntfs3 driver instead of ntfs-3g
    if [ "$USE_NTFS3" -ge "1" ] || [ "$VOLD_USE_NTFS3" -ge 1 ]; then
        set_property ro.vold.use_ntfs3 true
    fi
}

function init_hal_audio()
{
	## HACK: if snd_hda_intel cannot be probed, reprobe it
	if [ "$( lsmod | grep "snd_hda_intel" )" ]; then	
		if [ "$( dmesg | grep "couldn't bind with audio component" )" ]; then
		rmmod snd_hda_intel
		modprobe snd_hda_intel
		fi
	fi

	case "$PRODUCT" in
		VirtualBox*|Bochs*)
			[ -d /proc/asound/card0 ] || modprobe snd-sb16 isapnp=0 irq=5
			;;
		TS10*)
			set_prop_if_empty hal.audio.out pcmC0D2p
			;;
	esac

	case "$(ls /proc/asound)" in
		*sofhdadsp*)
			AUDIO_PRIMARY=x86_celadon
			;;
	esac
	set_property ro.hardware.audio.primary ${AUDIO_PRIMARY:-x86}

	if [ "$BOARD" == "Jupiter" ] && [ "$VENDOR" == "Valve" ]
	then
		pcm_card=$(cat /proc/asound/cards | grep acp5x | awk '{print $1}')
		# headset microphone on d0, 32bit only
		set_property hal.audio.in.headset "pcmC${pcm_card}D0c"
		set_property hal.audio.in.headset.format 1

		# internal microphone on d0, 32bit only
		set_property hal.audio.in.mic "pcmC${pcm_card}D0c"
		set_property hal.audio.in.mic.format 1

		# headphone jack on d0, 32bit only
		set_property hal.audio.out.headphone "pcmC${pcm_card}D0p"
		set_property hal.audio.out.headphone.format 1

		# speaker on d1, 16bit only
		set_property hal.audio.out.speaker "pcmC${pcm_card}D1p"
		set_property hal.audio.out.speaker.format 0

		# enable hdmi audio on the 3rd output, but it really depends on how docks wire things
		# to make matters worse, jack detection on alsa does not seem to always work on my setup, so a dedicated hdmi hal might want to send data to all ports instead of just probing
		pcm_card=$(cat /proc/asound/cards | grep HDA-Intel | awk '{print $1}')
		set_property hal.audio.out.hdmi "pcmC${pcm_card}D8p"
	fi
}

function init_hal_audio_bootcomplete()
{
	if [ "$BOARD" == "Jupiter" ] && [ "$VENDOR" == "Valve" ]
	then
		alsaucm -c Valve-Jupiter-1 set _verb HiFi

		pcm_card=$(cat /proc/asound/cards | grep acp5x | awk '{print $1}')
		# headset microphone on d0, 32bit only
		amixer -c ${pcm_card} sset 'Headset Mic',0 on

		# internal microphone on d0, 32bit only
		amixer -c ${pcm_card} sset 'Int Mic',0 on
		amixer -c ${pcm_card} sset 'DMIC Enable',0 on

		# headphone jack on d0, 32bit only
		amixer -c ${pcm_card} sset 'Headphone',0 on

		# speaker on d1, 16bit only
		amixer -c ${pcm_card} sset 'Left DSP RX1 Source',0 ASPRX1
		amixer -c ${pcm_card} sset 'Right DSP RX1 Source',0 ASPRX2
		amixer -c ${pcm_card} sset 'Left DSP RX2 Source',0 ASPRX1
		amixer -c ${pcm_card} sset 'Right DSP RX2 Source',0 ASPRX2
		amixer -c ${pcm_card} sset 'Left DSP1 Preload',0 on
		amixer -c ${pcm_card} sset 'Right DSP1 Preload',0 on

		# unmute them all
		amixer -c ${pcm_card} sset 'IEC958',0 on
		amixer -c ${pcm_card} sset 'IEC958',1 on
		amixer -c ${pcm_card} sset 'IEC958',2 on
		amixer -c ${pcm_card} sset 'IEC958',3 on
	fi

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
			alsa_amixer -c $c set Speaker on
			alsa_amixer -c $c set Speaker 100%
			alsa_amixer -c $c set Capture 80%
			alsa_amixer -c $c set Capture cap
			alsa_amixer -c $c set PCM 100% unmute
			alsa_amixer -c $c set SPO unmute
			alsa_amixer -c $c set IEC958 on
			alsa_amixer -c $c set 'Mic Boost' 1
			alsa_amixer -c $c set 'Internal Mic Boost' 1
		fi
		d=/data/vendor/alsa/$(cat /proc/asound/card$c/id).state
		if [ -e $d ]; then
			alsa_ctl -f $d restore $c
		fi
	done
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

	if [ "$BTLINUX_HAL" = "1" ]; then
		start btlinux-1.1
	else
		start vendor.bluetooth-1-1
	fi

	if [ "$BT_BLE_DISABLE" = "1" ]; then
		set_property bluetooth.core.le.disabled true
		set_property bluetooth.hci.disabled_commands 246
	fi

	if [ "$BT_BLE_NO_VENDORCAPS" = "1" ]; then
		set_property bluetooth.core.le.vendor_capabilities.enabled false
		set_property persist.sys.bt.max_vendor_cap 0
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
		*virtio_gpu|*virtio-pci)
			HWC=${HWC:-drm_minigbm_celadon}
			GRALLOC=${GRALLOC:-minigbm_arcvm}
			#video=${video:-1280x768}
			;&
		*nouveau)
			GRALLOC=${GRALLOC:-gbm_hack}
			HWC=${HWC:-drm_celadon}
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
				${HWC:+set_property ro.hardware.hwcomposer $HWC}
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
		if [ "$HWC" = "default" ]; then
			if [ "$HWC_IS_DRMFB" = "1" ]; then
				set_property debug.sf.hwc_service_name drmfb
				start vendor.hwcomposer-2-1.drmfb
			else
				set_property debug.sf.hwc_service_name default
				start vendor.hwcomposer-2-1
			fi
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

	if [ "$BOARD" == "Jupiter" ] && [ "$VENDOR" == "Valve" ]
	then
		FFMPEG_CODEC2_PREFER=${FFMPEG_CODEC2_PREFER:-1}
	fi

#FFMPEG Codec Setup
## Turn on/off FFMPEG OMX by default
	if [ "$FFMPEG_OMX_CODEC" -ge "1" ]; then
	    set_property media.sf.omx-plugin libffmpeg_omx.so
    	set_property media.sf.extractor-plugin libffmpeg_extractor.so
	else
	    set_property media.sf.omx-plugin ""
    	set_property media.sf.extractor-plugin ""
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
			set_property ro.hardware.vulkan amd
			;;
		*virtio_gpu|*virtio-pci)
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
			SLEEP_STATE=none
			;;
		e-tab*Pro)
			SLEEP_STATE=force
			;;
		*)
			;;
	esac

	set_property sleep.state ${SLEEP_STATE}
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
            *TECLAST*X4*|*SF133AYR110*)
                set_property ro.iio.accel.order 102
                set_property ro.iio.accel.x.opt_scale -1
                set_property ro.iio.accel.y.opt_scale -1
                ;;
			*TAIFAElimuTab*)
				set_property ro.ignore_atkbd 1
				set_property ro.iio.accel.quirks no-trig
				set_property ro.iio.accel.order 102
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

            # is steam deck?
            if [ "$BOARD" == "Jupiter" ] && [ "$VENDOR" == "Valve" ]
            then
                set_property poweroff.disable_virtual_power_button 1
                hal_sensors=jupiter
                has_sensors=true
            fi
    fi

    set_property ro.iio.accel.quirks "no-trig,no-event"
    set_property ro.iio.anglvel.quirks "no-trig,no-event"
    set_property ro.iio.magn.quirks "no-trig,no-event"
    set_property ro.hardware.sensors $hal_sensors
    set_property config.override_forced_orient ${HAS_SENSORS:-$has_sensors}
}

function init_hal_surface()
{
	case "$UEVENT" in
		*Surface*Pro*[4-9]*|*Surface*Book*|*Surface*Laptop*[1~4]*|*Surface*Laptop*Studio*)
			start iptsd_runner
			;;
	esac
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
	set_property ro.radio.noril yes
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

function set_custom_ota()
{
	for c in `cat /proc/cmdline`; do
		case $c in
			*=*)
				eval $c
				if [ -z "$1" ]; then
					case $c in
						# Set TimeZone
						SET_CUSTOM_OTA_URI=*)
							setprop bliss.updater.uri "$SET_CUSTOM_OTA_URI"
							;;
					esac
				fi
				;;
		esac
	done
	
}

function init_loop_links()
{
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
}

function init_prepare_ota()
{
	# If there's slot set, turn on bootctrl
	# If not, disable the OTA app (in bootcomplete)
	if [ "$(getprop ro.boot.slot_suffix)" ]; then
		start vendor.boot-hal-1-2
	fi
}

function set_custom_timezone()
{
	for c in `cat /proc/cmdline`; do
		case $c in
			*=*)
				eval $c
				if [ -z "$1" ]; then
					case $c in
						# Set TimeZone
						SET_TZ_LOCATION=*)
							settings put global time_zone "$SET_TZ_LOCATION"
							setprop persist.sys.timezone "$SET_TZ_LOCATION"
							;;
					esac
				fi
				;;
		esac
	done
	
}

function do_init()
{
	init_misc
	set_lowmem
	set_custom_timezone
	init_hal_audio
	set_custom_ota
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
	init_hal_surface
	init_tscal
	init_ril
	init_loop_links
	init_prepare_ota
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

	# initialize audio in bootcomplete
	init_hal_audio_bootcomplete

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

	if [ ! "$(getprop ro.boot.slot_suffix)" ]; then
		pm disable org.lineageos.updater
	fi

	post_bootcomplete
}

PATH=/sbin:/system/bin:/system/xbin

DMIPATH=/sys/class/dmi/id
BOARD=$(cat $DMIPATH/board_name)
PRODUCT=$(cat $DMIPATH/product_name)
VENDOR=$(cat $DMIPATH/sys_vendor)
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
					SET_SF_ROTATION=*)
						set_property ro.sf.hwrotation "$SET_SF_ROTATION"
						;;
					SET_OVERRIDE_FORCED_ORIENT=*)
						set_property config.override_forced_orient "$SET_OVERRIDE_FORCED_ORIENT"
						;;
					SET_SYS_APP_ROTATION=*)
						# property: persist.sys.app.rotation has three cases:
						# 1.force_land: always show with landscape, if a portrait apk, system will scale up it
						# 2.middle_port: if a portrait apk, will show in the middle of the screen, left and right will show black
						# 3.original: original orientation, if a portrait apk, will rotate 270 degree
						set_property persist.sys.app.rotation "$SET_SYS_APP_ROTATION"
						;;
					# Battery Stats
					SET_FAKE_BATTERY_LEVEL=*)
						# Let us fake the total battery percentage
						# Range: 0-100
						dumpsys battery set level "$SET_FAKE_BATTERY_LEVEL"
						;;
					SET_FAKE_CHARGING_STATUS=*)
						# Allow forcing battery charging status
						# Off: 0  On: 1
						dumpsys battery set ac "$SET_FAKE_CHARGING_STATUS"
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
