#!/bin/bash

#######################################
mkdir /tmp/boot #Makes the folders to start mounting to (Deel 2 > 1.1)
mkdir /tmp/rootfs

#Gets the path from the label
PATHBOOT=$(lsblk -o name,label -lpn | grep "boot" | cut -d " " -f1)
PATHROOTFS=$(lsblk -o name,label -lpn | grep "rootfs" | cut -d " " -f1)

if test -f "$PATHBOOT"; then #Check if path exist
	#otherwise just exit because we can't do anything else
	exit 1
fi

if test -f "$PATHROOTFS"; then #Check if path exist
	#otherwise just exit because we can't do anything else
	exit 1
fi


#mount the drive
sudo mount -t vfat /dev/sdb1 /tmp/boot
sudo mount -t ext4 /dev/sdb2 /tmp/rootfs/

#######################################
#IP configuration

#Remove IP from cmdline text file just in case there is already one in there
if grep -q "ip" "/tmp/boot/cmdline.txt"; then
  cat /tmp/boot/cmdline.txt |  cut -d " " -f2- > /tmp/boot/cmdline.txt
fi

#Add the ip to the cmdline after it was removed
sudo echo -e "ip=169.254.10.1 $(cat /tmp/boot/cmdline.txt)" > /tmp/cmdline.txt 
sudo mv /tmp/cmdline.txt /tmp/boot/cmdline.txt

#######################################
#SSH configuration

#Simply adds a empty ssh file so it enables automaticly the ssh (this is also automaticly added the the raspberry pi imager)
sudo touch /tmp/boot/ssh

#######################################
#WPA configuration

#Echos the config file to a temp file
sudo echo 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BE

network={
ssid="Howest-IoT"
psk="LZe5buMyZUcDpLY"
key_mgmt=WPA-PSK
}
' > /tmp/wpa_supplicant.conf

#and moves this tempfile to the right dir
sudo mv /tmp/wpa_supplicant.conf /tmp/boot/wpa_supplicant.conf


#######################################
#IP configuration 2

FILENAME="cmdline.txt"
if grep -q "ip" "$FILENAME"; then
  cp /tmp/boot/$FILENAME /tmp/$FILENAME #Copies the original file to a temp location (because it denies permission to edit the file directly)

  #Removes the IP part from the cmdline text file and saves it to temp file
  sudo sed -i 's/[^ ]* //' /tmp/$FILENAME
  sudo cp /tmp/$FILENAME /tmp/boot/$/$FILENAME #Moves the tmp file to the original cmdline file
fi

#Checks if the file exists (sometimes the dhcpcd.conf file isn't there yet)
if test -f "/tmp/rootfs/etc/dhcpcd.conf"; then
  sudo cp /tmp/rootfs/etc/dhcpcd.conf /tmp/dhcpcd.conf #if the file is there then just change the values to what it needs to be
  sudo sed -i '/#profile static_eth0/,/#static ip_address/cprofile static_eth0\nstatic ip_address=192.168.168.168/24' /tmp/dhcpcd.conf
  sudo sed -i '/#fallback static_eth0/,/static domain/cinterface eth0\nfallback static_eth0' /tmp/dhcpcd.conf
else
  sudo touch /tmp/dhcpcd.conf #Else makes a simple file from scratch and add the basics to it 
  sudo echo "profile static_eth0"                  >> /tmp/dhcpcd.conf
  sudo echo "static ip_address=192.168.168.168/24" >> /tmp/dhcpcd.conf
  sudo echo "interface eth0"                       >> /tmp/dhcpcd.conf
  sudo echo "fallback static_eth0"                 >> /tmp/dhcpcd.conf
fi
#move the file back to original spot
sudo cp /tmp/dhcpcd.conf /tmp/rootfs/etc/dhcpcd.conf

#######################################
#Update

#Makes a temp file for config update
touch /tmp/config_update.sh
sudo echo '#!/bin/bash' > /tmp/config_update.sh
sudo echo "sudo apt update && sudo apt upgrade -y" >> /tmp/config_update.sh
sudo cp /tmp/config_update.sh /tmp/boot/config_update.sh 

#######################################
#unmounts the partitions so it can be removed safely
sudo umount /tmp/boot
sudo umount /tmp/rootfs

exit 0


