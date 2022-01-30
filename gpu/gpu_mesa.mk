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
    hwcomposer.drm hwcomposer.drm_minigbm hwcomposer.intel \
    gralloc.gbm gralloc.minigbm gralloc.minigbm_intel gralloc.minigbm_arcvm gralloc.minigbm_gbm_mesa \
    libGLES_mesa    \
    libtxc_dxtn     \
    modetest
    
PRODUCT_PACKAGES += \
    libEGL_swiftshader \
    libGLESv1_CM_swiftshader \
    libGLESv2_swiftshader \
    vulkan.intel \
    vulkan.radeon \
    vulkan.virtio \
    vulkan.lvp

PRODUCT_PACKAGES += \
    libEGL_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    libglapi

PRODUCT_PROPERTY_OVERRIDES := \
    ro.opengles.version = 196608 \
    ro.hardware.vulkan.level = 1 \
    ro.hardware.vulkan.version = 4198400 \
    ro.hardware.egl=mesa

# ANGLE provides an OpenGL implementation built on top of Vulkan.
PRODUCT_PACKAGES += \
    libEGL_angle \
    libGLESv1_CM_angle \
    libGLESv2_angle \
    libfeature_support_angle.so

#
# Packages for the Vulkan implementation
#
ifeq ($(TARGET_VULKAN_SUPPORT),true)
PRODUCT_PACKAGES += \
    vulkan.ranchu \
    libvulkan_enc \
    vulkan.pastel
endif

# GL/Vk implementation for gfxstream
PRODUCT_PACKAGES += \
    hwcomposer.ranchu \
    libandroidemu \
    libOpenglCodecCommon \
    libOpenglSystemCommon \
    libGLESv1_CM_emulation \
    lib_renderControl_enc \
    libEGL_emulation \
    libGLESv2_enc \
    libGLESv2_emulation \
    libGLESv1_enc

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:system/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:system/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:system/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:system/etc/permissions/android.hardware.vulkan.version.xml

