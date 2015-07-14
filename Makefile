GO_EASY_ON_ME = 1

ARCHS = armv7 arm64
SDKVERSION = 7.0
TARGET = iphone:clang::7.0

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CallAnswerActivate
CallAnswerActivate_FILES = Tweak.xm
CallAnswerActivate_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
