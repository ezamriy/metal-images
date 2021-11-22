# AlmaLinux OS 8 kickstart file for Equinix Metal

url --url https://repo.almalinux.org/almalinux/8/BaseOS/$basearch/kickstart/
repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/8/BaseOS/$basearch/os/
repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/8/AppStream/$basearch/os/

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

bootloader --location=mbr --timeout=1 --append="console=tty0 console=ttyS1,115200n8 earlyprintk=ttyS1,115200 rootdelay=300 biosdevname=0"
zerombr
clearpart --all --initlabel --disklabel=gpt
part /boot/efi --fstype=vfat --size=500
part /boot --fstype=xfs --size=500
part pv.01 --fstype=lvmpv --size=1000 --grow
volgroup sysvg pv.01
logvol / --vgname=sysvg --fstype=xfs --size=8192 --name=root
logvol /home --vgname=sysvg --fstype=xfs --size=1024 --name=home
logvol /var --vgname=sysvg --fstype=xfs --size=8192 --name=var
logvol swap --vgname=sysvg --fstype=swap --size=2048 --name=swap

rootpw --plaintext tinkerbell

reboot --eject


%packages
@core
bzip2
grub2-pc-modules
tar

-open-vm-tools
-iwl*-firmware
%end


# disable kdump service
%addon com_redhat_kdump --disable
%end


%post --log=/var/log/anaconda/post-install.log --erroronfail
echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub
echo 'GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' >> /etc/default/grub
%end
