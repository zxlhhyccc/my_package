require("luci.sys")
m=Map("autoreboot",translate("定时重启"),translate("配置定时重启。"))
m.apply_on_parse=true
s=m:section(TypedSection,"login","")
s.addremove=false
s.anonymous=true
enable=s:option(Flag,"enable",translate("启用"))
week=s:option(ListValue,"week",translate("星期"))
week:value(0,translate("每天"))
for e=1,7 do
week:value(e,translate("星期"..e))
end
week.default=0
pass=s:option(Value,"minute",translate("分"))
pass.datatype = "range(0,59)"
pass.rmempty = false
hour=s:option(Value,"hour",translate("时"))
hour.datatype = "range(0,23)"
hour.rmempty = false
local e=luci.http.formvalue("cbi.apply")
if e then
io.popen("/etc/init.d/autoreboot restart")
end
return m
