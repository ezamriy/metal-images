# Equinix Metal Images


## AlmaLinux OS

Build command:

```shell
$ packer build -var 'qemu_binary=/usr/libexec/qemu-kvm' -only=qemu.almalinux-8-equinix-x86_64 .
```

VNC-enabled build command:

```shell
packer build -var 'qemu_binary=/usr/libexec/qemu-kvm' \
             -var 'vnc_port_min=5900' -var 'vnc_port_max=5900' \
             -var 'vnc_bind_address=0.0.0.0' -only=qemu.almalinux-8-equinix-x86_64 .
```
