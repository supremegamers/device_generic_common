# Graphics HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.graphics.mapper@4.0-impl.minigbm \
    android.hardware.graphics.mapper@4.0-impl.minigbm_arcvm\
    android.hardware.graphics.mapper@4.0-impl.minigbm_gbm_mesa \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.allocator@4.0-service.minigbm \
    android.hardware.graphics.allocator@4.0-service.minigbm_arcvm \
    android.hardware.graphics.allocator@4.0-service.minigbm_gbm_mesa

# HWComposer HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.4-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.composer@2.4-service \
    android.hardware.graphics.composer@2.1-drmfb-service

# Audio HAL
PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.soundtrigger@2.3-impl

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service.vbt \
    android.hardware.bluetooth.audio@2.1-impl \
#    android.hardware.bluetooth@1.1-service.btlinux \


# Camera HAL
PRODUCT_PACKAGES += \
    camera.x86

# Media codec
PRODUCT_PACKAGES += \
    android.hardware.media.c2@1.1-service \
    android.hardware.media.c2@1.2-ffmpeg-service \
    android.hardware.media.omx@1.0-service

# DumpState HAL
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.0-impl \
    android.hardware.dumpstate@1.0-service.example

# Gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.1-service

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
    power.x86 \
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
    android.hardware.drm@1.0-service-lazy \
    android.hardware.drm@1.4-service-lazy.clearkey

# GPS HAL
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# ConfigStore HAL
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service

# Thermal HAL
PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0-service.intel

# vndservicemanager
PRODUCT_PACKAGES += vndservicemanager
