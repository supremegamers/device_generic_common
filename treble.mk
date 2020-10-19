# Graphics HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.graphics.allocator@2.0-impl \

# HWComposer HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl

# Audio HAL
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.broadcastradio@1.0-impl \
    android.hardware.soundtrigger@2.0-impl

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service.btlinux

# Camera HAL
PRODUCT_PACKAGES += \
    camera.device@3.2-impl \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service

# Media codec
PRODUCT_PACKAGES += \
    android.hardware.media.c2@1.0-service \
    android.hardware.media.omx@1.0-service

# DumpState HAL
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.0-impl \
    android.hardware.dumpstate@1.0-service.example

# Gatekeeper HAL
#PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl

# Light HAL
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service

# Memtrack HAL
PRODUCT_PACKAGES += \
    memtrack.default \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service

# Power HAL
PRODUCT_PACKAGES += \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Sensors HAL
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl

# USB HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-impl \
    android.hardware.usb@1.0-service

# Drm HAL
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.3-service.clearkey

# GPS HAL
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# ConfigStore HAL
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service
