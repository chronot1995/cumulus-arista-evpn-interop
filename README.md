### cumulus-arista-evpn-interop

### NOTES:

This repo is a work in progess

### Summary:

  - Cumulus Linux 3.7.8
  - Underlying Topology Converter to 4.7.0
  - Tested against Vagrant 2.1.5 on Mac and Linux. Windows is not supported
  - Tested against Virtualbox 5.2.32 on Mac 10.14
  - Tested against Libvirt 1.3.1 and Ubuntu 16.04 LTS
  - Tested against Arista vEOS 4.21.1.1F

### Description:

Two Linux servers, one Cumulus VX switch, and one Arista vEOS switch, configured with BGP and EVPN / VXLAN in a Cumulus / Arista interop.

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/cumulus-arista-evpn-interop/blob/master/documentation/cumulus-arista-evpn-interop.png)

### Install and Setup Virtualbox on Mac

Setup Vagrant for the first time on Mojave, MacOS 10.14.6

1. Install Homebrew 2.1.9 (This will also install Xcode Command Line Tools)

    https://brew.sh

2. Install Virtualbox (Tested with 5.2.32)

    https://www.virtualbox.org

I had to go through the install process twice to load the proper security extensions (System Preferences > Security & Privacy > General Tab > "Allow" on bottom)

3. Install Vagrant (Tested with 2.1.5)

    https://www.vagrantup.com

### Install and Setup Linux / libvirt demo environment:

First, make sure that the following is currently running on your machine:

1. This demo was tested on a Ubuntu 16.04 VM w/ 4 processors and 32Gb of Diagram

2. Following the instructions at the following link:

    https://docs.cumulusnetworks.com/cumulus-vx/Development-Environments/Vagrant-and-Libvirt-with-KVM-or-QEMU/

3. Download the latest Vagrant, 2.1.5, from the following location:

    https://www.vagrantup.com/

### Initializing the demo environment:

1. Copy the Git repo to your local machine:

    ```git clone https://github.com/chronot1995/cumulus-arista-evpn-interop```

2. Change directories to the following

    ```cumulus-arista-evpn-interop```

3a. Run the following for Virtualbox:

    ```./start-vagrant-vbox-poc.sh```

    Note: The Arista VM takes a little time to boot and may appear hung at the "SSH auth method: private key" message - give it a minute or two, it should work.

3b. Run the following for Libvirt:

    ```./start-vagrant-libvirt-poc.sh```

### Running the Ansible Playbook

1a. SSH into the Virtualbox oob-mgmt-server:

    ```cd vx-vbox-simulation```   
    ```vagrant ssh oob-mgmt-server```

1a. SSH into the Libvirt oob-mgmt-server:

    ```cd vx-libvirt-simulation```   
    ```vagrant ssh oob-mgmt-server```

2. Copy the Git repo unto the oob-mgmt-server:

    ```git clone https://github.com/chronot1995/cumulus-arista-evpn-interop```

3. Change directories to the following

    ```cumulus-arista-evpn-interop/automation```

4. Run the following:

    ```./provision.sh```

This will run the automation script and configure the environment.

### Cumulus Troubleshooting and Verification

Helpful VRF-enabled NCLU troubleshooting commands:

- net show route
- net show route vrf <name>
- net show bgp summary
- net show bgp vrf <name> summary
- net show interface | grep -i UP
- net show lldp

Helpful Linux troubleshooting commands:

- ip route
- ip link show
- ip address <interface>

One should see all of the routes in the default VRF with the following:

```
cumulus@switch01:mgmt-vrf:~$ net show route bgp
RIB entry for bgp
=================
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR,
       > - selected route, * - FIB route

B>* 10.2.2.2/32 [20/0] via 172.16.31.2, swp2, 00:01:58
  *                    via 172.16.31.6, swp3, 00:01:58

```

One can also view the VNIs that are established on all of the switches:

```
cumulus@switch01:mgmt-vrf:~$ net show evpn vni
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF
11         L2   vni11                 2        0        1               default
```

This will show all of the Type-2 and Type-3 routes coming from the Arista pod, AS65222. The MAC address of "44:38:39:00:00:01" is from server02 and learned via EVPN.

```
cumulus@switch01:mgmt-vrf:~$ net show bgp evpn route
BGP table version is 2, local router ID is 10.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-2 prefix: [2]:[ESI]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[ESI]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 65222:11
*> [2]:[0]:[0]:[48]:[44:38:39:00:00:01]
                    10.2.2.2                               0 65222 i
*  [2]:[0]:[0]:[48]:[44:38:39:00:00:01]
                    10.2.2.2                               0 65222 i
*> [3]:[0]:[32]:[10.2.2.2]
                    10.2.2.2                               0 65222 i
*  [3]:[0]:[32]:[10.2.2.2]
                    10.2.2.2                               0 65222 i
Route Distinguisher: 10.1.1.1:2
*> [2]:[0]:[0]:[48]:[44:38:39:00:00:05]
                    10.1.1.1                           32768 i
*> [3]:[0]:[32]:[10.1.1.1]
                    10.1.1.1                           32768 i
```

### Arista Troubleshooting and Verification

