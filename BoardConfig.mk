#
# BoardConfig.mk for x86 platform
#

TARGET_BOARD_PLATFORM := android-x86

## Use EROFS image or SquashFS
USE_SQUASHFS := 1
USE_EROFS := 0

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    system \
    initrd \
    kernel

# Rootfs
BOARD_ROOT_EXTRA_FOLDERS := grub

# Some framework code requires this to enable BT
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_LINUX := true
#BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/generic/common/bluetooth
BOARD_SEPOLICY_DIRS += system/bt/vendor_libs/linux/sepolicy

BOARD_USE_LEGACY_UI := true

# customize the malloced address to be 16-byte aligned
BOARD_MALLOC_ALIGNMENT := 16

# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
WITH_DEXPREOPT := true
WITH_DEXPREOPT_PIC := true
endif

# the following variables could be overridden
TARGET_PRELINK_MODULE := false
TARGET_NO_KERNEL ?= false
TARGET_NO_RECOVERY ?= true
TARGET_EXTRA_KERNEL_MODULES := tp_smapi
ifneq ($(filter efi_img,$(MAKECMDGOALS)),)
TARGET_KERNEL_ARCH ?= x86_64
endif
TARGET_USES_64_BIT_BINDER := true

BOARD_USES_GENERIC_AUDIO ?= false
BOARD_USES_ALSA_AUDIO ?= true
BUILD_WITH_ALSA_UTILS ?= true
BOARD_HAS_GPS_HARDWARE ?= true

# Don't build emulator
BUILD_EMULATOR ?= false
BUILD_STANDALONE_EMULATOR ?= false
BUILD_EMULATOR_QEMUD ?= false
BUILD_EMULATOR_OPENGL ?= false
BUILD_EMULATOR_OPENGL_DRIVER ?= false
BUILD_EMULATOR_QEMU_PROPS ?= false
BUILD_EMULATOR_CAMERA_HAL ?= false
BUILD_EMULATOR_GPS_MODULE ?= false
BUILD_EMULATOR_LIGHTS_MODULE ?= false
BUILD_EMULATOR_SENSORS_MODULE ?= false

BUILD_ARM_FOR_X86 := $(WITH_NATIVE_BRIDGE)

BOARD_USE_LIBVA_INTEL_DRIVER := true
BOARD_USE_LIBVA := true
BOARD_USE_LIBMIX := true
BOARD_USES_WRS_OMXIL_CORE := true
USE_INTEL_OMX_COMPONENTS := true

USE_OPENGL_RENDERER := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS ?= 3
BOARD_USES_DRM_GRALLOC := false
BOARD_USES_DRM_HWCOMPOSER ?= true

BOARD_USES_MINIGBM := true
BOARD_USES_MINIGBM_INTEL := true
BOARD_USES_GRALLOC1 := true
BOARD_USES_IA_HWCOMPOSER := true
TARGET_USES_HWC2 ?= true
#BOARD_USES_VULKAN := true

USE_CAMERA_STUB ?= false

# This enables the wpa wireless driver
BOARD_WPA_SUPPLICANT_DRIVER ?= NL80211
WPA_SUPPLICANT_VERSION ?= VER_2_1_DEVEL

BOARD_GPU_DRIVERS ?= crocus i915 iris freedreno panfrost nouveau r300g r600g radeonsi virgl vmwgfx
ifneq ($(strip $(BOARD_GPU_DRIVERS)),)
TARGET_HARDWARE_3D := true
endif

BOARD_MESA3D_USES_MESON_BUILD := true
#BOARD_MESA3D_CLASSIC_DRIVERS := i965
BOARD_MESA3D_BUILD_LIBGBM := true
BOARD_MESA3D_GALLIUM_DRIVERS := crocus iris i915 nouveau r600 radeonsi svga virgl zink
BOARD_MESA3D_VULKAN_DRIVERS := amd intel intel_hasvk virtio-experimental
BUILD_EMULATOR_OPENGL := true

BOARD_KERNEL_CMDLINE := root=/dev/ram0$(if $(filter x86_64,$(TARGET_ARCH) $(TARGET_KERNEL_ARCH)),, vmalloc=192M)
TARGET_KERNEL_DIFFCONFIG := device/generic/common/selinux_diffconfig

COMPATIBILITY_ENHANCEMENT_PACKAGE := true
PRC_COMPATIBILITY_PACKAGE := true
ZIP_OPTIMIZATION_NO_INTEGRITY := true

DEVICE_MANIFEST_FILE := device/generic/common/manifest.xml

#BOARD_SEPOLICY_DIRS += device/generic/common/sepolicy/nonplat \
#                       system/bt/vendor_libs/linux/sepolicy \
#                       device/generic/common/sepolicy/celadon/graphics/mesa \
#                       device/generic/common/sepolicy/celadon/thermal \
#                       vendor/intel/proprietary/houdini/sepolicy \
#                       vendor/google/proprietary/widevine-prebuilt/sepolicy
#
#BOARD_PLAT_PRIVATE_SEPOLICY_DIR := device/generic/common/sepolicy/plat_private

BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 42000000
BOARD_USES_OEMIMAGE := true
BUILD_BROKEN_USES_NETWORK := true
USE_XML_AUDIO_POLICY_CONF := 1

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_USES_BUILD_HOST_EXECUTABLE := true
BUILD_BROKEN_USES_BUILD_HOST_STATIC_LIBRARY := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

#ifeq ($(ANDROID_USE_INTEL_HOUDINI),true)
#include vendor/intel/proprietary/houdini/board/native_bridge_arm_on_x86.mk
#endif

STAGEFRIGHT_AVCENC_CFLAGS := -DANDROID_GCE

# Properties
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
TARGET_VENDOR_PROP += device/generic/common/props/vendor.prop
TARGET_SYSTEM_PROP += device/generic/common/system.prop

