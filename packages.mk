#
# Copyright (C) 2014 The Android-x86 Open Source Project
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

# Common packages for Android-x86 platform.

PRODUCT_PACKAGES := \
    com.android.future.usb.accessory \
    drmserver \
    gps.default \
    gps.huawei \
    io_switch \
    lights.default \
    rtk_hciattach \
    scp \
    sftp \
    ssh \
    sshd \
    tablet-mode \
    v86d \
    wacom-input \

PRODUCT_PACKAGES += \
    libwpa_client \
    wificond \
    wpa_supplicant \

PRODUCT_PACKAGES += \
    badblocks \
    e2fsck \
    fsck.exfat \
    fsck.f2fs \
    mke2fs \
    make_f2fs \
    mkfs.exfat \
    resize2fs \
    tune2fs \

PRODUCT_PACKAGES += \
    btattach \
	btmon \
    hciconfig \
    hcitool \
    thermal-daemon \
    usb_otg_switch

# Stagefright FFMPEG plugins
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

# Third party apps
PRODUCT_PACKAGES += \
    TSCalibration2 \
    libnativebridge-headers \
    libnativeloader-headers \
    libandroidemu

PRODUCT_HOST_PACKAGES, += \
    libnativebridge \
    libnativeloader

# Debug tools
PRODUCT_PACKAGES_DEBUG := \
    avdtptest \
    avinfo \
    avtest \
    bneptest \
    btmgmt \
    btproxy \
    haltest \
    l2ping \
    l2test \
    mcaptest \
    rctest \

PRODUCT_HOST_PACKAGES := \
    qemu-android \

#
# Packages for AOSP-available stuff we use from the framework
#
PRODUCT_PACKAGES += \
    ip \
    tcpdump \
    libbt-vendor \
    iw \
    iw_vendor

## Enable hidden features on Android
PRODUCT_PACKAGES += \
	pc.xml \
	hpe.xml \
	device.prop
