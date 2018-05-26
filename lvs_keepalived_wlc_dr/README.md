>通过vagrant实现lvs+keepalived（wlc+DR模式）负载均衡高可用

# 一、环境相关说明
- 操作系统：macOS 10.13.4
- vagrant:  2.0.1
- vbox: 5.1.30 r118389
- box: CentOS/6

## 1. 主机IP相关说明

角色|vagrant-name|IP|备注
-|-|-|-
LVS1-Master|vs-master|DIP:192.168.4.50|LVS负载均衡器主节点
LVS2-Backup|vs-backup|DIP:192.168.4.55|LVS负载均衡器备节点
WEB1|rs-web1|RIP:192.168.4.51|工作节点服务器1
WEB2|rs-web2|RIP:192.168.4.52|工作节点服务器2
VIP||VIP:192.168.4.252|LVS虚拟IP

# 二、部署过程
## 1. 进入到Vagrantfile所在目录，执行:
```
$vagrant up 
```
## 2. 相关验证
### 验证lvs主备切换
```
$ vagrant ssh vs-master -c "sudo ipvsadm -Ln --stats"
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  192.168.4.252:80                   34      204        0    13634        0
  -> 192.168.4.51:80                    11       66        0     4411        0
  -> 192.168.4.52:80                    13       78        0     5213        0
Connection to 127.0.0.1 closed.
```
### 验证工作节点高可用
- 停掉vs-master keepavlived服务（发现VIP漂移到vs-backup机器eth1网卡上）
```
# vs-master
$ vagrant ssh vs-master -c "ip ad |grep 'inet '"
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet 192.168.4.50/24 brd 192.168.4.255 scope global eth1
    inet 192.168.4.252/32 scope global eth1
$ vagrant ssh vs-master -c "sudo service keepalived stop"
$ vagrant ssh vs-master -c "ip ad |grep 'inet '"
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet 192.168.4.50/24 brd 192.168.4.255 scope global eth1

# vs-backup
$ vagrant ssh vs-backup -c "ip ad |grep 'inet '"
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet 192.168.4.55/24 brd 192.168.4.255 scope global eth1
    inet 192.168.4.252/32 scope global eth1
```
- 恢复vs-master keepalived服务（VIP从vs-backup重新漂移到vs-master eth1网卡上）
```
$ vagrant ssh vs-master -c "sudo service keepalived start"
Starting keepalived:                                       [  OK  ]
# vs-master
$ vagrant ssh vs-master -c "ip ad |grep 'inet '"
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet 192.168.4.50/24 brd 192.168.4.255 scope global eth1
    inet 192.168.4.252/32 scope global eth1

# vs-backup
$ vagrant ssh vs-backup -c "ip ad |grep 'inet '"
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    inet 192.168.4.55/24 brd 192.168.4.255 scope global eth1
```
### 验证LVS负载均衡
```
# 在宿主机上执行
$ for i in `seq 100`;do curl --connect-timeout 1 192.168.4.252;sleep 1;done
Real Server 2
Real Server 1
Real Server 2
Real Server 1
Real Server 2
Real Server 1
Real Server 2
Real Server 1
Real Server 2
```