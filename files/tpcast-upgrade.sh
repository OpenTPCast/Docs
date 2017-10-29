#!/bin/bash

# ---------------------------------------------------------
# |                                                       |
# |                 TPCast Upgrade Script                 |
# |                   Installation Guide                  |
# |                                                       |
# ---------------------------------------------------------

# Overview:
# This guide provides instructions on how to upgrade a TPCast to Raspbian Stretch with Kernel 4.9+ and VirtualHere, which replaces the stock TPCast Connection Assistant software with a VirtualHere based solution, and enables use of the on-board microphone and auxiliary USB port in the HTC Vive.

# Preparation:
# This upgrade is not reversible, so it is STRONGLY RECOMMENDED that you BACKUP the MicroSD card of your TPCast power box so that it can be restored in the event that something goes wrong during the upgrade, or you want to restore back to the original factory state.  This requires removing the plastic covering of the TPCast power box (remove the 4 screws from the battery facing side and pry the grated plastic side off), removing the MicroSD and backing it up using a MicroSD card reader and cloning software such as Win32DiskImager (https://sourceforge.net/projects/win32diskimager/).
# Ensure that any TPCast software is NOT RUNNING on your local machine during the upgrade.
# Ensure that your TPCast power box battery is FULLY CHARGED and POWERED ON before attempting the upgrade.  Depending on your connection speed, it may be nessecary to disconnect the USB/power cables from the TPCast power box during the upgrade to further extend battery life.
# Download & install Squid (http://squid.diladele.com/ for Windows, check https://wiki.squid-cache.org/SquidFaq/BinaryPackages for other platforms) on your local machine.
# Download & install Putty SSH client (http://www.putty.org/ for Windows, use ssh command in other platforms) on your local machine.
# Download & install VirtualHere USB Client (https://virtualhere.com/usb_client_software).  Note that a TPCast-optimized licence key must be purchased to use with VirtualHere USB Server after the upgrade (https://www.virtualhere.com/tpcast_purchase).
# If you are a TPCast PRE user, you must replace all references to [ 192.168.144. ] with [ 192.168.1. ] in any steps mentioned during this guide.
# If you own a USB to Ethernet adapter, you may alternatively skip installation of Squid Proxy Server and plug in a USB to Ethernet adapter to the USB port of the TPCast power box, and connect it to your own internet-enabled router, which will greatly improve download speeds during the upgrade.

# Installation:
# Launch your SSH client and connect with the following details:
# Hostname: 192.168.144.88 (CE) or http://192.168.1.88 (PRE)
# Port: 22
# Username: pi
# Password: 1qaz2wsx3edc4rfv

# In your SSH client, run the following command if you opted to install Squid Proxy Server:
# sudo wget -e check_certificate=off -e use_proxy=yes -e https_proxy=https://$(echo $SSH_CONNECTION | awk '{print $1}'):3128 https://rawgit.com/NGenesis/Docs/master/files/tpcast-upgrade.sh && sudo chmod +x ./tpcast-upgrade.sh && sudo ./tpcast-upgrade.sh $(echo $SSH_CONNECTION | awk '{print $1}')

# In your SSH client, run the following command if you opted to use a USB to Ethernet adapter in place of Squid Proxy Server:
# sudo wget https://rawgit.com/NGenesis/Docs/master/files/tpcast-upgrade.sh && sudo chmod +x ./tpcast-upgrade.sh && sudo ./tpcast-upgrade.sh

# After the upgrade has finished (in approximately 1-2 hours), launch VirtualHere USB Client on your local machine and wait a few minutes following the reboot notification.  If your VirtualHere client does not detect the TPCast after 5 minutes following the reboot, remove and reinsert the battery to the power box and wait a further 5 minutes.

# Configuring VirtualHere for TPCast:
# Purchase and apply your VirtualHere USB Server unlimited licence key in VirtualHere USB Client by selecting Licence, Enter Licence(s) and copy your licence key from the email received following purchase.
# In VirtualHere USB Client, expand USB Hubs, expand TPCast, then right click and select "Auto-Use Device/Port" for each of the following devices:
# - HTC Vive
# - Lighthouse FPGA RX
# - Watchman Dongle
# - Watchman Dongle
# - USB Audio Device
# Right click on USB Hubs then select Install Client Service.

# Launching TPCast:
# To load up your TPCast on future play sessions, plug in the TPCast, wait a few minutes (checking VirtualHere USB Client if nessecary to see if the TPCast is ready), then launch SteamVR.

