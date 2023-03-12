#
# Copyright (C) 2014-2016 The Android-x86 Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_DIR := $(dir $(lastword $(filter-out device/common/%,$(filter device/%,$(ALL_PRODUCTS)))))

PRODUCT_PROPERTY_OVERRIDES := \
    ro.ril.hsxpa=1 \
    ro.ril.gprsclass=10 \
    keyguard.no_require_sim=true \
    ro.com.android.dataroaming=true \
    ro.lmk.kill_timeout_ms=100 \
    ro.arch=x86 \
    persist.rtc_local_time=1 \
    bluetooth.rfkill=1 \
    dalvik.vm.useautofastjni=true \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3

# LMKd
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lmk.critical_upgrade=true \
    ro.lmk.use_minfree_levels=true \
    ro.lmk.use_psi=true \
    ro.lmk.use_new_strategy=false

PRODUCT_COPY_FILES := \
    $(if $(wildcard $(PRODUCT_DIR)init.rc),$(PRODUCT_DIR)init.rc:root/init.rc) \
    $(if $(wildcard $(PRODUCT_DIR)init.sh),$(PRODUCT_DIR),$(LOCAL_PATH)/)init.sh:system/etc/init.sh \
    $(if $(wildcard $(PRODUCT_DIR)modules.blocklist),$(PRODUCT_DIR),$(LOCAL_PATH)/)modules.blocklist:system/etc/modules.blocklist \
    $(if $(wildcard $(PRODUCT_DIR)modules.options),$(PRODUCT_DIR),$(LOCAL_PATH)/)modules.options:system/etc/modules.options \
    $(if $(wildcard $(PRODUCT_DIR)fstab.$(TARGET_PRODUCT)),$(PRODUCT_DIR)fstab.$(TARGET_PRODUCT),$(LOCAL_PATH)/fstab.x86):root/fstab.$(TARGET_PRODUCT) \
    $(if $(wildcard $(PRODUCT_DIR)wpa_supplicant.conf),$(PRODUCT_DIR),$(LOCAL_PATH)/)wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(if $(wildcard $(PRODUCT_DIR)wpa_supplicant_overlay.conf),$(PRODUCT_DIR),$(LOCAL_PATH)/)wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(if $(wildcard $(PRODUCT_DIR)excluded-input-devices.xml),$(PRODUCT_DIR),$(LOCAL_PATH)/)excluded-input-devices.xml:system/etc/excluded-input-devices.xml \
    $(if $(wildcard $(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/init.x86.rc):root/init.$(TARGET_PRODUCT).rc \
    $(if $(wildcard $(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/ueventd.x86.rc):$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/ppp/ip-up:system/etc/ppp/ip-up \
    $(LOCAL_PATH)/ppp/ip-down:system/etc/ppp/ip-down \
    $(LOCAL_PATH)/ppp/peers/gprs:system/etc/ppp/peers/gprs \
    $(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
    $(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml \
    $(LOCAL_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml \
    $(LOCAL_PATH)/pciids/pci.ids:system/vendor/etc/pci.ids \
    $(LOCAL_PATH)/usbids/usb.ids:system/vendor/etc/usb.ids \
    $(LOCAL_PATH)/fstab.internal.x86:system/vendor/etc/fstab.internal.x86 \
    $(LOCAL_PATH)/init.configfs_x86.rc:root/init.configfs_x86.rc \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:system/etc/media_codecs_google_c2.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:system/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:system/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:system/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:system/etc/permissions/android.hardware.camera.external.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:system/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.gamepad.xml:system/etc/permissions/android.hardware.gamepad.xml \
    frameworks/native/data/etc/android.hardware.location.xml:system/etc/permissions/android.hardware.location.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:system/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:system/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:system/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.connectionservice.xml:system/etc/permissions/android.software.connectionservice.xml \
    frameworks/native/data/etc/android.software.controls.xml:system/etc/permissions/android.software.controls.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:system/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:system/etc/permissions/android.software.freeform_window_management.xml \
    frameworks/native/data/etc/android.software.midi.xml:system/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:system/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.software.print.xml:system/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.autofill.xml:system/etc/permissions/android.software.autofill.xml \
    frameworks/native/data/etc/android.software.sip.xml:system/etc/permissions/android.software.sip.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:system/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.webview.xml:system/etc/permissions/android.software.webview.xml \
    external/thermal_daemon/data/thermal-conf.xml:/system/vendor/etc/thermal-daemon/thermal-conf.xml \
    external/thermal_daemon/data/thermal-cpu-cdev-order.xml:/system/vendor/etc/thermal-daemon/thermal-cpu-cdev-order.xml \
    external/mesa/src/util/00-mesa-defaults.conf:system/etc/drirc \
    $(LOCAL_PATH)/OEMBlackList:$(TARGET_COPY_OUT_VENDOR)/etc/misc/.OEMBlackList \
    $(LOCAL_PATH)/OEMWhiteList:$(TARGET_COPY_OUT_VENDOR)/etc/misc/.OEMWhiteList \
    $(LOCAL_PATH)/ThirdPartySO:$(TARGET_COPY_OUT_VENDOR)/etc/misc/.ThirdPartySO \
    $(LOCAL_PATH)/seccomp/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy \
    $(foreach f,$(wildcard $(LOCAL_PATH)/alsa/*),$(f):$(subst $(LOCAL_PATH),system/etc,$(f))) \
    $(foreach f,$(wildcard $(LOCAL_PATH)/idc/*.idc $(LOCAL_PATH)/keylayout/*.kl),$(f):$(subst $(LOCAL_PATH),system/usr,$(f)))

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_ENFORCE_VINTF_MANIFEST_OVERRIDE := true
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG := normal large xlarge mdpi hdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.sys.sdcardfs=false \
    persist.sys.sdcardfs=force_off

# Copy any Permissions files, overriding anything if needed
$(foreach f,$(wildcard $(LOCAL_PATH)/permissions/*.xml),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/$(notdir $f)))

$(foreach f,$(wildcard $(LOCAL_PATH)/permissions_product/*.xml),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/$(notdir $f)))

# Get emulated storage settings
#$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Get Android 8.0 HIDL HALs
$(call inherit-product,$(LOCAL_PATH)/treble.mk)

# Get the touchscreen calibration tool
$(call inherit-product-if-exists,external/tslib/tslib.mk)

# Get the alsa files
$(call inherit-product-if-exists,hardware/libaudio/alsa.mk)

# Get GPS configuration
$(call inherit-product-if-exists,device/common/gps/gps_as.mk)

# Get the hardware acceleration libraries
$(call inherit-product-if-exists,$(LOCAL_PATH)/gpu/gpu_mesa.mk)

# Get the sensors hals
$(call inherit-product-if-exists,hardware/libsensors/sensors.mk)

# Get tablet dalvik parameters
$(call inherit-product,frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

ifeq ($(USE_LIBNDK_TRANSLATION_NB),true)
$(call inherit-product-if-exists, vendor/google/emu-x86/target/libndk_translation.mk)
$(call inherit-product-if-exists, vendor/google/emu-x86/target/native_bridge_arm_on_x86.mk)
NDK_TRANSLATION_PREINSTALL := google
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.nativebridge=1
endif

ifeq ($(USE_CROS_HOUDINI_NB),true)
$(call inherit-product-if-exists, vendor/google/chromeos-x86/target/houdini.mk)
$(call inherit-product-if-exists, vendor/google/chromeos-x86/target/native_bridge_arm_on_x86.mk)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.nativebridge=1
endif

ifeq ($(ANDROID_USE_NDK_TRANSLATION),true)
$(call inherit-product-if-exists, vendor/google/proprietary/ndk_translation-prebuilt/libndk_translation.mk)
$(call inherit-product-if-exists, vendor/google/proprietary/ndk_translation-prebuilt/native_bridge_arm_on_x86.mk)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.nativebridge=1
endif

ifeq ($(ANDROID_USE_INTEL_HOUDINI),true)
$(call inherit-product-if-exists, vendor/intel/proprietary/houdini/houdini.mk)
$(call inherit-product-if-exists, vendor/intel/proprietary/houdini/native_bridge_arm_on_x86.mk)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.nativebridge=1
endif

$(call inherit-product,$(if $(wildcard $(PRODUCT_DIR)packages.mk),$(PRODUCT_DIR),$(LOCAL_PATH)/)packages.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/handheld_vendor.mk)

# Inherit common LMODroid stuff
$(call inherit-product-if-exists,vendor/lmodroid/config/common_full_tablet_wifionly.mk)
TARGET_FACE_UNLOCK_SUPPORTED := false
TARGET_WANTS_FOD_ANIMATIONS := false
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true
##CHOOSE THE BUILD YOU WANT HERE, FOSS OR OPENGAPPS
#BLISS_BUILD_VARIANT := foss
WITH_SU := false

# Widevine addons
ifeq ($(USE_LIBNDK_TRANSLATION_NB),true)
$(call inherit-product-if-exists, vendor/google/emu-x86/target/widevine.mk)
endif

ifeq ($(USE_WIDEVINE),true)
$(call inherit-product-if-exists, vendor/google/chromeos-x86/target/widevine.mk)
$(call inherit-product-if-exists, vendor/google/proprietary/widevine-prebuilt/widevine.mk)
endif

ifeq ($(USE_EMU_GAPPS),true)

$(call inherit-product-if-exists, vendor/google/emu-x86/target/gapps.mk)

endif

ifeq ($(USE_OPENGAPPS),true)

$(call inherit-product-if-exists, vendor/opengapps/gapps.mk)

endif

ifeq ($(ANDROID_INTEGRATE_MAGISK),true)
$(call inherit-product-if-exists, vendor/supremegamers/kokoro/kokoro.mk)
endif

# Add agp-apps
$(call inherit-product-if-exists, vendor/prebuilts/agp-apps/agp-apps.mk)

# Add SettingsIntelligenceGooglePrebuilt
$(call inherit-product-if-exists, vendor/google/proprietary/SettingsIntelligenceGooglePrebuilt/sigp.mk)

# Boringdroid
$(call inherit-product-if-exists, vendor/boringdroid/boringdroid.mk)

# Enable MultiWindow
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.debug.multi_window=true
    persist.sys.debug.desktop_mode=true

# DRM service opt-in
PRODUCT_VENDOR_PROPERTIES += drm.service.enabled=true

PRODUCT_SHIPPING_API_LEVEL := 24
DISABLE_RILD_OEM_HOOK := true
PRODUCT_REQUIRES_INSECURE_EXECMEM_FOR_SWIFTSHADER := true

