local e=require"nixio.fs"
local e=luci.http
local a,t,e
a=Map("ddnsto",translate("ddnsto"),translate("ddnsto是koolshare小宝开发的，支持http2的快速远程路由工具。</br>你需要先到 https://ddnsto.com 注册，然后在本插件内填入Token，再登录 https://ddnsto.com 设置穿透。"))
a:section(SimpleSection).template="ddnsto/ddnsto_status"
t=a:section(TypedSection,"global",translate("全局设置"),translate("设置教程:</font><a style=\"color: #ff0000;\" onclick=\"window.open('http://koolshare.cn/thread-116500-1-1.html')\">点击跳转到论坛教程</a>"))
t.anonymous=true
t.addremove=false
e=t:option(Flag,"enable",translate("启用"))
e.default=0
e.rmempty=false
e=t:option(Value,"start_delay",translate("Delay Start"),translate("Units:seconds"))
e.datatype="uinteger"
e.default="0"
e.rmempty=true
e=t:option(Value,"token",translate('ddnsto Token'))
e.password=true
e.rmempty=false
if nixio.fs.access("/etc/config/ddnsto")then
e=t:option(Button,"Configuration",translate("域名配置管理"))
e.inputtitle=translate("打开网站")
e.inputstyle="reload"
e.write=function()
luci.http.redirect("https://www.ddnsto.com")
end
end
return a
