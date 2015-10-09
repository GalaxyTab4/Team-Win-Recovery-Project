LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_CFLAGS := -fno-strict-aliasing

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    animation.cpp \
    object.cpp \
    slider.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp \
    mousecursor.cpp \
    scrolllist.cpp \
    patternpassword.cpp

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
    LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
    LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++ libminzip libaosprecovery
LOCAL_MODULE := libguitwrp

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
    LOCAL_CFLAGS += -D_EVENT_LOGGING
endif
ifneq ($(TW_USE_KEY_CODE_TOUCH_SYNC),)
    LOCAL_CFLAGS += -DTW_USE_KEY_CODE_TOUCH_SYNC=$(TW_USE_KEY_CODE_TOUCH_SYNC)
endif

ifneq ($(TW_NO_SCREEN_BLANK),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(HAVE_SELINUX), true)
    LOCAL_CFLAGS += -DHAVE_SELINUX
endif
ifeq ($(TW_OEM_BUILD), true)
    LOCAL_CFLAGS += -DTW_OEM_BUILD
endif
ifeq ($(TW_DISABLE_TTF), true)
    LOCAL_CFLAGS += -DTW_DISABLE_TTF
endif
ifneq ($(TW_X_OFFSET),)
    LOCAL_CFLAGS += -DTW_X_OFFSET=$(TW_X_OFFSET)
endif
ifneq ($(TW_Y_OFFSET),)
    LOCAL_CFLAGS += -DTW_Y_OFFSET=$(TW_Y_OFFSET)
endif
ifeq ($(TW_ROUND_SCREEN), true)
    LOCAL_CFLAGS += -DTW_ROUND_SCREEN
endif
ifneq ($(LANDSCAPE_RESOLUTION),)
    LOCAL_CFLAGS += -DTW_HAS_LANDSCAPE
endif
ifneq ($(TW_THEME_LANDSCAPE),)
    LOCAL_CFLAGS += -DTW_HAS_LANDSCAPE
endif
ifneq ($(TW_DEFAULT_ROTATION),)
    LOCAL_CFLAGS += -DTW_DEFAULT_ROTATION=$(TW_DEFAULT_ROTATION)
endif
ifneq ($(BOARD_SYSTEMIMAGE_PARTITION_SIZE),)
    LOCAL_CFLAGS += -DBOARD_SYSTEMIMAGE_PARTITION_SIZE=$(BOARD_SYSTEMIMAGE_PARTITION_SIZE)
endif

LOCAL_C_INCLUDES += bionic external/stlport/stlport system/core/libpixelflinger/include
LOCAL_CFLAGS += -DTWRES=\"$(TWRES_PATH)\"

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
TWRP_RES_LOC := $(commands_recovery_local_path)/gui/devices/common/res
TWRP_COMMON_XML := $(hide) echo "No common TWRP XML resources"