This will show the routes that are received via BGP from the Cumulus Linux switch.

```
switch02#show ip route bgp

VRF: default
Codes: C - connected, S - static, K - kernel,
       O - OSPF, IA - OSPF inter area, E1 - OSPF external type 1,
       E2 - OSPF external type 2, N1 - OSPF NSSA external type 1,
       N2 - OSPF NSSA external type2, B I - iBGP, B E - eBGP,
       R - RIP, I L1 - IS-IS level 1, I L2 - IS-IS level 2,
       O3 - OSPFv3, A B - BGP Aggregate, A O - OSPF Summary,
       NG - Nexthop Group Static Route, V - VXLAN Control Service,
       DH - DHCP client installed default route, M - Martian,
       DP - Dynamic Policy Route

 B E    10.1.1.1/32 [200/0] via 172.16.31.1, Ethernet2
                            via 172.16.31.5, Ethernet3
```

This will show that there are two eBGP connections established between AS65111, the Cumulus switch, and the Arista switch.

```
switch02#show bgp evpn summary
BGP summary information for VRF default
Router identifier 10.2.2.2, local AS number 65222
Neighbor Status Codes: m - Under maintenance
  Neighbor         V  AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State  PfxRcd PfxAcc
  172.16.31.1      4  65111            201       228    0    0 00:09:26 Estab  2      2
  172.16.31.5      4  65111            201       230    0    0 00:09:26 Estab  2      2
```
This will show all of the Type-2 and Type-3 routes coming from the Cumulus switch, AS65111. The MAC address of "44:38:39:00:00:05" is from server01 and learned via EVPN.

```
switch02#show bgp evpn vni 11
BGP routing table information for VRF default
Router identifier 10.2.2.2, local AS number 65222
Route status codes: s - suppressed, * - valid, > - active, # - not installed, E - ECMP head, e - ECMP
                    S - Stale, c - Contributing to ECMP, b - backup
                    % - Pending BGP convergence
Origin codes: i - IGP, e - EGP, ? - incomplete
AS Path Attributes: Or-ID - Originator ID, C-LST - Cluster List, LL Nexthop - Link Local Nexthop

         Network             Next Hop         Metric  LocPref Weight Path
 * >Ec   RD: 10.1.1.1:2 mac-ip 4438.3900.0005
                             10.1.1.1         -       100     0      65111 i
 *  ec   RD: 10.1.1.1:2 mac-ip 4438.3900.0005
                             10.1.1.1         -       100     0      65111 i
 * >Ec   RD: 10.1.1.1:2 imet 10.1.1.1
                             10.1.1.1         -       100     0      65111 i
 *  ec   RD: 10.1.1.1:2 imet 10.1.1.1
                             10.1.1.1         -       100     0      65111 i
 * >     RD: 65222:11 imet 10.2.2.2
                             -                -       -       0       i
```

A detailed looked at this table will show the Route Targets that are being received and imported from the Cumulus switch:

```
switch02#show bgp evpn detail
BGP routing table information for VRF default
Router identifier 10.2.2.2, local AS number 65222
BGP routing table entry for mac-ip 4438.3900.0005, Route Distinguisher: 10.1.1.1:2
 Paths: 2 available
  65111
    10.1.1.1 from 172.16.31.1 (10.1.1.1)
      Origin IGP, metric -, localpref 100, weight 0, valid, external, ECMP head, best, ECMP contributor
      Extended Community: Route-Target-AS:65111:11 TunnelEncap:tunnelTypeVxlan
      VNI: 11 ESI: 0000:0000:0000:0000:0000
```

### BUGS

1. There is an .iso file mounted as a DVD on the vEOS image. For whatever reason, it stays in the local directory when you do a ```vagrant destroy -f```

You will need to run the following:

```rm -rf $HOME/VirtualBox\ VMs/*_switch02```

2. switch02 requires a username and password to SSH into the device:

```
Username: cumulus
Password: CumulusLinux!
```

### Shout out / Thanks!

I would like to thank Jason Van Patten for his invaluable blog post and his time on Slack:

https://www.jasonvanpatten.com/2018/11/15/cumulus-and-arista-evpn-configuration/

### CAVEATS

1. You will need to download Arista'a vEOS 4.21.1.1F from their suppport website:

https://www.arista.com/en/support/software-download

This will require signing up at Arista's website.

2. Installing the vEOS Vagrant image

I ran the following command:

```vagrant box add veos.json```

Here is my veos.json file:

```
{
  "name": "vEOS-lab-4.21.1.1F",
  "description": "Arista vEOS",
  "versions": [
	{
	  "version": "4.21.1.1F",
	  "providers": [
		{
		  "name": "virtualbox",
		  "url": "file:///Volumes/USB/Arista/vEOS-lab-4.21.1.1F-virtualbox.box"
		}
	  ]
	}
  ]
}
```

The "url" path will be dependent on your machine.

On the Linux / Libvirt side, you need to "mutate" the file from Virtualbox to Libvirt. Here are the instructions that I used:

https://medium.com/@gamunu/use-vagrant-with-libvirt-unsupported-boxes-12e719d71e8e
