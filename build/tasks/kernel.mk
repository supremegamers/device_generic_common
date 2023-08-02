#
# Copyright (C) 2014-2019 The Android-x86 Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

TARGET_CLANG_PATH := prebuilts/clang/host/linux-x86/clang-r450784/bin

ifneq ($(TARGET_NO_KERNEL),true)

INSTALLED_KERNELIMAGE_TARGET := $(PRODUCT_OUT)/kernel.img

ifeq ($(TARGET_PREBUILT_KERNEL),)
ifneq ($(filter x86%,$(TARGET_ARCH)),)

KERNEL_DIR ?= kernel
FIRMWARE_DIR := device/generic/firmware
COPY_FIRMWARE_SCRIPT := $(FIRMWARE_DIR)/copy-firmware.sh

TARGET_KERNEL_ARCH := $(TARGET_ARCH)
KERNEL_TARGET := bzImage
TARGET_KERNEL_CONFIG ?= android-$(TARGET_KERNEL_ARCH)_defconfig
KERNEL_CONFIG_DIR := arch/x86/configs

ifeq ($(TARGET_KERNEL_ARCH),x86_64)
CROSS_COMPILE := $(abspath $(TARGET_TOOLS_PREFIX))
KERNEL_CLANG_FLAGS := \
        LLVM=1 \
        CC=$(abspath $(TARGET_CLANG_PATH)/clang) \
        LD=$(abspath $(TARGET_CLANG_PATH)/ld.lld) \
        AR=$(abspath $(TARGET_CLANG_PATH)/llvm-ar) \
        NM=$(abspath $(TARGET_CLANG_PATH)/llvm-nm) \
        OBJCOPY=$(abspath $(TARGET_CLANG_PATH)/llvm-objcopy) \
        OBJDUMP=$(abspath $(TARGET_CLANG_PATH)/llvm-objdump) \
        READELF=$(abspath $(TARGET_CLANG_PATH)/llvm-readelf) \
        OBJSIZE=$(abspath $(TARGET_CLANG_PATH)/llvm-size) \
        STRIP=$(abspath $(TARGET_CLANG_PATH)/llvm-strip) \
        HOSTCC=$(abspath $(TARGET_CLANG_PATH)/clang) \
        HOSTCXX=$(abspath $(TARGET_CLANG_PATH)/clang++) \
        HOSTLD=$(abspath $(TARGET_CLANG_PATH)/ld.lld) \
        HOSTLDFLAGS=-fuse-ld=lld \
        HOSTAR=$(abspath $(TARGET_CLANG_PATH)/llvm-ar)
else
$(error not implemented)
endif

KBUILD_OUTPUT := $(TARGET_OUT_INTERMEDIATES)/kernel
ifeq ($(HOST_OS),darwin)
KBUILD_JOBS := $(shell /usr/sbin/sysctl -n hw.ncpu)
else
KBUILD_JOBS := $(shell echo $$((1-(`cat /sys/devices/system/cpu/present`))))
endif

mk_kernel := + $(hide) prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/make -j$(KBUILD_JOBS) -l$$(($(KBUILD_JOBS)+2)) \
	-C $(KERNEL_DIR) O=$(abspath $(KBUILD_OUTPUT)) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
	YACC=$(abspath $(BISON)) LEX=$(abspath $(LEX)) M4=$(abspath $(M4)) DEPMOD=/sbin/depmod PERL=/usr/bin/perl \
	$(KERNEL_CLANG_FLAGS)

KERNEL_CONFIG_FILE := $(if $(wildcard $(TARGET_KERNEL_CONFIG)),$(TARGET_KERNEL_CONFIG),$(KERNEL_DIR)/$(KERNEL_CONFIG_DIR)/$(TARGET_KERNEL_CONFIG))

MOD_ENABLED := $(shell grep ^CONFIG_MODULES=y $(KERNEL_CONFIG_FILE))
FIRMWARE_ENABLED := $(shell grep ^CONFIG_FIRMWARE_IN_KERNEL=y $(KERNEL_CONFIG_FILE))

