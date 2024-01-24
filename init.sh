#!/bin/bash

# if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
#   mke2fs -F -j /dev/sdb
#   mount /dev/sdb /mnt
#   chmod 755 /mnt
#   echo "/dev/sdb      /mnt    ext3    defaults,nofail 0       2" >> /etc/fstab
# fi

# mkdir /mnt/hadoop
# chmod 1777 /mnt/hadoop

sudo apt-get install htop

git config --global core.editor "vim"
