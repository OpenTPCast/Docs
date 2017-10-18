#!/bin/bash  

sudo /home/pi/watchdog &

sleep 2  
echo "change ip ..."
sudo ifconfig wlan0 192.168.1.88 netmask 255.255.255.0
sleep 1

sudo insmod /lib/modules/`uname -r`/tpusb.ko


echo "start daemon ..."
sudo tpusbd
sleep 1

echo "start daemon monitor..."
sudo tp_m

echo "start console ..."
sudo tpusbc jj




