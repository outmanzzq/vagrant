#!/bin/bash
yum install -y ipvsadm
#yum install net-tools -y
service iptables stop
chkconfig iptables off

yum install keepalived -y

cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.ori
cat /vagrant/conf/keepalived-backup.conf >/etc/keepalived/keepalived.conf

service keepalived restart
