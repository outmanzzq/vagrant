#!/bin/bash
vip=192.168.4.252
dev=lo:1
case $1 in
start)
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore # 只响应目的IP地址为接收网卡上的本地地址的arp请求
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce # 忽略IP数据包的源IP地址，选择该发送网卡上最合适的本地地址作为arp请求的源IP地址。
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ifconfig $dev $vip netmask 255.255.255.255 broadcast $vip up
    echo "VS Server is Ready!"
    ;;
stop)
    ifconfig $dev down
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore # 响应任意网卡上接收到的对本机IP地址的arp请求（包括环回网卡上的地址），而不管该目的IP是否在接收网卡上。
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce # 允许使用任意网卡上的IP地址作为arp请求的源IP，通常就是使用数据包a的源IP。
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
    echo "VS Server is Cancel!"
    ;;
*)
    echo "Usage `basename $0` start|stop"
    exit 1
    ;;
esac