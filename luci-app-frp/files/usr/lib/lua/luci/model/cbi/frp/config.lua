local n="frp"
local i=require"luci.dispatcher"
local o=require"luci.model.network".init()
local m=require"nixio.fs"
local a,t,e
arg[1]=arg[1]or""
a=Map(n,translate("Frp Domain Config"))
a.redirect=i.build_url("admin","services","frp")
t=a:section(NamedSection,arg[1],"frp",translate("Config Frp Protocol"))
t.addremove=false
t.dynamic=false
t:tab("base",translate("Basic Settings"))
t:tab("other",translate("Other Settings"))
e=t:taboption("base",ListValue,"enable",translate("Enable State"))
e.default="1"
e.rmempty=false
e:value("1",translate("Enable"))
e:value("0",translate("Disable"))
e=t:taboption("base",ListValue, "type", translate("Frp Protocol Type"))
e:value("http",translate("HTTP"))
e:value("https",translate("HTTPS"))
e:value("tcp",translate("TCP"))
e:value("udp",translate("UDP"))
e:value("stcp",translate("STCP"))
e:value("xtcp",translate("XTCP"))
e = t:taboption("base",ListValue, "domain_type", translate("Domain Type"))
e.default = "custom_domains"
e:value("custom_domains",translate("Custom Domains"))
e:value("subdomain",translate("SubDomain"))
e:value("both_dtype",translate("Both the above two Domain types"))
e:depends("type","http")
e:depends("type","https")
e = t:taboption("base",Value, "custom_domains", translate("Custom Domains"), translate("If SubDomain is used, Custom Domains couldn't be subdomain or wildcard domain of the maindomain(subdomain_host)."))
e:depends("domain_type","custom_domains")
e:depends("domain_type","both_dtype")
e = t:taboption("base",Value, "subdomain", translate("SubDomain"), translate("subdomain_host must be configured in server: frps in advance."))
e:depends("domain_type","subdomain")
e:depends("domain_type","both_dtype")
e = t:taboption("base",ListValue, "stcp_role", translate("STCP Role"))
e.default = "server"
e:value("server",translate("STCP Server"))
e:value("vistor",translate("STCP Vistor"))
e:depends("type","stcp")
e = t:taboption("base",ListValue, "xtcp_role", translate("XTCP Role"))
e.default = "server"
e:value("server",translate("XTCP Server"))
e:value("vistor",translate("XTCP Vistor"))
e:depends("type","xtcp")
e = t:taboption("base",Value, "remote_port", translate("Remote Port"))
e.datatype = "port"
e:depends("type","tcp")
e:depends("type","udp")
e = t:taboption("other",Flag, "enable_plugin", translate("Use Plugin"),translate("If plugin is defined, local_ip and local_port is useless, plugin will handle connections got from frps."))
e.default = "0"
e:depends("type","tcp")
e = t:taboption("base",Value, "local_ip", translate("Local Host Address"))
luci.sys.net.ipv4_hints(function(x,d)
e:value(x,"%s (%s)"%{x,d})
end)
e.datatype = "ip4addr"
e:depends("type","udp")
e:depends("type","http")
e:depends("type","https")
e:depends("enable_plugin",0)
e = t:taboption("base",Value, "local_port", translate("Local Host Port"))
e.datatype = "port"
e:depends("type","udp")
e:depends("type","http")
e:depends("type","https")
e:depends("enable_plugin",0)
e = t:taboption("base",Flag, "range_ports", translate("Range Ports Mapping"), translate("Support multiple ports, like 6000-6005,6007"))
e.default = "0"
e:depends("type","tcp")
e:depends("type","udp")
e = t:taboption("base",Value, "stcp_secretkey", translate("STCP Screct Key"))
e.default = "abcdefg"
e:depends("type","stcp")
e = t:taboption("base",Value, "stcp_servername", translate("STCP Server Name"), translate("STCP Server Name is Service Remark Name of STCP Server"))
e.default = "secret_tcp"
e:depends("stcp_role","vistor")
e = t:taboption("base",Value, "xtcp_secretkey", translate("XTCP Screct Key"), translate("In order to support XTCP protocol, please make sure <code>bind_udp_port</code> has been configured in your server."))
e.default = "abcdefg"
e:depends("type","xtcp")
e = t:taboption("base",Value, "xtcp_servername", translate("XTCP Server Name"), translate("XTCP Server Name is Service Remark Name of XTCP Server"))
e.default = "xsecret_tcp"
e:depends("xtcp_role","vistor")
e = t:taboption("other",Flag, "enable_locations", translate("Enable URL routing"), translate("Frp support forward http requests to different backward web services by url routing."))
e:depends("type","http")
e = t:taboption("other",Value, "locations ", translate("URL routing"), translate("Http requests with url prefix /news will be forwarded to this service."))
e.default="locations=/"
e:depends("enable_locations",1)
e = t:taboption("other",ListValue, "plugin", translate("Choose Plugin"))
e:value("http_proxy",translate("http_proxy"))
e:value("socks5",translate("socks5"))
e:value("unix_domain_socket",translate("unix_domain_socket"))
e:value("static_file",translate("static_file"))
e:depends("enable_plugin",1)
e = t:taboption("other",Flag, "enable_plugin_httpuserpw", translate("Plugin Authentication"))
e.default = "0"
e:depends("plugin","http_proxy")
e:depends("plugin","socks5")
e:depends("plugin","static_file")
e = t:taboption("other",Value, "plugin_http_user", translate("Plugin UserName"))
e.default = "abc"
e:depends("enable_plugin_httpuserpw",1)
e = t:taboption("other",Value, "plugin_http_passwd", translate("Plugin Password"))
e.default = "abc"
e:depends("enable_plugin_httpuserpw",1)
e = t:taboption("other",Value, "plugin_unix_path", translate("Plugin Unix Sock Path"))
e.default = "/var/run/docker.sock"
e:depends("plugin","unix_domain_socket")
e = t:taboption("other",Value, "plugin_local_path", translate("Local Path of Static File"))
e.default = "/tmp/file"
e:depends("plugin","static_file")
e = t:taboption("other",Value, "plugin_strip_prefix", translate("Url Prefix"))
e.default = "static"
e:depends("plugin","static_file")
e = t:taboption("other",Flag, "enable_http_auth", translate("Password protecting your web service"), translate("Http username and password are safety certification for http protocol."))
e.default = "0"
e:depends("type","http")
e = t:taboption("other",Value, "http_user", translate("HTTP UserName"))
e.default = "frp"
e:depends("enable_http_auth",1)
e = t:taboption("other",Value, "http_pwd", translate("HTTP PassWord"))
e.default = "frp"
e:depends("enable_http_auth",1)
e = t:taboption("other",Flag, "enable_host_header_rewrite", translate("Rewriting the Host Header"), translate("Frp can rewrite http requests with a modified Host header."))
e.default = "0"
e:depends("type","http")
e = t:taboption("other",Value, "host_header_rewrite", translate("Host Header"), translate("The Host header will be rewritten to match the hostname portion of the forwarding address."))
e.default = "dev.yourdomain.com"
e:depends("enable_host_header_rewrite",1)
e = t:taboption("base",Flag, "use_encryption", translate("Use Encryption"), translate("Encrypted the communication between frpc and frps, will effectively prevent the traffic intercepted."))
e.default = "1"
e.rmempty = false
e = t:taboption("base",Flag, "use_compression", translate("Use Compression"), translate("The contents will be compressed to speed up the traffic forwarding speed, but this will consume some additional cpu resources."))
e.default = "1"
e.rmempty = false
e = t:taboption("base",Value, "remark", translate("Service Remark Name"), translate("<font color=\"red\">Please ensure the remark name is unique.</font>"))
e.rmempty = false
return a
