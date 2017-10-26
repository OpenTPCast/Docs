#!/bin/bash
# TPCast Upgrade Script

# Usage:
# sudo wget -e check_certificate=off -e use_proxy=yes -e https_proxy=https://192.168.144.100:3128 https://rawgit.com/NGenesis/Docs/master/files/tpcast-upgrade.sh
# sudo chmod +x ./tpcast-upgrade.sh
# sudo ./tpcast-upgrade.sh 192.168.144.100

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
		echo -e "check_certificate = off\nuse_proxy = on\nhttp_proxy = http://$HOST_PROXY_IP:3128\nhttps_proxy = https://$HOST_PROXY_IP:3128" | sudo tee -a /etc/wgetrc > /dev/null
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
unset UCF_FORCE_CONFFNEW && export UCF_FORCE_CONFFOLD=YES && export DEBIAN_FRONTEND=noninteractive && export APT_LISTCHANGES_FRONTEND=none && export DEBIAN_PRIORITY=critical && 
sudo apt-get remove apt-listchanges --assume-yes --force-yes && 
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections && 

# Upgrade Rapsian distro
sudo apt-get --force-yes -fuy autoremove && 
sudo apt-get --force-yes clean && 
sudo apt-get update && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" -fuy upgrade &&
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" -fuy dist-upgrade && 
sudo apt-get --force-yes -o Dpkg::Options::="--force-confold" --force-yes -o Dpkg::Options::="--force-confdef" --purge -fuy autoremove && 
sudo apt-get --force-yes clean

# Upgrade kernel
sudo sed -i 's/kernel=kernel_new_defcfg.img/kernel=kernel7.img/g' /boot/config.txt

# Optimize for faster boot time
sudo sed -i 's/rootwait/rootwait quiet/g' /boot/cmdline.txt

# Disable tpusbd service and old driver insertion boot script
sudo rm /etc/init.d/wlan-load.sh
sudo update-rc.d -f wlan-load.sh remove

# Upgrade WLAN driver
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw.bin
sudo wget -O /lib/firmware/rtlwifi/rtl8192dufw_wol.bin https://rawgit.com/lwfinger/rtl8192du/master/rtl8192dufw_wol.bin
sudo wget -O /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko https://rawgit.com/OpenTPCast/Docs/master/files/8192du-$(ls -1 /lib/modules | tail -1)-stretch.ko
echo '8192du' | sudo tee -a /etc/modules > /dev/null

# Configure WLAN interface
sudo sed -i '/country=GB/d' /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase "$(grep -oP '(?<=SSID=)([a-zA-Z0-9]+)$' key.txt)" "$(grep -oP '(?<=PWD=)([a-zA-Z0-9]+)$' key.txt)" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
echo -e "interface wlan0\nstatic ip_address=192.168.144.88/24\nstatic routers=192.168.144.1\nstatic domain_name_servers=192.168.144.1" | sudo tee -a /etc/dhcpcd.conf > /dev/null

# Create script to initialize WLAN driver on first boot
echo -e "#\0041/bin/bash\n### BEGIN INIT INFO\n# Provides:          8192du-init.sh\n# Required-Start:    $all\n# Required-Stop:     $all\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: Initialize 8192du WLAN kernel module on first boot\n# Description:       Initialize 8192du WLAN kernel module on first boot\n### END INIT INFO\nsudo insmod /lib/modules/$(ls -1 /lib/modules | tail -1)/kernel/drivers/net/wireless/8192du.ko\nsudo depmod -a > /dev/null\nsudo modprobe 8192du > /dev/null\nrm \$0\nsudo update-rc.d -f 8192du-init.sh remove" | sudo tee -a /etc/init.d/8192du-init.sh > /dev/null
sudo chmod +x /etc/init.d/8192du-init.sh
sudo update-rc.d 8192du-init.sh defaults

# Install VirtualHere USB Server (Server licence must be purchased from https://virtualhere.com to use)
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
