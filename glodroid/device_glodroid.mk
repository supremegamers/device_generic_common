# SPDX-License-Identifier: Apache-2.0
#
# GloDroid project (https://github.com/GloDroid)
#
# Copyright (C) 2022 Roman Stratiienko (r.stratiienko@gmail.com)

#External USB Camera HAL
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.5-external-service \

#PRODUCT_COPY_FILES += \
#    $(LOCAL_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

#Camera HAL
ifeq ($(BOARD_BUILD_AOSPEXT_LIBCAMERA),true)
PRODUCT_PACKAGES += \
    ipa_ipu3.so ipa_ipu3.so.sign \
    camera.libcamera libcamera libcamera-base libcamera-cam lc-compliance \
    android.hardware.camera.provider@2.5-service_64 libdav1d dav1d \

PRODUCT_PROPERTY_OVERRIDES += ro.hardware.camera=libcamera
endif

PRODUCT_COPY_FILES +=  \
    frameworks/native/data/etc/android.hardware.camera.concurrent.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.concurrent.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.camera.external.xml \
