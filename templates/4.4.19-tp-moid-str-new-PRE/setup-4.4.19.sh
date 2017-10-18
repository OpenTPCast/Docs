#!/bin/bash  
  
#echo "$whoami"
#echo "add group"
#sudo groupadd tp
#echo "add usr to group"
#sudo gpasswd -a `whoami` tp

echo "cp usb rules"
sudo cp 90-tpusb.rules /lib/udev/rules.d/

echo "cp ko"
sudo cp tpusb.ko /lib/modules/`uname -r`/	

echo "cp daemon ..."
sudo cp tpusbd /usr/bin/
echo "cp console ..."
sudo cp tpusbc /usr/bin/

echo "cp libs ..."
sudo cp libtp* /usr/lib/
sudo cp libboost* /usr/lib/

sudo cp shares_devs /var/opt
sudo cp shares_devs_2 /var/opt

sudo cp tpusb_startup.sh /home/pi/
sudo cp watchdog /home/pi/

sudo cp tp_m /usr/bin

#sudo sed -i "s/using/#using/g" /etc/init.d/wlan0.sh



echo "setup success"



