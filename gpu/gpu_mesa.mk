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
    hwcomposer.drm hwcomposer.drm_minigbm hwcomposer.drm_celadon hwcomposer.drm_minigbm_celadon \
    hwcomposer.drm_gbm_cros hwcomposer.drm_gbm_cros_celadon \
    gralloc.minigbm_dmabuf gralloc.minigbm gralloc.minigbm_arcvm gralloc.minigbm_gbm_mesa \
    gralloc.gbm gralloc.gbm_hack gralloc.gbm_noscanout \
    libGLES_mesa    \
    libtxc_dxtn     \
    modetest \
    vulkan.intel \
    vulkan.intel_hasvk \
    vulkan.radeon \
    vulkan.virtio \
    libEGL_angle \
    libGLESv1_CM_angle \
    libGLESv2_angle \
    libEGL_swiftshader \
    libGLESv2_swiftshader \
    vulkan.pastel \
    vulkan.pastel_legacy \

PRODUCT_PACKAGES += \
    libEGL_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    libglapi \
    libgbm_mesa_wrapper \
    i965_drv_video \
    crocus_drv_video \
    iHD_drv_video \
    libgallium_drv_video \
    vainfo \
    amdgpu.ids

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
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml
