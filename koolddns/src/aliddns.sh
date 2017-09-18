#!/bin/sh

timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")

accesskey=$1
signature=$2
domain=$3
name=$4
ip=$5
alinum=$6
recordid=$7

subname=$(echo "$name" | awk -F'.' '{print $1}')
subdomain=$(echo "$name" | awk -F'.' '{print $2}')
if [ "Z$subdomain" == "Z" ]; then
	#add support sencond subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		alidomain=$domain
		url_name=%40
	elif [ "Z$subname" == "Z*" ]; then
		alidomain=$name.$domain
		url_name=%2A
	else
		alidomain=$name.$domain
		url_name=$name
	fi
else
	#add support third subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		alidomain=$subdomain.$domain
		url_name=%40.$subdomain
	elif [ "Z$subname" == "Z*" ]; then
		alidomain=$name.$domain
		url_name=%2A.$subdomain
	else
		alidomain=$name.$domain
		url_name=$name
	fi
fi

remoteresolve2ip() {
	#remoteresolve2ip alidomain<string>
	alidomain=$1
	tmp_ip=`drill @ns1.alidns.com $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`drill @ns2.alidns.com $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`dig @223.5.5.5 $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	echo -n $tmp_ip
}

resolve2ip() {
	#resolve2ip alidomain<string>
	alidomain=$1
	localtmp_ip=`nslookup $alidomain ns1.alidns.com 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p' | sed -n '2p' | awk -F' ' '{print $1}'`
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $alidomain ns2.alidns.com 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p' | sed -n '2p' | awk -F' ' '{print $1}'`
	fi
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $alidomain 223.5.5.5 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p' | sed -n '2p' | awk -F' ' '{print $1}'`
	fi
	echo -n $localtmp_ip
}

check_aliddns() {
	current_ip=$(resolve2ip $alidomain)
	remotecurrent_ip=$(remoteresolve2ip $alidomain)
	
	echo $(date): "本地接口IP :" ${ip}
	if [ "Z$remotecurrent_ip" == "Z" ]; then
		echo $(date): "远程解析IP : 暂无解析记录！"
		recordid='' # NO Remote Resolve IP Means new Record_ID
	else
		if [ "Z$current_ip" == "Z" ]; then
			echo $(date): "本地解析IP : 本地解析尚未生效！"
			echo $(date): "远程解析IP :" ${remotecurrent_ip}
		else
			if [ "Z$current_ip" != "Z$remotecurrent_ip" ]; then
				echo $(date): "本地解析IP : 本地解析尚未生效！"
				echo $(date): "远程解析IP :" ${remotecurrent_ip}
			else
				echo $(date): "本地解析IP :" ${current_ip}
				echo $(date): "远程解析IP :" ${remotecurrent_ip}
			fi
		fi
	fi
	if [ "Z$ip" == "Z$remotecurrent_ip" ]; then
		echo $(date): "解析地址一致，无需更新"
		return 0
	else
		echo $(date): "正在检查阿里云解析配置..."
		return 1
	fi
}

urlencode() {
	# urlencode url<string>
	out=''
	for c in $(echo -n $1 | sed 's/[^\n]/&\n/g'); do
		case $c in
			[a-zA-Z0-9._-]) out="$out$c" ;;
			*) out="$out$(printf '%%%02X' "'$c")" ;;
		esac
	done
	echo -n $out
}

send_request() {
	# send_request action<string> args<string>
	local args="AccessKeyId=$accesskey&Action=$1&Format=json&$2&Version=2015-01-09"
	local hash=$(urlencode $(echo -n "GET&%2F&$(urlencode $args)" | openssl dgst -sha1 -hmac "$signature&" -binary | openssl base64))
	curl -sSL "http://alidns.aliyuncs.com/?$args&Signature=$hash"
}

get_recordid() {
	sed -n 's/.*RecordId[^0-9]*\([0-9]*\).*/\1/p'
}

query_recordid() {
	send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$url_name.$domain&Timestamp=$timestamp"
}

update_record() {
	send_request "UpdateDomainRecord" "RR=$url_name&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&Timestamp=$timestamp&Type=A&Value=$ip"
}

add_record() {
	send_request "AddDomainRecord&DomainName=$domain" "RR=$url_name&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&Timestamp=$timestamp&Type=A&Value=$ip"
}

do_ddns_record() {
	recordid=`query_recordid | get_recordid`
	if [ "Z$recordid" == "Z" ]; then
		recordid=`add_record | get_recordid`
		doaction=1
		echo $(date): "添加记录..."
	else
		update_record $recordid >/dev/null 2>&1
		doaction=0
		echo $(date): "更新记录..."
	fi
	if [ "Z$recordid" == "Z" ]; then
		# failed
		echo $(date): "更新失败，请检查配置文件！"
	else
		# save recordid
		uci set koolddns.$alinum.recordid=$recordid
		uci commit koolddns
		if [ "$doaction" == 1 ]; then
			echo $(date): "koolddns添加成功!"
		else
			echo $(date): "koolddns更新成功!"
		fi
	fi
}

[ -x /usr/bin/openssl -a -x /usr/bin/curl -a -x /bin/sed ] ||
	( echo $(date): "Need openssl +bind-dig +curl + sed !" && exit 1 )

version=$(cat /etc/openwrt_release | grep -w DISTRIB_RELEASE | grep -w "By stones")
[ -z "$version" ] && exit 0

check_aliddns || do_ddns_record