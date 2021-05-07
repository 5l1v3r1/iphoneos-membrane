include $(THEOS)/makefiles/common.mk
export TARGET = iphone:clang:13.0

DEBUG = 1
TOOL_NAME = membrane
SDKVERSION = 13.0
ARCHS = arm64 arm64e

membrane_FILES = src/main.mm src/membrane.m
membrane_FRAMEWORKS = Foundation
membrane_PRIVATE_FRAMEWORKS = AppSupport
membrane_CFLAGS = -fobjc-arc -Wno-unused -I./src/include -I$(THEOS)/sdks/iPhoneOS$(SDKVERSION).sdk/usr/include
membrane_OBJ_FILES = lib/libssl.a lib/libcrypto.a 
membrane_LDFLAGS = -L./lib -lssl -lcrypto -w
membrane_LIBRARIES = ssl crypto
membrane_CODESIGN_FLAGS = -Ssign.plist

include $(THEOS_MAKE_PATH)/tool.mk

