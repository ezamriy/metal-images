variables {
  /*
   * AlmaLinux specific variables
   */
  alma_iso_url_x86_64        = "https://repo.almalinux.org/almalinux/8.5/isos/x86_64/AlmaLinux-8.5-x86_64-boot.iso"
  alma_iso_checksum_x86_64   = "file:https://repo.almalinux.org/almalinux/8.5/isos/x86_64/CHECKSUM"
  alma_iso_url_aarch64       = "https://repo.almalinux.org/almalinux/8.5/isos/aarch64/AlmaLinux-8.5-aarch64-boot.iso"
  alma_iso_checksum_aarch64  = "file:https://repo.almalinux.org/almalinux/8.5/isos/aarch64/CHECKSUM"
#  alma_boot_command_x86_64   = [
#    "e<down><down><end><bs><bs><bs><bs><bs>inst.text net.ifnames=1 ",
#    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.${var.partition_scheme}.ks",
#    "<leftCtrlOn>x<leftCtrlOff>"
#  ]
  alma_boot_command_aarch64  = [
    "e<wait><down><down><leftCtrlOn>e<leftCtrlOff><bs><bs><bs><bs><bs>",
    "inst.text net.ifnames=1 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.aarch64.ks",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  /*
   *  Common variables
   */
  shutdown_command      = "/sbin/shutdown -hP now"
  http_directory        = "http"
  ssh_username          = "root"
  ssh_password          = "tinkerbell"
  ssh_timeout           = "3600s"
  cpus                  = 2
  disk_size             = 4096
  // disk_size             = 20480
  headless              = true
  memory                = 2048
  boot_wait             = "10s"
  vnc_bind_address      = "127.0.0.1"
  vnc_port_min          = 5900
  vnc_port_max          = 6000
  qemu_binary           = ""
  packer_cache_dir      = env("PACKER_CACHE_DIR")
  # Partitioning scheme type: plain or lvm.
  partition_scheme        = "plain"
}