# Clean Up:
# Any TPCast software should be left disabled or uninstalled while using VirtualHere USB Client.
# Squid and Putty are no longer needed once everything is confirmed as working correctly and can be safely uninstalled from your local machine.

# Performance Optimizations:
# If you experience regular tracking issues, it may be nessecary to update the stock TPCast router to operate in "11a only" network mode.
# Connect to the router at http://192.168.144.1 (CE) or http://192.168.1.1 (PRE)
# Username: tproot (if prompted)
# Password: 8427531 (CE) or 12345678 (PRE)
# Navigate to WLAN Settings > Basic Settings > 5G and change Network Mode from "11vht AC/AN/A" to "11a only".
# Click Save to apply the changes.

# If you continue to experience tracking issues, you may have to select a different Channel by navigating to WLAN Settings > Basic Settings > 5G, and change Channel from "AutoSelect" to a different option.  The channel you select will vary based on region, outside interference and network configuration so try each channel until one works well for your setup.

# Alternatively, using a more reliable router to overcome poor connection or bandwidth issues exhibited by the stock TPCast router may be an option.  The following routers have been tested with the TPCast upgrade and have shown to provide substantial improvements to tracking reliability over the stock TPCast router:
# - Asus RT-AC68U

# ---------------------------------------------------------

# Stop on errors
set -e

