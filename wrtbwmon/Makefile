#
# Copyright (C) 2006-2011 Xmlad.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wrtbwmon
PKG_VERSION:=0.3.6
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/wrtbwmon
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+busybox +iptables +ip
	TITLE:=An Traffic Usage Monitor
	SUBMENU:=CERNET
	PKGARCH:=all
endef

define Package/wrtbwmon/description
An CERNET client daemon,
Most usually used in China collages.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wrtbwmon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/* $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/usr/share/wrtbwmon
	$(INSTALL_BIN) ./files/usr/share/wrtbwmon/* $(1)/usr/share/wrtbwmon/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/wrtbwmon $(1)/etc/init.d/wrtbwmon
endef

$(eval $(call BuildPackage,wrtbwmon))
