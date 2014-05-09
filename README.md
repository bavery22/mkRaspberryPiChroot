mkRaspberryPiChroot
===================

Very bare bones script to make a raspberry pi chroot for development. Anyone else WILL need to modify it.

Assumed Vars:
IMAGE_FILE="2014-01-07-wheezy-raspbian.working.img"
CHROOT_DIR="/mnt/rPI"
WORK_DIR="/home/bavery/src/rPi-workspace"
LOOP="/dev/mapper/loop0p2"



dependencies
sudo apt-get install kpartx
wget http://downloads.raspberrypi.org/raspbian_latest -O raspian-lates.zip
unzip  raspian-lates.zip
cp 2014-01-07-wheezy-raspbian.img 2014-01-07-wheezy-raspbian.working.img


Note: the 2014-01-07-wheezy-raspbian.working.img file will change each time you enter, do stuff and exit.
The stuff in the working directory won't affect it but anything installed will.
