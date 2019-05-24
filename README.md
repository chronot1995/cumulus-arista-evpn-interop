### cumulus-arista-evpn-interop

Two Linux servers, one Cumulus VX switch, and one Arista vEOS switch, configured with BGP and EVPN / VXLAN in a Cumulus / Arista interop.

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/cumulus-arista-evpn-interop/blob/master/documentation/cumulus-arista-evpn-interop.png)

### Initializing the demo environment:

First, make sure that the following is currently running on your machine:

1. Vagrant > version 2.1.5

    https://www.vagrantup.com/

2. Virtualbox > version 5.2.20

    https://www.virtualbox.org

3. Copy the Git repo to your local machine:

    ```git clone https://github.com/chronot1995/cumulus-arista-evpn-interop```

4. Change directories to the following

    ```cumulus-arista-evpn-interop```

6. Run the following:

    ```./start-vagrant-poc.sh```

### Running the Ansible Playbook

1. SSH into the oob-mgmt-server:

    ```cd vx-simulation```   
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

### BUGS

1. There is an .iso file mounted as a DVD on the vEOS image. For whatever reason, it stays in the local directory when you do a ```vagrant destroy -f```

You will need to run the following:

```rm -rf $HOME/VirtualBox VMs/*_switch02```

2. switch02 requires a username and password to SSH into the device:

Username: cumulus
Password: CumulusLinux!

### Shout out / Thanks!

I would like to thank Jason Van Patten for his invaluable blog post and his time on Slack:

https://www.jasonvanpatten.com/2018/11/15/cumulus-and-arista-evpn-configuration/

### CAVEATS

1. You will need to download the latest version of Arista'a vEOS from their website:

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
