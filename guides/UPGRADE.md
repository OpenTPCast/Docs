# Upgrading TPCast For Raspbian Stretch & VirtualHere

## Overview
This guide provides instructions on how to upgrade a TPCast to Raspbian Stretch with Kernel 4.9+ and [VirtualHere](VIRTUALHERE.md), which replaces the stock TPCast Connection Assistant software with a VirtualHere based solution, and enables use of the on-board microphone and auxiliary USB port in the HTC Vive.

## Disclaimer
**This upgrade is performed at you own risk! OpenTPCast and its contributers will not be held responsible for any physical damage or data loss incurred due to modifications or tampering of your TPCast hardware or software.**

If the upgrade fails and leaves your device inoperable, please refer to [Unbricking](UNBRICKING.md) for more information on how to restore your device to its original factory state.  We do not recommend attempting this upgrade if you are unable to, or are unwilling to open up your TPCast power box to remove and [back up the internal MicroSD card](SDCARD.md).

## Known Issues
- The HTC Vive camera currently does not function correctly with VirtualHere.
- The US/EU version of the TPCast is known to have hardware and software differences which are currently not supported by this upgrade process.  **Do not attempt to upgrade a US/EU version of the TPCast or you will brick your device!**

## Preparation
### Prepare Your TPCast
- Ensure that you have a **BACKUP** of your TPCast power box MicroSD card.  This upgrade is not reversible, so it is strongly recommended that you [back up the MicroSD card of your TPCast power box](SDCARD.md) so that it can be restored in the event that something goes wrong during the upgrade, or you want to restore back to the original factory state.
- Ensure that any TPCast software is **NOT RUNNING** on your local machine during the upgrade.
- Ensure that your TPCast power box battery is **FULLY CHARGED** and **POWERED ON** before attempting the upgrade.  Depending on your connection speed, it may be nessecary to disconnect the USB/power cables from the TPCast power box during the upgrade to further extend battery life.

### Prerequisite Software
- Download & install [Squid](http://squid.diladele.com/) on your local machine, which will act as a proxy server allowing your TPCast power box to temporarily connect to the internet to download updates and files needed to perform the upgrade.
- Download & install [Putty SSH client](http://www.putty.org/) on your local machine, which will be used to connect to your TPCast power box.
- Download & install [VirtualHere USB Client](https://virtualhere.com/usb_client_software) on your local machine, which will be used to forward the HTC Vive's USB devices over your local network.  Note that a TPCast-optimized licence key must be [purchased](https://www.virtualhere.com/tpcast_purchase) to use with VirtualHere USB Server after the upgrade.

### Other Steps To Consider
- If you own a USB to Ethernet adapter, you may alternatively skip installation of Squid Proxy Server and plug in a USB to Ethernet adapter to the USB port of the TPCast power box or auxiliary USB port inside the HTC Vive headset, and connect it to your own internet-enabled router, which can greatly improve download speeds during the upgrade.

## Installation
### Connecting To The TPCast Power Box
Power up the TPCast power box by plugging in the battery and wait a few minutes, then launch your SSH client and connect with the following details:
  - Hostname: 192.168.144.88 (CE) or 192.168.1.88 (PRE)
  - Port: 22
  - Username: pi
  - Password: 1qaz2wsx3edc4rfv

### Begin The Upgrade Process
- In your SSH client, run the following command if you opted to install Squid Proxy Server:
```bash
sudo wget -e check_certificate=off -e use_proxy=yes -e https_proxy=https://$(echo $SSH_CONNECTION | awk '{print $1}'):3128 https://rawgit.com/OpenTPCast/Docs/master/files/tpcast-upgrade.sh && sudo chmod +x ./tpcast-upgrade.sh && sudo ./tpcast-upgrade.sh $(echo $SSH_CONNECTION | awk '{print $1}')
```

- In your SSH client, run the following command if you opted to use a USB to Ethernet adapter in place of Squid Proxy Server:
```bash
sudo wget https://rawgit.com/OpenTPCast/Docs/master/files/tpcast-upgrade.sh && sudo chmod +x ./tpcast-upgrade.sh && sudo ./tpcast-upgrade.sh
```

Once the upgrade has finished (in approximately 1-2 hours), launch VirtualHere USB Client on your local machine and wait a few minutes following the reboot notification.  If your VirtualHere client does not detect the TPCast after 5 minutes following the reboot, remove and reinsert the battery to the power box and wait a further 5 minutes.

## Configuring VirtualHere For TPCast
1. [Purchase](https://www.virtualhere.com/tpcast_purchase) and apply your VirtualHere USB Server unlimited licence key in VirtualHere USB Client by selecting Licence, Enter Licence(s) and copy your licence key from the email received following purchase.
1. In VirtualHere USB Client, expand USB Hubs, expand TPCast, then right click and select "Auto-Use Device/Port" for each of the following devices:
    - HTC Vive
    - Lighthouse FPGA RX
    - Watchman Dongle
    - Watchman Dongle
    - USB Audio Device
        - This should be used if available to enable microphone support for older revisions of HTC Vive.
    - Vive Camera
        - This should only be used when "USB Audio Device" is not available to enable microphone support for newer revisions of the HTC Vive, and the camera should be disabled while running SteamVR to avoid stability issues.
1. Right click on USB Hubs then select Install Client Service.

## Using Your TPCast After Upgrading
To load up your TPCast on future play sessions, plug in the TPCast, wait a few minutes (checking VirtualHere USB Client if nessecary to see if the TPCast is ready), then launch SteamVR.

## Cleaning Up After Upgrading
Any TPCast software should be left disabled or uninstalled while using VirtualHere USB Client.
Squid and Putty are no longer needed once everything is confirmed as working correctly and can be safely uninstalled from your local machine.

## Optimizing Your TPCast Router For Tracking Performance:
If you experience regular tracking issues, it may be nessecary to update the stock TPCast router to operate in "11a only" network mode.
1. Connect to the router at http://192.168.144.1 (CE) or http://192.168.1.1 (PRE)
    - Username: tproot (if prompted)
    - Password: 8427531 (CE) or 12345678 (PRE)
1. Navigate to WLAN Settings > Basic Settings > 5G and change Network Mode from "11vht AC/AN/A" to "11a only".
1. Click Save to apply the changes.

If you continue to experience tracking issues, you may have to select a different Channel by navigating to WLAN Settings > Basic Settings > 5G, and change Channel from "AutoSelect" to a different option.  The channel you select will vary based on region, outside interference and network configuration so try each channel until one works well for your setup.

Alternatively, using a more reliable router to overcome poor connection or bandwidth issues exhibited by the stock TPCast router may be an option.  The following routers have been tested with the TPCast upgrade and have shown to provide substantial improvements to tracking reliability over the stock TPCast router:
- Asus RT-AC68U