ifeq ($(TW_CUSTOM_THEME),)
    ifeq ($(TW_THEME),)
        # This converts the old DEVICE_RESOLUTION flag to the new TW_THEME flag
        PORTRAIT_MDPI := 320x480 480x800 480x854 540x960
        PORTRAIT_HDPI := 720x1280 800x1280 1080x1920 1200x1920 1440x2560 1600x2560
        WATCH_MDPI := 240x240 280x280 320x320
        LANDSCAPE_MDPI := 800x480 1024x600 1024x768
        LANDSCAPE_HDPI := 1280x800 1920x1200 2560x1600
        ifneq ($(filter $(DEVICE_RESOLUTION), $(PORTRAIT_MDPI)),)
            TW_THEME := portrait_mdpi
        else ifneq ($(filter $(DEVICE_RESOLUTION), $(PORTRAIT_HDPI)),)
            TW_THEME := portrait_hdpi
        else ifneq ($(filter $(DEVICE_RESOLUTION), $(WATCH_MDPI)),)
            TW_THEME := watch_mdpi
        else ifneq ($(filter $(DEVICE_RESOLUTION), $(LANDSCAPE_MDPI)),)
            TW_THEME := landscape_mdpi
        else ifneq ($(filter $(DEVICE_RESOLUTION), $(LANDSCAPE_HDPI)),)
            TW_THEME := landscape_hdpi
        endif
    endif
    ifeq ($(TW_THEME), portrait_mdpi)
        TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/480x800/res
        TWRP_COMMON_XML := cp -fr $(commands_recovery_local_path)/gui/devices/portrait/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
    else ifeq ($(TW_THEME), portrait_hdpi)
        TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/1080x1920/res
        TWRP_COMMON_XML := cp -fr $(commands_recovery_local_path)/gui/devices/portrait/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
    else ifeq ($(TW_THEME), watch_mdpi)
        TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/320x320/res
        TWRP_COMMON_XML := cp -fr $(commands_recovery_local_path)/gui/devices/watch/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
    else ifeq ($(TW_THEME), landscape_mdpi)
        TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/800x480/res
        TWRP_COMMON_XML := cp -fr $(commands_recovery_local_path)/gui/devices/landscape/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
    else ifeq ($(TW_THEME), landscape_hdpi)
        TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/1920x1200/res
        TWRP_COMMON_XML := cp -fr $(commands_recovery_local_path)/gui/devices/landscape/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
    else
        $(warning ****************************************************************************)
        $(warning * TW_THEME ($(TW_THEME)) is not valid.)
        $(warning * Please choose an appropriate TW_THEME or create a new one for your device.)
        $(warning * Valid options are portrait_mdpi portrait_hdpi watch_mdpi)
        $(warning *                   landscape_mdpi landscape_hdpi)
        $(warning ****************************************************************************)
        $(error stopping)
    endif

    ifeq ($(TW_THEME_LANDSCAPE),)
        # This converts the old DEVICE_RESOLUTION flag to the new TW_THEME flag
        PORTRAIT_MDPI := 320x480 480x800 480x854 540x960
        PORTRAIT_HDPI := 720x1280 800x1280 1080x1920 1200x1920 1440x2560 1600x2560
        WATCH_MDPI := 240x240 280x280 320x320
        LANDSCAPE_MDPI := 800x480 1024x600 1024x768
        LANDSCAPE_HDPI := 1280x800 1920x1200 2560x1600
        ifneq ($(filter $(LANDSCAPE_RESOLUTION), $(PORTRAIT_MDPI)),)
            TW_THEME_LANDSCAPE := portrait_mdpi
        else ifneq ($(filter $(LANDSCAPE_RESOLUTION), $(PORTRAIT_HDPI)),)
            TW_THEME_LANDSCAPE := portrait_hdpi
        else ifneq ($(filter $(LANDSCAPE_RESOLUTION), $(WATCH_MDPI)),)
            TW_THEME_LANDSCAPE := watch_mdpi
        else ifneq ($(filter $(LANDSCAPE_RESOLUTION), $(LANDSCAPE_MDPI)),)
            TW_THEME := landscape_mdpi
        else ifneq ($(filter $(LANDSCAPE_RESOLUTION), $(LANDSCAPE_HDPI)),)
            TW_THEME_LANDSCAPE := landscape_hdpi
        endif
    endif
    ifeq ($(TW_THEME_LANDSCAPE), portrait_mdpi)
        TWRP_THEME_LOC_LANDSCAPE := $(commands_recovery_local_path)/gui/devices/480x800/res
        TWRP_COMMON_XML_LANDSCAPE := cp -fr $(commands_recovery_local_path)/gui/devices/portrait/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
    else ifeq ($(TW_THEME_LANDSCAPE), portrait_hdpi)
        TWRP_THEME_LOC_LANDSCAPE := $(commands_recovery_local_path)/gui/devices/1080x1920/res
        TWRP_COMMON_XML_LANDSCAPE := cp -fr $(commands_recovery_local_path)/gui/devices/portrait/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
    else ifeq ($(TW_THEME_LANDSCAPE), watch_mdpi)
        TWRP_THEME_LOC_LANDSCAPE := $(commands_recovery_local_path)/gui/devices/320x320/res
        TWRP_COMMON_XML_LANDSCAPE := cp -fr $(commands_recovery_local_path)/gui/devices/watch/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
    else ifeq ($(TW_THEME_LANDSCAPE), landscape_mdpi)
        TWRP_THEME_LOC_LANDSCAPE := $(commands_recovery_local_path)/gui/devices/800x480/res
        TWRP_COMMON_XML_LANDSCAPE := cp -fr $(commands_recovery_local_path)/gui/devices/landscape/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
    else ifeq ($(TW_THEME_LANDSCAPE), landscape_hdpi)
        TWRP_THEME_LOC_LANDSCAPE := $(commands_recovery_local_path)/gui/devices/1920x1200/res
        TWRP_COMMON_XML_LANDSCAPE := cp -fr $(commands_recovery_local_path)/gui/devices/landscape/res/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
    endif
else
    TWRP_THEME_LOC := $(TW_CUSTOM_THEME)
endif


ifeq ($(TW_DISABLE_TTF), true)
    TWRP_REMOVE_FONT := rm -f $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)fonts/*.ttf
else
    TWRP_REMOVE_FONT := rm -f $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)fonts/*.dat
endif

TWRP_RES_GEN := $(intermediates)/twrp
ifneq ($(TW_USE_TOOLBOX), true)
    TWRP_SH_TARGET := /sbin/busybox
else
    TWRP_SH_TARGET := /sbin/mksh
endif

$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_RES_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	$(TWRP_COMMON_XML)
	$(TWRP_REMOVE_FONT)
ifneq ($(TWRP_THEME_LOC_LANDSCAPE),)
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
	cp -fr $(TWRP_RES_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
	cp -fr $(TWRP_THEME_LOC_LANDSCAPE)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)landscape/
	$(TWRP_COMMON_XML_LANDSCAPE)
endif
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin/
ifneq ($(TW_USE_TOOLBOX), true)
	ln -sf $(TWRP_SH_TARGET) $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh
endif
	ln -sf /sbin/pigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gzip
	ln -sf /sbin/unpigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gunzip


LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)
