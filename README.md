### cumulus-arista-evpn-interop

Two Linux servers, one Cumulus VX switch, and one Arista vEOS switch configured with BGP and EVPN / VXLAN

### WORK IN PROGRESS

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/cumulus-arista-evpn-interop/blob/master/documentation/cumulus-arista-evpn-interop.png)

### Cumulus Troubleshooting and Verification

### Arista Troubleshooting and Verification

### BUGS

The .iso file that is attached

After a "vagrant destroy -f", you will need to run the following:

```rm -rf $HOME/VirtualBox VMs/*_switch02```

### Thanks!

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
