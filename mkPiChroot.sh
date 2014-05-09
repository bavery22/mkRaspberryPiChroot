#!/bin/bash

#assumptions
IMAGE_FILE="2014-01-07-wheezy-raspbian.working.img"
CHROOT_DIR="/mnt/rPI"
WORK_DIR="/home/bavery/src/rPi-workspace"
LOOP_PART="/dev/mapper/loop0p2"

sudo mkdir -p $CHROOT_DIR

usage(){
    echo "$0 <cmd>"
    echo "cmds: go,stop,mount,umount. go and stop also mount and unmount"
    echo "Assumptions:"
    echo "image=$IMAGE_FILE"
    echo "chroot=$CHROOT_DIR"
    echo "Work dir to mount inside for more space:$WORK_DIR"
    exit 0
}


if [ "$#" != "1" ]; then
    usage
fi


CMD=$1

DoLoopback(){
    LO_CHECK=`sudo losetup -a|egrep ${IMAGE_FILE}` 
    if [ "$LO_CHECK" == "" ]; then 
	echo "Making the Partitions"
	sudo kpartx -av ${IMAGE_FILE}
    else
	echo "Loopback already setup. Skipping...."
    fi
}

UnDoLoopback(){
    echo "Undoing Loopback"
    sudo kpartx -dv ${IMAGE_FILE}
}

MountIt(){
    if [ -d $CHROOT_DIR/proc ]; then
	echo "Proc already mounted in chroot. If all not there. umount then mount again"
	exit -1
    fi
    echo "Mounting..."
    sudo mount $LOOP_PART $CHROOT_DIR
    sudo cp /usr/bin/qemu-arm-static $CHROOT_DIR/usr/bin
    sudo mount -t proc proc $CHROOT_DIR/proc
    sudo mount -t sysfs sysfs $CHROOT_DIR/sys
    sudo mount -o bind /dev $CHROOT_DIR/dev
    sudo mount -t devpts devpts  $CHROOT_DIR/dev/pts
    sudo cp -Lv /etc/resolv.conf $CHROOT_DIR/etc/
    sudo mkdir -p $CHROOT_DIR/$WORK_DIR
    sudo mount -o bind $WORK_DIR $CHROOT_DIR/$WORK_DIR
}

unMountIt(){
    echo "UnMounting..."
    sudo umount $CHROOT_DIR/dev/pts
    sudo umount $CHROOT_DIR/proc
    sudo umount $CHROOT_DIR/sys
    sudo umount $CHROOT_DIR/dev
    sudo umount $CHROOT_DIR/$WORK_DIR
    sudo umount $CHROOT_DIR/dev/pts
    sudo umount $CHROOT_DIR/dev
    sudo umount $CHROOT_DIR
}

CMD_KNOWN=0
if [ "$1" == "mount" ]; then
    CMD_KNOWN=1
    MountIt
fi

if [ "$1" == "umount" ]; then
    CMD_KNOWN=1
    unMountIt
fi
if [ "$1" == "go" ]; then
    CMD_KNOWN=1
    DoLoopback
    if [ ! -d $CHROOT_DIR/proc ]; then
	MountIt
    fi
    sudo mv $CHROOT_DIR/etc/ld.so.preload $CHROOT_DIR/etc/ld.so.preload.BAD_FOR_QEMU
    echo "Remember to run dpkg-reconfigure locales the first time"
    sleep 1
    sudo chroot $CHROOT_DIR
fi
if [ "$1" == "stop" ]; then
    CMD_KNOWN=1
    unMountIt
    UnDoLoopback
fi
if [ $CMD_KNOWN == 0 ]; then
    usage
fi
