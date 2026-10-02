export ARCHS = arm64
export TARGET = iphone:clang:13.0:13.0

include theos/makefiles/common.mk

TWEAK_NAME = WatusiAdsPatch
WatusiAdsPatch_FILES = WatusiAdsPatch.m
WatusiAdsPatch_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"