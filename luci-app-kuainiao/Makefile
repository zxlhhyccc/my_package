
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-kuainiao
PKG_VERSION:=20170720
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-kuainiao
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	PKGARCH:=all
   DEPENDS:=+openssl-util +wget
   TITLE:=Xunlei Kuainiao for lede
endef

define Package/luci-app-kuainiao/description
endef

define Package/luci-app-kuainiao/conffiles
/etc/config/kuainiao
endef

define Package/luci-app-kuainiao/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-kuainiao ]; then
		( . /etc/uci-defaults/luci-kuainiao ) && rm -f /etc/uci-defaults/luci-kuainiao
	fi
	rm -rf /tmp/luci-indexcache
fi
endef

define Build/Compile
endef

define Package/luci-app-kuainiao/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/usr/bin/* $(1)/usr/bin/
	$(INSTALL_BIN) ./files/etc/init.d/kuainiao $(1)/etc/init.d/
	$(INSTALL_CONF) ./files/etc/config/kuainiao $(1)/etc/config/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/* $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/kuainiao
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/kuainiao/* $(1)/usr/lib/lua/luci/view/kuainiao/
	
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/luci-kuainiao $(1)/etc/uci-defaults/luci-kuainiao

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) ./files/js/*.js $(1)/www/luci-static/resources/
	
	$(INSTALL_DIR) $(1)/usr/share/kuainiao
	$(INSTALL_DATA) ./files/js/kuainiao_down_state $(1)/usr/share/kuainiao/kuainiao_down_state
	$(INSTALL_DATA) ./files/js/kuainiao_up_state $(1)/usr/share/kuainiao/kuainiao_up_state

endef


$(eval $(call BuildPackage,luci-app-kuainiao))
