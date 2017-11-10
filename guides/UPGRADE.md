# Upgrading The TPCast To OpenTPCast

## Overview
This guide provides instructions on how to upgrade a stock TPCast device to OpenTPCast, which replaces the stock TPCast Connection Assistant software with a VirtualHere based solution running on Raspbian Stretch, and enables use of the on-board microphone and auxiliary USB port in the HTC Vive.

## Disclaimer
**This upgrade is performed at you own risk! OpenTPCast and its contributers will not be held responsible for any physical damage, data loss or voided manufacturer warranties incurred due to modification or tampering of your TPCast hardware or software.**

This upgrade requires opening up your TPCast power box to remove and flash the internal MicroSD card with an OpenTPCast image.  We do not recommend performing this upgrade without [backing up the MicroSD card of your TPCast power box](SDCARD.md) to ensure that your TPCast device can be [restored](SDCARD.md) back to factory settings in the event of software compatibility issues during or after the upgrade.

## Known Issues
- The HTC Vive camera currently does not function correctly with VirtualHere.

## Preparation
### Hardware
- A MicroSD card reader is required to backup and flash images to your MicroSD card on your computer.
- Your device may come included with a Class 4 MicroSD card.  A Class 10 MicroSD card is recommended to speed up TPCast boot times.

### Software
- Ensure that any TPCast software is not running on your local machine during or after the upgrade.
- Download and extract (using [7-Zip](http://www.7-zip.org/)) the latest [OpenTPCast](https://drive.google.com/uc?export=download&id=1t4KKQDUUPZh_tjGo-6Cu9oZ5H6smWItB) image.
- Download and install [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) on your local machine, which will be used to back up and restore images to and from a MicroSD card.
- Download & install [VirtualHere USB Client](https://virtualhere.com/usb_client_software) on your local machine, which will be used to forward the HTC Vive's USB devices over your local network.  Note that a TPCast-optimized licence key must be [purchased](https://www.virtualhere.com/tpcast_purchase) to use with VirtualHere USB Server after the upgrade.

## Installation
### Accessing The TPCast Power Box MicroSD Card
![Removing the MicroSD card from a TPCast power box](../img/tpcast-sdcard-removal.jpg)

Video:

[![Video - Removing the MicroSD card from a TPCast power box](https://img.youtube.com/vi/et4RxKuxeC4/0.jpg)](https://www.youtube.com/watch?v=et4RxKuxeC4)

1. Remove the battery, power cable and USB cable from the power box.
1. Unscrew the 4 screws from the battery facing side of the power box using a Phillips-head/Crosshead screwdriver.
1. Remove the grated plastic side of the casing by applying pressure inward and upward on the notch at the bottom of the power box.
1. Locate the MicroSD card near the bottom of the device and slide the card out of its socket with your finger.

### Backing Up The Stock TPCast MicroSD Card
![Backing up an image with Win32 Disk Imager](../img/win32diskimager-backup.jpg)
1. Connect the MicroSD card to your computer using a MicroSD card reader.
1. Launch Win32 Disk Imager.
1. In the "Image File" field, select a file path and enter a file name that will become your backup image. (e.g. C:/tpcast-backup.img).
1. Select the MicroSD drive from the Device drop down list.
1. Click "Read" to back up the image to your computer.
1. Store the backed up file somewhere safe, as it will be required to restore your TPCast back to factory settings in the event of software compatibility issues during or after the upgrade.

### Flashing The MicroSD Card With OpenTPCast
![Restoring an image with Win32 Disk Imager](../img/win32diskimager-flash.jpg)
1. Connect the MicroSD card to your computer using a MicroSD card reader.
1. Launch Win32 Disk Imager.
1. In the "Image File" field, select the OpenTPCast image that was downloaded and extracted (e.g. C:/opentpcast.img).
1. Select the MicroSD drive from the Device drop down list.
1. Click "Write" to flash the image to your MicroSD card.

### Reassembling The TPCast Power Box
1. Push the MicroSD card back into its socket.
1. Clip both sides of the plastic casing back together.
1. Screw the 4 screws back into the device.
1. Attach the USB cable, power cable and battery.

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

Any installed TPCast software should be left disabled or uninstalled while using VirtualHere USB Client.

## Optimizing Your TPCast Router For Tracking Performance
If you experience regular tracking issues, it may be nessecary to update the stock TPCast router to operate in "11a only" network mode.
1. Connect to the router at http://192.168.144.1 (CE) or http://192.168.1.1 (PRE)
    - Username: tproot (if prompted)
    - Password: 8427531 (CE) or 12345678 (PRE)
1. Navigate to WLAN Settings > Basic Settings > 5G and change Network Mode from "11vht AC/AN/A" to "11a only".
1. Click Save to apply the changes.

If you continue to experience tracking issues, you may have to select a different Channel by navigating to WLAN Settings > Basic Settings > 5G, and change Channel from "AutoSelect" to a different option.  The channel you select will vary based on region, outside interference and network configuration so try each channel until one works well for your setup.

Alternatively, using a more reliable router to overcome poor connection or bandwidth issues exhibited by the stock TPCast router may be an option.  The following routers have been tested with the TPCast upgrade and have shown to provide substantial improvements to tracking reliability over the stock TPCast router:
- Asus RT-AC68U
