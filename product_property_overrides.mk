# Dolby audio
PRODUCT_PROPERTY_OVERRIDES += \
    ro.platform.support.dts=true \
    ro.platform.support.dolby=true

# Default OMX service to non-Treble
PRODUCT_PROPERTY_OVERRIDES += \
    persist.media.treble_omx=false

# Some CTS tests will be skipped based on what the initial API level that
# shipped on device was.
#PRODUCT_PROPERTY_OVERRIDES += \
# ro.product.first_api_level=21