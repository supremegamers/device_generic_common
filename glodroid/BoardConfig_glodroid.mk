# SPDX-License-Identifier: Apache-2.0
#
# GloDroid project (https://github.com/GloDroid)
#
# Copyright (C) 2022 Roman Stratiienko (r.stratiienko@gmail.com)

BCC_PATH := $(patsubst $(CURDIR)/%,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

BOARD_BUILD_AOSPEXT_LIBCAMERA := true
BOARD_LIBCAMERA_SRC_DIR := glodroid/libcamera
BOARD_LIBCAMERA_IPAS := ipu3
BOARD_LIBCAMERA_PIPELINES := uvcvideo ipu3
BOARD_BUILD_AOSPEXT_MESA3D := true
BOARD_MESA3D_SRC_DIR := external/mesa
BOARD_MESA3D_GALLIUM_VA := enabled
BOARD_MESA3D_GALLIUM_VA_CODECS := h264dec h264enc h265dec h265enc vc1dec
BOARD_BUILD_AOSPEXT_DAV1D := true
BOARD_DAV1D_SRC_DIR := glodroid/dav1d

BOARD_LIBCAMERA_EXTRA_TARGETS := \
    libetc:libcamera/ipa_ipu3.so:libcamera:ipa_ipu3.so:           \
    libetc:libcamera/ipa_ipu3.so.sign:libcamera:ipa_ipu3.so.sign: \
