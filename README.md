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


## References

* [AlmaLinux OS cloud images templates](https://github.com/AlmaLinux/cloud-images)
* [AlmaLinux OS aarch64 templates by Ampere Computing](https://github.com/AmpereComputing/packer-aarch64-templates/tree/main/almalinux)
* [Kickstart Commands in Red Hat Enterprise Linux](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-3-kickstart-commands-in-red-hat-enterprise-linux)
