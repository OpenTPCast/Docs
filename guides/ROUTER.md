# Optimizing The TPCast Router

## Connecting To The TPCast Router
The TPCast router control panel can be accessed from http://192.168.144.1 (CE) or http://192.168.1.1 (PRE) using a web browser and the following credentials:
- Username: tproot (if prompted)
- Password: 8427531 (CE) or 12345678 (PRE)

## Switching To Another Network Mode
If you experience regular tracking issues, it may be nessecary to update the stock TPCast router to operate in "11a only" network mode.
1. In the router control panel, navigate to `WLAN Settings` > `Basic Settings` > `5G` and change `Network Mode` from `11vht AC/AN/A` to `11a only`.
1. Click `Save` to apply the changes.

## Switching To Another Channel Frequency
If you continue to experience tracking issues, you may have to select a different channel.  The channel you select will vary based on region, outside interference and network configuration so try each channel until one works well for your setup.
1. In the router control panel, navigate to `WLAN Settings` > `Basic Settings` > `5G`, and change `Channel` from `AutoSelect` to a different option.
1. Click `Save` to apply the changes.

## Using A Different Router
Alternatively, using a more reliable router to overcome poor connection or bandwidth issues exhibited by the stock TPCast router may be an option.  The following routers have been tested by community members with the OpenTPCast upgrade and have shown to work as suitable replacements to the TPCast router:
- Asus RT-AC68U
- D-Link AC1750
- Linksys WRT1900ACS
- Netgear WNDR3700

## Customizing Wi-Fi Credentials For OpenTPCast Devices
Custom Wi-Fi credentials can be set for additional security.

### Updating The TPCast Router Credentials
1. In the router control panel, navigate to `WLAN Settings` > `Security Settings` > `5G` and change the `SSID` and `Password` fields to the desired credentials.
1. Click `Save` to apply the changes.

### Updating The TPCast Power Box Credentials
1. [Remove the MicroSD card](https://github.com/OpenTPCast/Docs/blob/master/guides/SDCARD.md#accessing-the-microsd-card) from your TPCast power box, insert the MicroSD card into your computer and locate the boot partition in My Computer/This PC.
1. In the boot drive, edit the file `opentpcast.txt` in Notepad, uncomment and amend the `ssid` and `passphrase` with the desired credentials, then save the file.
```
ssid=MyHomeNetwork
passphrase=MySecretPassword
```
1. Create an empty file in the boot partition called `initwlan` if the file does not exist, [ensuring that there is no file extension](https://support.microsoft.com/en-gb/help/865219/how-to-show-or-hide-file-name-extensions-in-windows-explorer).
1. Remove the MicroSD card from the computer and insert the MicroSD back into the TPCast power box.
