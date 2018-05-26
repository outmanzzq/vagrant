#!/bin/bash

#rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum install nginx -y

cat >/usr/share/nginx/html/index.html<<EOF
Real Server 2
EOF
chkconfig nginx on
service nginx start
bash /vagrant/scripts/rs-config.sh start