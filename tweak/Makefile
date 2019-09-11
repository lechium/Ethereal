ARCHS = arm64
TARGET = appletv
export GO_EASY_ON_ME=1
export SDKVERSION=12.1
THEOS_DEVICE_IP=twelve.local
DEBUG=1
export DEBUG=1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Prefs
Prefs_FILES = Prefs.xm
Prefs_LIBRARIES = substrate
Prefs_FRAMEWORKS = Foundation UIKit CoreGraphics MobileCoreServices
Prefs_LDFLAGS = -undefined dynamic_lookup
Prefs_CFLAGS = -I.

include $(THEOS_MAKE_PATH)/tweak.mk


internal-stage::
	cp $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).* ../layout/Library/MobileSubstrate/DynamicLibraries/
	
after-install::
	install.exec "killall -9 TVSettings"
