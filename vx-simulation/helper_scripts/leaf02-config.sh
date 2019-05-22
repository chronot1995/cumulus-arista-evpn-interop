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
!username cumulus secret sha512 $6$/cus0zbed5QGw/R6$Z24/Ki17LWGo0XDL8uBqPBdf0k3bt9bKHzIz8vwopVKm.EPr8bWhVdMaqaGi0kn9ytMv0t1dGGDz3HX70F6jZ/
username cumulus privilege 15 role network-admin secret sha512 $6$xm5sEsJGMcqaXexD$vnODbAGcDcsxFtDnTQurrL3NPMPKL7Z1ubyS6DArPrArvxAJfe.AUV7LHkMGXOzCjypZPnYhT9Q4S1bH8sI3P0
!username eapi secret sha512 $6$5FRqvZkWztLfz4k2$QUQk6SNrzky91RmbX5VOp5iZEHdxNopTaM2mDxRtqwBBWIFtM19.Lu81Tfa9rIIim2d7lmW54pI8lvJ1SEGyk.
!username vagrant privilege 15 shell /bin/bash secret sha512 $6$3kgdKcJLJ3j/0N51$a0YshIzKL3xtdwP6XXXRlY9B8yHFK/tLdg0I95YUIaW7oHqLsgK9TxMg8/0bL6VDkImuWT.g7WRKTxi8nNPtA1
username vagrant sshkey ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
!
vlan 24
!
vrf definition vrf1
!
interface Ethernet1
   description Management
   no switchport
   ip address 192.168.200.2/24
!
interface Ethernet2
   description to-Server02
   mtu 9214
   switchport access vlan 24
!
interface Ethernet3
   description to-Switch01
   mtu 9214
   no switchport
   ip address 172.16.31.2/30
!
interface Ethernet4
   description to-Switch01
   mtu 9214
   no switchport
   ip address 172.16.31.6/30
!
interface Loopback0
   description ROUTER-ID
   ip address 10.0.0.12/32
!
interface Management1
   ip address dhcp
!
interface Vlan24
   vrf forwarding vrf1
   ip address 10.2.4.12/24
!
interface Vxlan1
   vxlan source-interface Loopback0
   vxlan udp-port 4789
   vxlan vlan 24 vni 10024
   vxlan vrf vrf1 vni 104001
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
ip routing vrf vrf1
!
ipv6 unicast-routing
!
router bgp 65012
   router-id 10.0.0.12
   maximum-paths 2 ecmp 2
   neighbor SPINE peer-group
   neighbor SPINE remote-as 65020
   neighbor SPINE send-community extended
   neighbor SPINE maximum-routes 12000
   neighbor 172.16.31.1 peer-group SPINE
   neighbor 172.16.31.5 peer-group SPINE
   !
   vlan 24
      rd auto
      route-target both 1:10020
      redistribute learned
   !
   address-family evpn
      neighbor SPINE activate
   !
   address-family ipv4
      neighbor SPINE activate
      network 10.0.0.12/32
   !
   vrf vrf1
      rd 10.0.0.12:70
      route-target import evpn 1:10020
      route-target export evpn 1:10020
!
management api http-commands
   no protocol https
   protocol unix-socket
   no shutdown
!
end
"
