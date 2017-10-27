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
# This upgrade is not reversible, so it is HIGHLY RECOMMENDED that you BACKUP the MicroSD card of your TPCast power box so that it can be restored in the event that something goes wrong during the upgrade, or you want to restore back to the original factory state.  This requires removing the plastic covering of the TPCast power box (remove the 4 screws from the battery facing side and pry the grated plastic side off), removing the MicroSD and backing it up using a MicroSD card reader and cloning software such as Win32DiskImager (https://sourceforge.net/projects/win32diskimager/).
# Ensure that any TPCast software is NOT RUNNING on your local machine during the upgrade.
# Ensure TPCast power box battery is FULLY CHARGED and POWERED ON before attempting the upgrade.
# Download & install Squid (http://squid.diladele.com/ for Windows, check https://wiki.squid-cache.org/SquidFaq/BinaryPackages for other platforms) on your local machine.
# Download & install Putty SSH client (http://www.putty.org/ for Windows, use ssh command in other platforms) on your local machine.
# Download & install VirtualHere USB Client (https://virtualhere.com/usb_client_software).  Note that an unlimited licence key must be purchased to use with VirtualHere USB Server after the upgrade.
# If you are a TPCast PRE user, you must replace all references to [ 192.168.144. ] with [ 192.168.0. ] in the upgrade script and any steps mentioned during this guide before attempting the upgrade.

# Installation:
# Launch your SSH client and connect with the following details:
# Hostname: 192.168.144.88
# Port: 22
# Username: pi
# Password: 1qaz2wsx3edc4rfv

# In your SSH client, run the following commands, substituting [ 192.168.144.XXX ] with the IP address of your local machine that is connected to the TPCast Router:
# sudo wget -e check_certificate=off -e use_proxy=yes -e https_proxy=https://192.168.144.XXX:3128 https://rawgit.com/NGenesis/Docs/master/files/tpcast-upgrade.sh
# sudo chmod +x ./tpcast-upgrade.sh
# sudo ./tpcast-upgrade.sh 192.168.144.XXX

# After the upgrade has finished (in approximately 1-2 hours), launch VirtualHere USB Client on your local machine and wait a few minutes following the reboot notification.  If your VirtualHere client does not detect the TPCast after 5 minutes following the reboot, remove and reinsert the battery to the power box and wait a further 5 minutes.

# Configuring VirtualHere for TPCast:
# Purchase and apply your VirtualHere USB Server unlimited licence key in VirtualHere USB Client by selecting Licence, Enter Licence(s) and copy your licence key from the email received following purchase.
# In VirtualHere USB Client, select TPCast, then right click and select "Auto-Use Device/Port" for each of the following devices:
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
sudo rm /etc/init.d/wlan-load.sh
sudo update-rc.d -f wlan-load.sh remove

# Upgrade WLAN driver
logger "Upgrading WLAN driver and firmware for rtl8192du"
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw.bin
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw_wol.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw_wol.bin
sudo wget -O /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko https://rawgit.com/OpenTPCast/Docs/master/files/8192du-$(ls -1 /lib/modules | tail -1)-stretch.ko
echo '8192du' | sudo tee -a /etc/modules > /dev/null

# Configure WLAN interface
logger "Configuring WLAN interface wlan0"
sudo sed -i '/country=GB/d' /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase "$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)" "$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
echo -e "interface wlan0\nstatic ip_address=192.168.144.88/24\nstatic routers=192.168.144.1\nstatic domain_name_servers=192.168.144.1" | sudo tee -a /etc/dhcpcd.conf > /dev/null

# Create script to initialize WLAN driver on first boot
logger "Creating script to initialize WLAN driver on first boot"
echo -e "#\0041/bin/bash\n### BEGIN INIT INFO\n# Provides:          8192du-init.sh\n# Required-Start:    $all\n# Required-Stop:     $all\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: Initialize 8192du WLAN kernel module on first boot\n# Description:       Initialize 8192du WLAN kernel module on first boot\n### END INIT INFO\nlogger \"Finalizing Wi-Fi driver installation...\"\nsudo insmod /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko\nsudo depmod -a\nsudo modprobe 8192du\nrm \$0\nsudo update-rc.d -f 8192du-init.sh remove\nlogger \"Wi-Fi driver installation complete.\"" | sudo tee -a /etc/init.d/8192du-init.sh > /dev/null
sudo chmod +x /etc/init.d/8192du-init.sh
sudo update-rc.d 8192du-init.sh defaults

# Install VirtualHere USB Server (Server licence must be purchased from https://virtualhere.com to use)
logger "Installing VirtualHere USB Server"
sudo wget https://www.virtualhere.com/sites/default/files/usbserver/vhusbdarmpi3
sudo chmod +x ./vhusbdarmpi3
sudo mv vhusbdarmpi3 /usr/sbin
sudo wget http://www.virtualhere.com/sites/default/files/usbserver/scripts/vhusbdpin
sudo chmod +x ./vhusbdpin
sudo sed -i 's/vhusbdarm/vhusbdarmpi3/g' ./vhusbdpin
sudo mv vhusbdpin /etc/init.d
sudo update-rc.d vhusbdpin defaults

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
