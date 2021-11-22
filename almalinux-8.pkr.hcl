/*
 * AlmaLinux OS 8 Packer template for building Equinix Metal images.
 */

source "qemu" "almalinux-8-equinix-x86_64" {
  iso_checksum       = var.alma_iso_checksum_x86_64
  iso_url            = var.alma_iso_url_x86_64
  shutdown_command   = var.shutdown_command
  http_directory     = var.http_directory
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = var.ssh_timeout
  cpus               = var.cpus
  disk_size          = var.disk_size
  format             = "raw"
  headless           = var.headless
  memory             = var.memory
  vm_name            = "almalinux-8-equinix-x86_64"
  boot_wait          = var.boot_wait
  boot_command       = [
    "e<wait><down><down><leftCtrlOn>e<leftCtrlOff><bs><bs><bs><bs><bs>",
    "inst.text net.ifnames=1 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.${var.partition_scheme}.ks",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  vnc_bind_address   = var.vnc_bind_address
  vnc_port_min       = var.vnc_port_min
  vnc_port_max       = var.vnc_port_max
  // qemu configuration
  accelerator        = "kvm"
  qemu_binary        = var.qemu_binary
  machine_type       = "q35"
  net_device         = "virtio-net"
  qemuargs           = [
    ["-m", "${var.memory}m"],
    ["-smp", var.cpus],
    ["-vga", "virtio"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-drive", "if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.secboot.fd"],
    ["-drive", "if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_VARS.fd"],
    ["-drive", "if=none,file=output-almalinux-8-equinix-x86_64/almalinux-8-equinix-x86_64,cache=writeback,discard=ignore,format=raw,id=drive0" ],
    ["-drive", "if=none,file=${var.packer_cache_dir}/6f7c25d58d3bf3cae0d71bc8d35643231ea3c651.iso,media=cdrom,id=cdrom0"]
  ]
}

source "qemu" "almalinux-8-equinix-aarch64" {
  iso_checksum       = var.alma_iso_checksum_aarch64
  iso_url            = var.alma_iso_url_aarch64
  shutdown_command   = var.shutdown_command
  http_directory     = var.http_directory
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = var.ssh_timeout
  cpus               = var.cpus
  disk_size          = var.disk_size
  format             = "raw"
  headless           = var.headless
  memory             = var.memory
  vm_name            = "almalinux-8-equinix-aarch64"
  boot_wait          = var.boot_wait
  boot_command       = [
    "e<wait><down><down><leftCtrlOn>e<leftCtrlOff><bs><bs><bs><bs><bs>",
    "inst.text net.ifnames=1 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.${var.partition_scheme}.ks",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  vnc_bind_address   = var.vnc_bind_address
  vnc_port_min       = var.vnc_port_min
  vnc_port_max       = var.vnc_port_max
  // qemu configuration
  accelerator        = "kvm"
  qemu_binary        = var.qemu_binary
  disk_interface     = "virtio-scsi"
  net_device         = "virtio-net"
  qemuargs           = [
    ["-m", "${var.memory}m"],
    ["-cpu", "host"],
    [ "-machine", "virt,gic-version=max,accel=kvm" ],
    [ "-boot", "strict=on" ],
    [ "-bios", "/usr/share/AAVMF/AAVMF_CODE.fd" ],
    [ "-monitor", "none" ]
  ]
}

build {
  sources = [
    "sources.qemu.almalinux-8-equinix-x86_64",
    "sources.qemu.almalinux-8-equinix-aarch64"
  ]

  provisioner "ansible" {
    playbook_file    = "./ansible/almalinux.yml"
    galaxy_file      = "./ansible/requirements.yml"
    roles_path       = "./ansible/roles"
    collections_path = "./ansible/collections"
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes'"
    ]
  }
}
