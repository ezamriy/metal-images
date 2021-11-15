# AlmaLinux 8 kickstart file for Equinix Metal
# Special thanks to CentOS Cloud SIG for the partitioning example:
#   https://github.com/CentOS/sig-cloud-instance-build/blob/master/cloudimg/CentOS-8-x86_64-Azure.ks

url --url https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/kickstart/
repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/
repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/8/AppStream/x86_64/os/

text
skipx
eula --agreed
firstboot --disabled

lang en_US.UTF-8
keyboard us
timezone UTC

network --bootproto=dhcp
firewall --disabled
services --disabled="kdump" --enabled="chronyd,rsyslog,sshd"
selinux --enforcing

bootloader --append="console=tty0 console=ttyS1,115200n8 earlyprintk=ttyS1,115200 rootdelay=300 rd.auto rd.auto=1" --location=mbr --timeout=1
zerombr
bootloader --location=mbr --timeout=1
part /boot/efi --onpart=vda15 --fstype=vfat
part /boot --fstype="xfs" --size=500
part / --fstype="xfs" --size=1 --grow --asprimary

#clearpart --all --initlabel --disklabel=gpt
#autopart --type=plain --noboot --nohome --noswap --fstype=xfs

rootpw --plaintext tinkerbell
user --name=tinkerbell --plaintext --password tinkerbell

reboot --eject


%packages
@core
bzip2
grub2-pc-modules
tar

-open-vm-tools
-iwl*-firmware
%end


%pre --log=/var/log/anaconda/pre-install.log --erroronfail
#!/bin/bash

# Pre-create the biosboot and EFI partitions
#  - Ensure that efi and biosboot are created at the start of the disk to
#    allow resizing of the OS disk.
#  - Label biosboot and efi as vda14/vda15 for better compat - some tools
#    may assume that vda1/vda2 are '/boot' and '/' respectively.
sgdisk --clear /dev/vda
sgdisk --new=14:2048:10239 /dev/vda
sgdisk --new=15:10240:500M /dev/vda
sgdisk --typecode=14:EF02 /dev/vda
sgdisk --typecode=15:EF00 /dev/vda

%end


# disable kdump service
%addon com_redhat_kdump --disable
%end


%post --log=/var/log/anaconda/post-install.log --erroronfail
# allow tinkerbell user to run everything without a password
echo "tinkerbell     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/tinkerbell
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers

echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub
echo 'GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' >> /etc/default/grub

# Enable BIOS bootloader
grub2-mkconfig --output /etc/grub2-efi.cfg
grub2-install --target=i386-pc --directory=/usr/lib/grub/i386-pc/ /dev/vda
grub2-mkconfig --output=/boot/grub2/grub.cfg
ln -sf /boot/grub2/grub.cfg /etc/grub2.cfg

# Fix grub.cfg to remove EFI entries, otherwise "boot=" is not set correctly and blscfg fails
EFI_ID=$(blkid --match-tag UUID --output value /dev/vda15)
BOOT_ID=$(blkid --match-tag UUID --output value /dev/vda1)
sed -i 's/gpt15/gpt1/' /boot/grub2/grub.cfg
sed -i "s/${EFI_ID}/${BOOT_ID}/" /boot/grub2/grub.cfg
sed -i 's|${config_directory}/grubenv|(hd0,gpt15)/efi/almalinux/grubenv|' /boot/grub2/grub.cfg
sed -i '/^### BEGIN \/etc\/grub.d\/30_uefi/,/^### END \/etc\/grub.d\/30_uefi/{/^### BEGIN \/etc\/grub.d\/30_uefi/!{/^### END \/etc\/grub.d\/30_uefi/!d}}' /boot/grub2/grub.cfg
%end
