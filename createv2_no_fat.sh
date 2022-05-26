#!/bin/bash

set +x

sudo echo "Starting..."

dd if=/dev/zero of=./testimage.img bs=1G count=4

echo 🥷 Creating rootfs partition...

#sudo fdisk -c=dos -u=cylinders -H 255 -S 63 ./testimage.img <<___EOF___
sudo fdisk ./testimage.img <<___EOF___
n
p

8192

a
x
i
0
r
w
___EOF___

LOOP_DEV=`sudo losetup -f`
echo "Using $LOOP_DEV"

sudo losetup $LOOP_DEV -P ./testimage.img

mkdir -p ./boot-mount/
mkdir -p ./main-mount/

sudo mkfs.ext4 -O ^metadata_csum,^64bit -L ROOT ${LOOP_DEV}p1

sudo mount ${LOOP_DEV}p1 ./main-mount

#rm -rf ./u-boot

#git clone -b v2022.04 https://github.com/u-boot/u-boot u-boot-beagleboard --depth=1
pushd u-boot-beagleboard
#git pull --no-edit https://git.beagleboard.org/beagleboard/u-boot.git v2022.04-bbb.io-am335x-am57xx

ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make  am335x_evm_defconfig

ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make

popd

sudo rsync -zahPq ./kali_rootfs_content/ ./main-mount/

#sudo mkdir -p ./main-mount/boot/

#sudo cp ./linux/arch/arm/boot/uImage ./main-mount/boot/
sudo cp ./kernel/arch/arm/boot/zImage ./main-mount/boot/
sudo cp ./kali_bootfs_content/uEnv.txt ./main-mount/boot/uEnv.txt
#sudo cp ./files/*.dtb* ./main-mount/boot/
sudo cp ./kali_bootfs_content/zImage ./main-mount/
sudo cp ./kali_bootfs_content/uImage ./main-mount/
sudo cp -r ./kali_bootfs_content/dtbs ./main-mount/boot/

#sudo umount ./main-mount

#sudo losetup -D $LOOP_DEV

#sudo dd if=./u-boot/MLO of=./testimage.img conv=notrunc count=1 seek=1 bs=128k
#sudo dd if=./u-boot/u-boot.img of=./testimage.img conv=notrunc count=2 seek=1 bs=384k

sudo dd of=./testimage.img if=u-boot/MLO count=2 seek=1 conv=notrunc bs=128k
sudo dd of=./testimage.img if=u-boot/u-boot-dtb.img count=4 seek=1 conv=notrunc bs=384k

