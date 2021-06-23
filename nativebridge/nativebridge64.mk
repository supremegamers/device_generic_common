#
# Copyright (C) 2021 The Android-x86 Open Source Project
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

NATIVE_BRIDGE_ABI_LIST_64_BIT := arm64-v8a
NATIVE_BRIDGE_ABI_LIST := x86_64 x86 arm64-v8a armeabi-v7a armeabi
TARGET_CPU_ABI_LIST := x86_64 x86 arm64-v8a armeabi-v7a armeabi

PRODUCT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.isa.arm64=x86_64 \
    ro.enable.native.bridge.exec64=1


