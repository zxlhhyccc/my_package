local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"

m = Map("vlmcsd")
m.title	= translate("KMS服务器")
m:section(SimpleSection).template="vlmcsd/vlmcsd_status"

s = m:section(TypedSection, "vlmcsd")
s.anonymous=true

--基本设置
s:tab("basic", translate("基本设置"))

o = s:taboption("basic", Flag, "enable")
o.title = translate("开启")
o.rmempty = false

o = s:taboption("basic", Flag, "use_conf_file")
o.title = translate("使用配置自动激活")
o.rmempty = false

o = s:taboption("basic", Value, "port")
o.title = translate("本地端口")
o.datatype = "port"
o.default = 1688
o.placeholder = 1688
o:depends("use_conf_file",0)

o = s:taboption("basic", Flag, "enable_web")
o.title = translate("开启外网访问")
o.default = 0
o.rmempty = false

--配置
s:tab("config", translate("配置"))

local file = "/usr/share/vlmcsd/vlmcsd.ini"
o = s:taboption("config", TextValue, "configfile")
o.description = translate("开头数字符号（＃）或分号（;）的每一行被视为注释，去除分号（;）启用选项。")
o.rows = 20
o.wrap = "off"
o.cfgvalue = function(self, section)
	return NXFS.readfile(file) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(file, value:gsub("\r\n", "\n"))
end

s:tab("log", translate("日志记录"))

local file = "/var/log/vlmcsd.log"
o = s:taboption("log", TextValue, "logfile")
o.rows = 20
o.wrap = "on"
o.cfgvalue = function(self, section)
	return NXFS.readfile(file) or ""
end
o.write = function(self, section, value)
end

return m
