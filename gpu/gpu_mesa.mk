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
    gralloc.gbm gralloc.minigbm gralloc.minigbm_arcvm gralloc.minigbm_gbm_mesa \
    gralloc.minigbm_dmabuf \
	hwcomposer.cutf_cvm_ashmem hwcomposer.cutf_hwc2 hwcomposer-stats \
    libGLES_mesa    \
    libtxc_dxtn     \
    modetest \
    vulkan.intel \
    vulkan.radeon \
    vulkan.virtio \
    libEGL_angle \
    libGLESv1_CM_angle \
    libGLESv2_angle \
    libEGL_swiftshader \
    libGLESv1_CM_swiftshader \
    libGLESv2_swiftshader \
    vulkan.ranchu \
    libvulkan_enc \
    vulkan.pastel \
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

PRODUCT_PACKAGES += \
    libEGL_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    libglapi

PRODUCT_PROPERTY_OVERRIDES := \
    ro.opengles.version = 196608

PRODUCT_VENDOR_PROPERTIES += \
    debug.angle.feature_overrides_enabled=preferLinearFilterForYUV

# ANGLE provides an OpenGL implementation built on top of Vulkan.
#PRODUCT_PACKAGES += \


# GL/Vk implementation for gfxstream
#PRODUCT_PACKAGES += \


PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:system/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml
    
