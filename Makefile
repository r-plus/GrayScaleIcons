include theos/makefiles/common.mk

TWEAK_NAME = GrayScaleIcons
GrayScaleIcons_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = GrayScaleIconsSettings
GrayScaleIconsSettings_FILES = Preference.m GSAppListCell.m
GrayScaleIconsSettings_INSTALL_PATH = /Library/PreferenceBundles
GrayScaleIconsSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics
GrayScaleIconsSettings_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices
GrayScaleIconsSettings_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GrayScaleIcons.plist$(ECHO_END)
