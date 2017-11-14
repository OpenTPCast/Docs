# Upgrading The TPCast To OpenTPCast

## Overview
This guide provides instructions on how to upgrade a stock TPCast device to OpenTPCast, which replaces the stock TPCast Connection Assistant software with a VirtualHere based solution running on Raspbian Stretch, and enables use of the on-board microphone and auxiliary USB port in the HTC Vive.

## Known Issues
- The HTC Vive camera currently does not function correctly with VirtualHere.

## Disclaimer
**This upgrade is performed at your own risk! OpenTPCast and its contributers will not be held responsible for any physical damage, data loss or voided manufacturer warranties incurred due to modification or tampering of your TPCast hardware or software.**

This upgrade requires opening up your TPCast power box to remove and flash the internal MicroSD card with an OpenTPCast image.  We do not recommend performing this upgrade without [backing up the MicroSD card of your TPCast power box](SDCARD.md) to ensure that your TPCast device can be [restored](SDCARD.md#restoring-an-image-to-a-microsd-card) back to factory settings in the event of software compatibility issues during or after the upgrade.

## Preparation
### Hardware
- Ensure that your TPCast is functioning correctly with the stock router and software before attempting the upgrade.
- A MicroSD card reader is required to backup and flash images to your MicroSD card on your computer.
- A small phillips/crossheaded screwdriver is required to open the TPCast power box.
- Your device may come included with a Class 4 MicroSD card.  A Class 10 MicroSD card is recommended to speed up TPCast boot times.

### Software
- Ensure that any TPCast software is not running on your local machine during or after the upgrade.
- Ensure that you have at least 8GB of free space on your local machine during the upgrade to back up the TPCast MicroSD card.
- Download and extract (using [7-Zip](http://www.7-zip.org/)) the latest [OpenTPCast](https://github.com/OpenTPCast/Docs/releases) image.
- Download and install [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) on your local machine, which will be used to back up and restore images to and from a MicroSD card.
- Download & install [VirtualHere USB Client](https://virtualhere.com/usb_client_software) on your local machine, which will be used to forward the HTC Vive's USB devices over your local network.  Note that a TPCast-optimized licence key must be [purchased](https://www.virtualhere.com/tpcast_purchase) to use with VirtualHere USB Server after the upgrade.

## Installation
### Accessing The TPCast Power Box MicroSD Card
![Removing the MicroSD card from a TPCast power box](../img/tpcast-sdcard-removal.jpg)

Video:

[![Video - Removing the MicroSD card from a TPCast power box](../img/sdcardremoval-video.jpg)](https://www.youtube.com/watch?v=rosli1DYzLc)

1. Remove the battery, power cable and USB cable from the power box.
1. Unscrew the 4 screws from the battery facing side of the power box using a Phillips-head/Crosshead screwdriver.
1. Remove the grated plastic side of the casing by applying pressure inward and upward on the notch at the bottom of the power box.
1. Locate the MicroSD card near the bottom of the device and slide the card out of its socket with your finger.

### Backing Up The Stock TPCast MicroSD Card
![Backing up an image with Win32 Disk Imager](../img/win32diskimager-backup.jpg)
1. Connect the MicroSD card to your computer using a MicroSD card reader.
    - Ignore any warnings about the MicroSD card being corrupt or unreadable - this is normal due to Windows being unable to read Linux partitions natively.
1. Launch Win32 Disk Imager.
1. In the "Image File" field, select a file path and enter a file name that will become your backup image. (e.g. C:/tpcast-backup.img).
1. Select the MicroSD drive from the Device drop down list.
1. Click "Read" to back up the image to your computer.  This will produce a file approximately 8GB in size.
1. Store the backed up file somewhere safe, as it will be required to restore your TPCast back to factory settings in the event of software compatibility issues during or after the upgrade.

### Flashing The MicroSD Card With OpenTPCast
![Restoring an image with Win32 Disk Imager](../img/win32diskimager-flash.jpg)
1. Connect the MicroSD card to your computer using a MicroSD card reader.
    - Ignore any warnings about the MicroSD card being corrupt or unreadable - this is normal due to Windows being unable to read Linux partitions natively.
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
![Applying licence to VirtualHere USB Client](../img/virtualhere-licence.jpg)
1. Once the TPCast device is listed in VirtualHere, you can then [purchase](https://www.virtualhere.com/tpcast_purchase) and apply your VirtualHere USB Server unlimited licence key in VirtualHere USB Client by right clicking on USB Hubs > Licence, select Enter Licence(s) and copy your licence key from the email received following purchase.
    - Note That you cannot purchase a licence until you have a serial number which won't appear in Licences until TPCast shows up under USB Hubs.
1. Right click on USB Hubs then select "Install Client as a Service" and click OK.
1. Relaunch VirtualHere USB Client, expand USB Hubs, expand TPCast, then right click and select "Auto-Use Device/Port" for each of the following devices:
    - HTC Vive
    - Lighthouse FPGA RX
    - Watchman Dongle
    - Watchman Dongle
    - USB Audio Device
        - This should be used if available to enable microphone support for older revisions of HTC Vive.
    - Vive Camera
        - This should only be used when "USB Audio Device" is not available to enable microphone support for newer revisions of the HTC Vive, and the camera should be disabled while running SteamVR to avoid stability issues.

If you would prefer SteamVR to launch automatically when the TPCast power box is turned on, follow these steps:
1. In VirtualHere USB Client, expand "USB Hubs", then expand "TPCast".
1. Right click "Lighthouse FPGA RX", select "Custom Event Handler..." and enter the following command:
```onClientAfterBind.$VENDOR_ID$.$PRODUCT_ID$=for /F "Tokens=1,2*" %A in ('Reg Query HKCU\SOFTWARE\Valve\Steam') do (if "%A" equ "SteamPath" (start "" "%C\steamapps\common\SteamVR\bin\win64\vrstartup.exe"))```

## Using Your TPCast After Upgrading
To load up your TPCast on future play sessions, plug in the TPCast, wait a few minutes (checking VirtualHere USB Client if nessecary to see if the TPCast is ready), then launch SteamVR.

Any installed TPCast software should be left disabled or uninstalled while using VirtualHere USB Client.

If you experience tracking issues after upgrading, try [switching Wi-Fi channels](ROUTER.md) or [network mode](ROUTER.md) in your TPCast router.