if [[ $# -eq 0 ]]; then
	logger "No host proxy server IP address was provided, assume internet connection is available."
	echo 'No host proxy server IP address was provided, assume internet connection is available.'
else
	# Configure updates over proxy server
	HOST_PROXY_IP=$1
	logger "Configuring proxy server settings for $HOST_PROXY_IP:3128"

	if [ -f /etc/apt/apt.conf.d/10proxy ]; then
		sudo rm /etc/apt/apt.conf.d/10proxy
	fi

	echo -e "Acquire::http::Proxy \"http://$HOST_PROXY_IP:3128/\";" | sudo tee -a /etc/apt/apt.conf.d/10proxy > /dev/null

	if [ ! -f /etc/wgetrc.bak ]; then
		sudo cp /etc/wgetrc /etc/wgetrc.bak
		echo -e "check_certificate = off\nuse_proxy = on\nhttp_proxy = http://$HOST_PROXY_IP:3128\nhttps_proxy = https://$HOST_PROXY_IP:3128" | sudo tee -a /etc/wgetrc > /dev/null
	fi

	if [ ! -f /etc/environment.bak ]; then
		sudo cp /etc/environment /etc/environment.bak
		echo -e "http_proxy=http://$HOST_PROXY_IP:3128\nhttps_proxy=https://$HOST_PROXY_IP:3128\nexport http_proxy https_proxy" | sudo tee -a /etc/environment > /dev/null
	fi

	export http_proxy=http://$HOST_PROXY_IP:3128
	export https_proxy=https://$HOST_PROXY_IP:3128
fi

logger "TPCast upgrade is starting..."
echo "------------------------------------------------------"
echo "|                                                    |"
echo "|                   TPCast Upgrade                   |"
echo "|                 Beginning Upgrade...               |"
echo "|                                                    |"
echo "------------------------------------------------------"
echo "Please wait while the TPCast is upgraded, this process is will take approximately 1-2 hours depending on your internet connection speed."

# Upgrade Raspian distro repositories (/etc/apt/sources.list /etc/apt/sources.list.d/raspi.list)
logger "Upgrading Raspian distro repositories to Stretch (/etc/apt/sources.list /etc/apt/sources.list.d/raspi.list)"
find /etc/apt -name "*.list" | sudo xargs sed -i -r '/^#*deb/s/jessie/stretch/g'

# Disable prompts during anattended upgrade
logger "Disabling prompts during anattended upgrade"
if [ ! -f /etc/ucf.conf.bak ]; then
	sudo cp /etc/ucf.conf /etc/ucf.conf.bak
	echo 'conf_force_conffold=YES' | sudo tee -a /etc/ucf.conf > /dev/null
fi

logger "Downloading and installing updates to Rapsian Stretch..."
unset UCF_FORCE_CONFFNEW && export UCF_FORCE_CONFFOLD=YES && export DEBIAN_FRONTEND=noninteractive && export APT_LISTCHANGES_FRONTEND=none && export DEBIAN_PRIORITY=critical && 
sudo apt-get remove apt-listchanges --assume-yes --force-yes && 
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections && 

# Upgrade Rapsian distro
sudo apt-get --force-yes -fuy autoremove && 
sudo apt-get --force-yes clean && 
sudo apt-get update && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" --purge -fuy autoremove && 
sudo apt-get --force-yes clean

# Upgrade kernel
logger "Upgrading kernel to 4.9..."
sudo sed -i 's/kernel=kernel_new_defcfg.img/kernel=kernel7.img/g' /boot/config.txt

# Optimize for faster boot time
logger "Optimizing for faster boot time"
sudo sed -i 's/rootwait/rootwait quiet/g' /boot/cmdline.txt

# Disable tpusbd service and old driver insertion boot script
logger "Disabling tpusbd service and old driver insertion boot script"
if [ -f /etc/init.d/wlan-load.sh ]; then
	sudo rm /etc/init.d/wlan-load.sh > /dev/null 2>&1 || true
	sudo update-rc.d -f wlan-load.sh remove > /dev/null 2>&1 || true
fi

# Configure WLAN interface
logger "Configuring WLAN interface wlan0"
sudo sed -i '/country=GB/d' /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase "$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)" "$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
echo -e "interface wlan0\nstatic ip_address=$(ip route show | grep -i 'default via.*wlan0'| awk '{print $7 }')/24\nstatic routers=$(ip route show | grep -i 'default via.*wlan0'| awk '{print $3 }')\nstatic domain_name_servers=$(ip route show | grep -i 'default via.*wlan0'| awk '{print $3 }')" | sudo tee -a /etc/dhcpcd.conf > /dev/null

# Upgrade WLAN driver
logger "Upgrading WLAN driver and firmware for rtl8192du"
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw.bin
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw_wol.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw_wol.bin
sudo wget -O /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko https://rawgit.com/OpenTPCast/Docs/master/files/8192du-$(ls -1 /lib/modules | tail -1)-stretch.ko
echo '8192du' | sudo tee -a /etc/modules > /dev/null
sudo depmod -a $(ls -1 /lib/modules | tail -1) > /dev/null 2>&1 || true

# Install VirtualHere USB Server (Server licence must be purchased from https://www.virtualhere.com/tpcast_purchase to use)
logger "Installing VirtualHere USB Server"
sudo wget https://www.virtualhere.com/sites/default/files/usbserver/vhusbdtpcast
sudo chmod +x ./vhusbdtpcast
sudo mv vhusbdtpcast /usr/sbin
sudo wget http://www.virtualhere.com/sites/default/files/usbserver/scripts/vhusbdpin
sudo chmod +x ./vhusbdpin
sudo sed -i 's/vhusbdarm/vhusbdtpcast/g' ./vhusbdpin
sudo mv vhusbdpin /etc/init.d > /dev/null 2>&1 || true
sudo update-rc.d vhusbdpin defaults > /dev/null 2>&1 || true

# Configure VirtualHere USB Server for TPCast devices
# HMD camera has custom event handler onReset.$VENDOR_ID$.$PRODUCT_ID$=
echo -e "ServerName=TPCast\nonReset.0bb4.2c87=\nDeviceNicknames=Vive Camera,0bb4,2c87,1122" | sudo tee /root/config.ini > /dev/null

# Restore proxy server and unattended install overrides to defaults
logger "Restoring proxy server and unattended install overrides to defaults"
if [ -f /etc/apt/apt.conf.d/10proxy ]; then
	sudo rm /etc/apt/apt.conf.d/10proxy
fi

if [ -f /etc/wgetrc.bak ]; then
	sudo mv /etc/wgetrc.bak /etc/wgetrc
fi

if [ -f /etc/ucf.conf.bak ]; then
	sudo mv /etc/ucf.conf.bak /etc/ucf.conf
fi

if [ -f /etc/environment.bak ]; then
	sudo mv /etc/environment.bak /etc/environment
fi

logger "TPCast upgrade has finished, rebooting to finalize..."
echo "------------------------------------------------------"
echo "|                                                    |"
echo "|                   TPCast Upgrade                   |"
echo "|            Upgrade Finished, Rebooting...          |"
echo "|                                                    |"
echo "------------------------------------------------------"
echo -e "TPCast upgrade has finished, please wait while the TPCast power box reboots automatically to finalize the upgrade...\nYou can now launch VirtualHere USB Client on your local machine if you have not already done so.  If VirtualHere USB Client does not detect the TPCast after 5 minutes following the reboot, please remove and reinsert the battery to the power box and wait a further 5 minutes."

# Reboot for changes to take effect
sudo reboot now
