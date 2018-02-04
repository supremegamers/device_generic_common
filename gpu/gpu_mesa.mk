#
# Copyright (C) 2011-2017 The Android-x86 Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

PRODUCT_PACKAGES := \
    hwcomposer.drm  \
    gralloc.drm     \
    gralloc.gbm     \
    libGLES_mesa    \
    libtxc_dxtn     \

PRODUCT_PACKAGES += \
    libEGL_swiftshader \
    libGLESv1_CM_swiftshader \
    libGLESv2_swiftshader \
    vulkan.android-x86

PRODUCT_PROPERTY_OVERRIDES := \
    ro.opengles.version = 196608 \
    ro.hardware.vulkan.level = 1 \
    ro.hardware.vulkan.version = 4194307

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:system/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_0_3.xml:system/etc/permissions/android.hardware.vulkan.version.xml
