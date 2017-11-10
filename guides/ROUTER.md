# Optimizing The TPCast Router For Tracking Performance

## Connecting To The TPCast Router
The TPCast router control panel can be accessed from http://192.168.144.1 (CE) or http://192.168.1.1 (PRE) using a web browser and the following credentials:
    - Username: tproot (if prompted)
    - Password: 8427531 (CE) or 12345678 (PRE)

## Switching To Another Network Mode
If you experience regular tracking issues, it may be nessecary to update the stock TPCast router to operate in "11a only" network mode.
1. In the router control panel, navigate to WLAN Settings > Basic Settings > 5G and change Network Mode from "11vht AC/AN/A" to "11a only".
1. Click Save to apply the changes.

## Switching To Another Channel Frequency
If you continue to experience tracking issues, you may have to select a different channel.  The channel you select will vary based on region, outside interference and network configuration so try each channel until one works well for your setup.
1. In the router control panel, navigate to WLAN Settings > Basic Settings > 5G, and change Channel from "AutoSelect" to a different option.
1. Click Save to apply the changes.

## Using A Different Router
Alternatively, using a more reliable router to overcome poor connection or bandwidth issues exhibited by the stock TPCast router may be an option.  The following routers have been tested with the OpenTPCast upgrade and have shown to provide substantial improvements to tracking reliability over the stock TPCast router:
- Asus RT-AC68U
