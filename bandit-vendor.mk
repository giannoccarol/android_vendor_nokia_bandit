#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Nokia Lumia 1520 (bandit) proprietary files.
#
# 1. Files of the 1520 itself (firmware, Wi-Fi config, audio calibration)
#    come from the user's own phone. extract-local.sh copies them into
#    proprietary-local/, which is ignored by git: they are never committed.
#    The tree mirrors the install paths:
#      proprietary-local/vendor/...  -> $(TARGET_COPY_OUT_VENDOR)/...
#      proprietary-local/system/...  -> $(TARGET_COPY_OUT_SYSTEM)/...
#    Without proprietary-local/ the build still works, without these files.
#    They are listed first: PRODUCT_COPY_FILES keeps the first entry for a
#    destination, so they win over the generic files of the device tree.
#
# 2. Generic MSM8974 Android blobs (Adreno, QMI/RIL, location, ...) come
#    from TheMuppets' proprietary_vendor_oppo (msm8974-common), minus the
#    OnePlus One firmware that does not belong on the 1520.

BANDIT_LOCAL_PATH := vendor/nokia/bandit/proprietary-local

BANDIT_LOCAL_FILES := $(wildcard \
    $(BANDIT_LOCAL_PATH)/vendor/firmware/*.mdt \
    $(BANDIT_LOCAL_PATH)/vendor/firmware/*.b[0-9][0-9] \
    $(BANDIT_LOCAL_PATH)/vendor/firmware/wlan/prima/* \
    $(BANDIT_LOCAL_PATH)/system/etc/acdbdata/MTP/*.acdb)

PRODUCT_COPY_FILES += \
    $(foreach f,$(filter $(BANDIT_LOCAL_PATH)/vendor/%,$(BANDIT_LOCAL_FILES)), \
        $(f):$(TARGET_COPY_OUT_VENDOR)/$(patsubst $(BANDIT_LOCAL_PATH)/vendor/%,%,$(f))) \
    $(foreach f,$(filter $(BANDIT_LOCAL_PATH)/system/%,$(BANDIT_LOCAL_FILES)), \
        $(f):$(TARGET_COPY_OUT_SYSTEM)/$(patsubst $(BANDIT_LOCAL_PATH)/system/%,%,$(f)))

# Generic MSM8974 blobs. Venus (video codec) firmware of the OnePlus One is
# dropped: the 1520 uses its own qcvss8974 image (venus.* above).
include vendor/oppo/msm8974-common/msm8974-common-vendor.mk

BANDIT_OPPO_FW := vendor/oppo/msm8974-common/proprietary/vendor/firmware
PRODUCT_COPY_FILES := $(filter-out $(BANDIT_OPPO_FW)/venus.%,$(PRODUCT_COPY_FILES))
