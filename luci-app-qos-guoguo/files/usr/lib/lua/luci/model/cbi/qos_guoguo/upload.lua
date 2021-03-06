local t=require"luci.tools.webadmin"
local e=require"nixio.fs"
local a=require"luci.sys"
m=Map("qos_guoguo",translate("Upload Settings"))
s=m:section(TypedSection,"upload_class",translate("Classification Rules"),
translate("Each upload service class is specified by three parameters: percent bandwidth at capacity, minimum bandwidth and maximum bandwidth.").."<br />"..
translate("<em>Percent bandwidth</em> is the percentage of the total available bandwidth that should be allocated to this class when all available bandwidth is being used. If unused bandwidth is available, more can (and will) be allocated. The percentages can be configured to equal more (or less) than 100, but when the settings are applied the percentages will be adjusted proportionally so that they add to 100.").."<br />"..
translate("<em>Minimum bandwidth</em> specifies the minimum service this class will be allocated when the link is at capacity. For certain applications like VoIP or online gaming it is better to specify a minimum service in bps rather than a percentage. QoS will satisfiy the minimum service of all classes first before allocating the remaining service to other waiting classes.").."<br />"..
translate("<em>Maximum bandwidth</em> specifies an absolute maximum amount of bandwidth this class will be allocated in kbit/s. Even if unused bandwidth is available, this service class will never be permitted to use more than this amount of bandwidth.")
)
s.addremove=true
s.template="cbi/tblsection"
name=s:option(Value,"name",translate("Class Name"))
pb=s:option(Value,"percent_bandwidth",translate("Percent bandwidth at capacity"))
minb=s:option(Value,"min_bandwidth",translate("Minimum bandwidth"))
minb.datatype="and(portrange)"
maxb=s:option(Value,"max_bandwidth",translate("Maximum bandwidth"))
maxb.datatype="and(portrange)"
s=m:section(TypedSection,"upload_rule",translate("Classification Rules"),
translate("Packets are tested against the rules in the order specified -- rules toward the top have priority. As soon as a packet matches a rule it is classified, and the rest of the rules are ignored. The order of the rules can be altered using the arrow controls.")
)
s.addremove=true
s.sortable=true
s.anonymous=true
s.template="cbi/tblsection"
class=s:option(Value,"class",translate("Service Class"))
for e in io.lines("/etc/config/qos_guoguo")do
local t=e
e=string.gsub(e,"config ['\"]*upload_class['\"]* ","")
if t~=e then
e=string.gsub(e,"^'","")
e=string.gsub(e,"^\"","")
e=string.gsub(e,"'$","")
e=string.gsub(e,"\"$","")
class:value(e,m.uci:get("qos_guoguo",e,"name"))
end
end
pr=s:option(Value,"proto",translate("Application Protocol"))
pr:value("tcp")
pr:value("udp")
pr:value("icmp")
pr:value("gre")
pr.rmempty="true"
sip=s:option(Value,"source",translate("Source IP"))
t.cbi_add_knownips(sip)
sip.datatype="and(ipaddr)"
dip=s:option(Value,"destination",translate("Destination IP"))
t.cbi_add_knownips(dip)
dip.datatype="and(ipaddr)"
s:option(Value,"dstport",translate("Destination Port")).datatype="portrange"
s:option(Value,"srcport",translate("Source Port")).datatype="portrange"
min_pkt_size=s:option(Value,"min_pkt_size",translate("Minimum Packet Length"))
min_pkt_size.datatype="and(uinteger,min(1))"
max_pkt_size=s:option(Value,"max_pkt_size",translate("Maximum Packet Length"))
max_pkt_size.datatype="and(uinteger,min(1))"
connbytes_kb=s:option(Value,"connbytes_kb",translate("Connection bytes reach"))
connbytes_kb.datatype="and(uinteger,min(0))"
if(tonumber(a.exec("lsmod | cut -d ' ' -f 1 | grep -c 'xt_ndpi'")))>0 then
ndpi=s:option(Value,"ndpi",translate("DPI protocol"))
local o=io.popen("iptables -m ndpi --help | grep -e '^--'")
if o then
local e,a,t,s,i,n
while true do
e=o:read("*l")
if not e then break end
a,t=e:find("%-%-[^%s]+")
if a and t then
i=e:sub(a+2,t)
end
a,t=e:find("for [^%s]+ protocol")
if a and t then
n=e:sub(a+3,t-9)
end
ndpi:value(i,n)
end
o:close()
end
end
return m
