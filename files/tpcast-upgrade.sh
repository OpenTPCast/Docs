#!/bin/bash

# OpenTPCast upgrade script for Raspbian Stretch and VirtualHere.
# An installation guide on how to use this script can be found at https://github.com/OpenTPCast/Docs/blob/master/guides/UPGRADE.md

# Author: Genesis (https://github.com/NGenesis)

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

WLAN_IP_ADDRESS=$(ifconfig wlan0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
WLAN_GATEWAY=$(route -n | grep '^0.0.0.0.*wlan0' | tr -s ' ' | cut -f2 -d' ')

logger "TPCast upgrade is starting..."
echo "------------------------------------------------------"
echo "|                                                    |"
echo "|                   TPCast Upgrade                   |"
echo "|                 Beginning Upgrade...               |"
echo "|                                                    |"
echo "------------------------------------------------------"
echo "Please wait while the TPCast is upgraded, this process is will take approximately 1-2 hours depending on your internet connection speed."

# Upgrade Raspbian distro repositories (/etc/apt/sources.list /etc/apt/sources.list.d/raspi.list)
logger "Upgrading Raspbian distro repositories to Stretch (/etc/apt/sources.list /etc/apt/sources.list.d/raspi.list)"
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

# Clean up old tpusbd service and wlan driver files
logger "Disabling tpusbd service and old driver insertion boot script"
if [ -f /etc/init.d/wlan-load.sh ]; then
	sudo rm /etc/init.d/wlan-load.sh > /dev/null 2>&1 || true
	sudo update-rc.d -f wlan-load.sh remove > /dev/null 2>&1 || true
fi

sudo rm -rf /usr/lib/libtpusb.so* /home/pi/4.4.19-tp-moid-str-new /home/pi/checknet /home/pi/oldver.conf /home/pi/rtwpriv /home/pi/server /home/pi/tpusb_startup.sh /home/pi/updated /home/pi/watchdog /home/pi/ssidpwd /home/pi/wlan-connect.sh /home/pi/wlan.ko

# Configure WLAN interface
logger "Configuring WLAN interface wlan0"
sudo sed -i '/country=GB/d' /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase "$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)" "$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
sudo sed -i 's/network={/network={\n\tscan_ssid=1/g' /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "interface wlan0\nstatic ip_address=$WLAN_IP_ADDRESS/24\nstatic routers=$WLAN_GATEWAY\nstatic domain_name_servers=$WLAN_GATEWAY" | sudo tee -a /etc/dhcpcd.conf > /dev/null

# Upgrade WLAN driver
logger "Upgrading WLAN driver and firmware for rtl8192du"
if sudo wget -q -O /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko https://rawgit.com/OpenTPCast/Docs/master/files/8192du-$(ls -1 /lib/modules | tail -1)-stretch.ko; then
	logger "Downloading WLAN kernel module and firmware..."
	sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw.bin https://rawgit.com/OpenTPCast/Docs/master/files/rtl8192dufw.bin
	sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw_wol.bin https://rawgit.com/OpenTPCast/Docs/master/files/rtl8192dufw_wol.bin
else
	logger "No precompiled kernel module available from repository, compiling WLAN kernel module..."
	sudo apt-get install -y raspberrypi-kernel-headers git
	git clone https://github.com/lwfinger/rtl8192du.git
	sudo ln -s /usr/src/linux-headers-$(ls -1 /lib/modules | tail -1)/arch/arm /usr/src/linux-headers-$(ls -1 /lib/modules | tail -1)/arch/armv7l > /dev/null 2>&1 || true
	sudo make KVER=$(ls -1 /lib/modules | tail -1) -C ./rtl8192du
	sudo cp rtl8192du/8192du.ko /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless && sudo cp rtl8192du/rtl8192dufw.bin /lib/firmware/rtlwifi/rtl8192dufw.bin && sudo cp rtl8192du/rtl8192dufw_wol.bin /lib/firmware/rtlwifi/rtl8192dufw_wol.bin
	sudo rm -rf rtl8192du
fi

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
# WLAN & VH debugging devices are hidden from client
echo -e "ServerName=TPCast\nonReset.0bb4.2c87=\nDeviceNicknames=Vive Camera,0bb4,2c87,1122\nIgnoredDevices=424/ec00,bda/8194" | sudo tee /root/config.ini > /dev/null

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

# Remove this script once done
rm -- "$0"

# Reboot for changes to take effect
sudo reboot now
