ARCHS = armv7
TARGET = iphone:clang::5.0
include theos/makefiles/common.mk

TWEAK_NAME = ActDescription
ActDescription_FILES = Tweak.mm
ActDescription_FRAMEWORKS = UIKit
ActDescription_LIBRARIES = activator
# ActDescription_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
