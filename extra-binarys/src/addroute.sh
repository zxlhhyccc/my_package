#!/bin/sh
# Copyright (C) 2016 fw867 <ffkykzs@gmail.com>
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.

wanport=$1
routeip=$2
cleanfile=$3

if [ $wanport -gt 0 ] && [ -z $(ip route show|grep $routeip) ];then
  gateway=$(ip route show|grep default|awk -F " " '{print $3}'|sed -n $wanport"p")
  devname=$(ip route show|grep default|awk -F " " '{print $5}'|sed -n $wanport"p")
  epname=$(cat /var/state/network|grep -w $devname|awk -F'.' '{print $2}')
  [ -z "$epname" ] && epname=`echo $devname | awk -F'-' '{print $2}' 2>/dev/null`
  if [ -n $gateway ] && [ -n $devname ];then
    ip route add $routeip via $gateway dev $devname >/dev/null 2>&1 &
    echo "$(date): 设置指定IP：$routeip 出口为：$epname"
	if [ ! -f $cleanfile ];then
		cat > $cleanfile <<EOF
#!/bin/sh
EOF
	fi
	if [ ! -x $cleanfile ];then
		chmod a+x $cleanfile
	fi
    echo "ip route del $routeip via $gateway dev $devname" >> $cleanfile
  fi
fi

