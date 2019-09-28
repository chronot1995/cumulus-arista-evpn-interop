#!/usr/bin/env bash
FastCli -p 15 -c"
enable
configure
transceiver qsfp default-mode 4x10G
service routing protocols model multi-agent
hostname switch02
spanning-tree mode mstp
aaa authorization exec default local
no aaa root
!
username cumulus privilege 15 role network-admin secret 0 CumulusLinux!
!username eapi secret sha512 $6$5FRqvZkWztLfz4k2$QUQk6SNrzky91RmbX5VOp5iZEHdxNopTaM2mDxRtqwBBWIFtM19.Lu81Tfa9rIIim2d7lmW54pI8lvJ1SEGyk.
!username vagrant privilege 15 shell /bin/bash secret sha512 $6$3kgdKcJLJ3j/0N51$a0YshIzKL3xtdwP6XXXRlY9B8yHFK/tLdg0I95YUIaW7oHqLsgK9TxMg8/0bL6VDkImuWT.g7WRKTxi8nNPtA1
username vagrant sshkey ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
!
vlan 11
!
interface Ethernet1
   description Management
   no switchport
   ip address 192.168.200.2/24
!
interface Ethernet2
   description to-Switch01
   mtu 9000
   no switchport
   ip address 172.16.31.2/30
!
interface Ethernet3
   description to-Switch01
   mtu 9000
   no switchport
   ip address 172.16.31.6/30
!
interface Ethernet4
   description to-Server02
   switchport access vlan 11
!
interface Loopback0
   description ROUTER-ID
   ip address 10.2.2.2/32
!
interface Management1
   ip address dhcp
!
interface Vxlan1
   vxlan source-interface Loopback0
   vxlan udp-port 4789
   vxlan vlan 11 vni 11
!
event-handler ALTER-VAGRANT-SHELL
   action bash sudo sed -i 's:^username vagrant privilege 15 shell /bin/bash :username vagrant privilege 15 :g' /mnt/flash/startup-config
   delay 60
!
event-handler COPY-STARTUP-TO-RUNNING
   action bash FastCli -p 15 -c 'configure replace startup-config'
   delay 70
!
ip routing
!
ipv6 unicast-routing
!
router bgp 65222
   router-id 10.2.2.2
   maximum-paths 2 ecmp 2
   neighbor SPINE peer-group
   neighbor SPINE remote-as 65111
   neighbor SPINE send-community extended
   neighbor SPINE maximum-routes 12000
   neighbor 172.16.31.1 peer-group SPINE
   neighbor 172.16.31.5 peer-group SPINE
   !
   vlan 11
      rd 65222:11
      route-target both 65222:11
      route-target import 65111:11
      redistribute learned
   !
   address-family evpn
      neighbor SPINE activate
   !
   address-family ipv4
      neighbor SPINE activate
      network 10.2.2.2/32
   !
!
management api http-commands
   no protocol https
   protocol unix-socket
   no shutdown
!
end
"
