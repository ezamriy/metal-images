# AlmaLinux 8 kickstart file for Equinix Metal
# Special thanks to CentOS Cloud SIG for the partitioning example:
#   https://github.com/CentOS/sig-cloud-instance-build/blob/master/cloudimg/CentOS-8-x86_64-Azure.ks

url --url https://repo.almalinux.org/almalinux/8/BaseOS/aarch64/kickstart/
repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/8/BaseOS/aarch64/os/
repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/8/AppStream/aarch64/os/

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
clearpart --all --initlabel --disklabel=gpt
autopart --type=plain --noboot --nohome --noswap --fstype=xfs

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


# disable kdump service
%addon com_redhat_kdump --disable
%end


%post --log=/var/log/anaconda/post-install.log --erroronfail
# allow tinkerbell user to run everything without a password
echo "tinkerbell     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/tinkerbell
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers

echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub
echo 'GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' >> /etc/default/grub
%end
