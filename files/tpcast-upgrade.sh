#!/bin/bash
# TPCast Upgrade Script

# chmod +x ./tpcast-upgrade.sh
# ./tpcast-upgrade.sh 192.168.144.100

# Stop on errors
set -e

if [[ $# -eq 0 ]]; then
	echo 'No host proxy server IP address was provided, assume internet connection is available.'
else
	HOST_PROXY_IP=$1

	# Configure TPCast to download updates via proxy server
	if [ -f /etc/apt/apt.conf.d/10proxy ]; then
		sudo rm /etc/apt/apt.conf.d/10proxy
	fi

	echo -e "Acquire::http::Proxy \"http://$HOST_PROXY_IP:3128/\";" | sudo tee -a /etc/apt/apt.conf.d/10proxy > /dev/null

	if [ ! -f /etc/wgetrc.bak ]; then
		sudo cp /etc/wgetrc /etc/wgetrc.bak
		echo -e "use_proxy = on\nhttp_proxy = http://$HOST_PROXY_IP:3128\nhttps_proxy = https://$HOST_PROXY_IP:3128" | sudo tee -a /etc/wgetrc > /dev/null
	fi

	if [ ! -f /etc/environment.bak ]; then
		sudo cp /etc/environment /etc/environment.bak
		echo -e "http_proxy=http://$HOST_PROXY_IP:3128\nhttps_proxy=https://$HOST_PROXY_IP:3128\nexport http_proxy https_proxy" | sudo tee -a /etc/environment > /dev/null
	fi

	export http_proxy=http://$HOST_PROXY_IP:3128
	export https_proxy=https://$HOST_PROXY_IP:3128
fi

# Upgrade Raspian distro repositories (/etc/apt/sources.list /etc/apt/sources.list.d/raspi.list)
find /etc/apt -name "*.list" | sudo xargs sed -i -r '/^#*deb/s/jessie/stretch/g'

# Disable prompts during anattended upgrade
sudo apt-get remove apt-listchanges --assume-yes --force-yes && 
export DEBIAN_FRONTEND=noninteractive && export APT_LISTCHANGES_FRONTEND=none && export DEBIAN_PRIORITY=critical && 
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections

# Upgrade Rapsian distro
sudo apt-get --force-yes -fuy autoremove && 
sudo apt-get --force-yes clean && 
sudo apt-get update && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade &&
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" --purge -fuy autoremove

# Upgrade kernel
sudo sed -i 's/kernel=kernel_new_defcfg.img/kernel=kernel7.img/g' /boot/config.txt

# Optimize for faster boot time
sudo sed -i 's/rootwait/rootwait quiet/g' /boot/cmdline.txt

# Upgrade TPCast Wi-Fi driver
sudo wget --no-check-certificate -O /lib/firmware/rtlwifi/rtl8192dufw.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw.bin
sudo wget --no-check-certificate -O /lib/firmware/rtlwifi/rtl8192dufw_wol.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw_wol.bin
sudo wget --no-check-certificate -O /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko https://rawgit.com/OpenTPCast/Docs/master/files/8192du-$(ls -1 /lib/modules | tail -1)-stretch.ko
echo '8192du' | sudo tee -a /etc/modules > /dev/null
#sudo insmod /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko
sudo depmod -a

# Disable tpusbd service and old driver insertion script
sudo sed -i -e 's|sleep 10|#sleep 10|g' /etc/init.d/wlan-load.sh
sudo sed -i -e 's|sudo /home/pi/tpusb_startup.sh|#sudo /home/pi/tpusb_startup.sh|g' /etc/init.d/wlan-load.sh
sudo sed -i -e 's|sudo insmod \$MODULE_PATH/wlan.ko|#sudo insmod \$MODULE_PATH/wlan.ko|g' /etc/init.d/wlan-load.sh
sudo update-rc.d wlan-load.sh defaults

# Update TPCast Wi-Fi adapter (Incomplete)
wpa_passphrase "$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)" "$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
# TODO: Update wlan0 /etc/network/interfaces
# iface wlan0 inet manual
# wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
# iface default inet dhcp

#sudo sed -i -e 's|wpa-conf|wpa-roam|g' /etc/network/interfaces
#sudo sed -i -e 's|iface wlan0 inet manual|iface wlan0 inet dhcp\niface default inet dhcp|g' /etc/network/interfaces
#sudo sed -i -e "s|allow-hotplug wlan1\niface wlan1 inet manual\n    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf|test|g" /etc/network/interfaces

#echo -e "network={\n\tssid=\"$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)\"\n\tpsk=\"$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)\"\n}" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
#sudo wpa_cli reconfigure

#sudo ifconfig wlan0 down && sudo ifconfig wlan0 up
#sudo ifdown --force wlan0 && sudo ifup --force wlan0

#sudo nano /etc/network/interfaces
#sudo nano /etc/dhcpcd.conf
#sudo nano /etc/wpa_supplicant/wpa_supplicant.conf


# Install VirtualHere USB Server (Server licence must be purchased from https://virtualhere.com to use)
wget --no-check-certificate -O /home/pi/vhusbdarmpi3 https://virtualhere.com/sites/default/files/usbserver/vhusbdarmpi3
chmod +x /home/pi/vhusbdarmpi3
sudo sed -i -e 's|#sudo /home/pi/vhusbdarmpi2 -b|sudo /home/pi/vhusbdarmpi3 -b -c /home/pi/config.ini|g' /etc/init.d/wlan-load.sh
sudo update-rc.d wlan-load.sh defaults

# Configure VirtualHere USB Server for TPCast devices
# HMD camera has custom event handler onReset.$VENDOR_ID$.$PRODUCT_ID$=
echo -e "ServerName=TPCast\nonReset.0bb4.2c87=" | sudo tee config.ini > /dev/null

# Remove proxy server settings
if [ -f /etc/apt/apt.conf.d/10proxy ]; then
	sudo rm /etc/apt/apt.conf.d/10proxy
fi

if [ -f /etc/wgetrc.bak ]; then
	sudo mv /etc/wgetrc.bak /etc/wgetrc
fi

if [ -f /etc/environment.bak ]; then
	sudo mv /etc/environment.bak /etc/environment
fi

# Reboot for changes to take effect
sudo reboot now