# I understand Android build system discourage to use submake,
# but I don't want to write a complex Android.mk to build kernel.
# This is the simplest way I can think.
KERNEL_DOTCONFIG_FILE := $(KBUILD_OUTPUT)/.config
ifneq ($(filter 0,$(shell grep -s ^$(if $(filter x86,$(TARGET_KERNEL_ARCH)),\#.)CONFIG_64BIT $(KERNEL_DOTCONFIG_FILE) | wc -l)),)
KERNEL_ARCH_CHANGED := $(KERNEL_DOTCONFIG_FILE)-
$(KERNEL_ARCH_CHANGED):
		@touch $@
endif
$(KERNEL_DOTCONFIG_FILE): $(KERNEL_CONFIG_FILE) $(wildcard $(TARGET_KERNEL_DIFFCONFIG)) $(KERNEL_ARCH_CHANGED)
	$(hide) mkdir -p $(@D) && cat $(wildcard $^) > $@
	$(hide) rm -f $(KERNEL_ARCH_CHANGED)

BUILT_KERNEL_TARGET := $(KBUILD_OUTPUT)/arch/$(TARGET_ARCH)/boot/$(KERNEL_TARGET)
$(BUILT_KERNEL_TARGET): $(KERNEL_DOTCONFIG_FILE) $(M4) $(LEX) $(BISON)
	# A dirty hack to use ar & ld
	$(mk_kernel) olddefconfig
	$(mk_kernel) $(KERNEL_TARGET) $(if $(MOD_ENABLED),modules)
	$(COPY_FIRMWARE_SCRIPT) -v $(abspath $(TARGET_OUT))/lib/firmware
	$(if $(FIRMWARE_ENABLED),$(mk_kernel) INSTALL_MOD_PATH=$(abspath $(TARGET_OUT)) firmware_install)
	$(hide) cp $@ $(INSTALLED_KERNELIMAGE_TARGET)

ifneq ($(MOD_ENABLED),)
KERNEL_MODULES_DEP := $(firstword $(wildcard $(TARGET_OUT)/lib/modules/*/modules.dep))
KERNEL_MODULES_DEP := $(if $(KERNEL_MODULES_DEP),$(KERNEL_MODULES_DEP),$(TARGET_OUT)/lib/modules)

ALL_EXTRA_MODULES := $(patsubst %,$(TARGET_OUT_INTERMEDIATES)/kmodule/%,$(TARGET_EXTRA_KERNEL_MODULES))
$(ALL_EXTRA_MODULES): $(TARGET_OUT_INTERMEDIATES)/kmodule/%: $(BUILT_KERNEL_TARGET) | $(ACP)
	@echo Building additional kernel module $*
	$(hide) mkdir -p $(@D) && $(ACP) -fr $(EXTRA_KERNEL_MODULE_PATH_$*) $(@D)
	$(mk_kernel) M=$(abspath $@) modules || ( rm -rf $@ && exit 1 )

$(KERNEL_MODULES_DEP): $(BUILT_KERNEL_TARGET) $(ALL_EXTRA_MODULES)
	$(hide) rm -rf $(TARGET_OUT)/lib/modules
	$(mk_kernel) INSTALL_MOD_PATH=$(abspath $(TARGET_OUT)) modules_install
	+ $(hide) for kmod in $(TARGET_EXTRA_KERNEL_MODULES) ; do \
		echo Installing additional kernel module $${kmod} ; \
		$(subst +,,$(subst $(hide),,$(mk_kernel))) INSTALL_MOD_PATH=$(abspath $(TARGET_OUT)) M=$(abspath $(TARGET_OUT_INTERMEDIATES))/kmodule/$${kmod} modules_install ; \
	done
	$(hide) rm -f $(TARGET_OUT)/lib/modules/*/{build,source}
endif

$(BUILT_SYSTEMIMAGE): $(KERNEL_MODULES_DEP)

installclean: FILES += $(KBUILD_OUTPUT) $(INSTALLED_KERNEL_TARGET)

TARGET_PREBUILT_KERNEL := $(BUILT_KERNEL_TARGET)

.PHONY: kernel
kernel: $(INSTALLED_KERNEL_TARGET) $(KERNEL_MODULES_DEP)

endif # TARGET_ARCH
endif # TARGET_PREBUILT_KERNEL

#ifndef LINEAGE_BUILD
$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(copy-file-to-new-target)
	$(hide) cp $@ $(INSTALLED_KERNELIMAGE_TARGET)
ifdef TARGET_PREBUILT_MODULES
	mkdir -p $(TARGET_OUT)/lib
	$(hide) cp -r $(TARGET_PREBUILT_MODULES) $(TARGET_OUT)/lib
endif
#endif # LINEAGE_BUILD

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_KERNELIMAGE_TARGET)

endif # TARGET_NO_KERNEL
