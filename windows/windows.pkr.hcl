packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "powershell_scripts_home" {
  type    = string
  default = "ps_scripts"
}

variable "windows_version" {
  type    = string
  default = "${env("WINVER")}"
}

variable "win2016_iso_path" {
  type    = string
  default = "${env("WIN2016_ISO_PATH")}"
}

source "qemu" "windows_server_2016" {
  iso_url          = var.win2016_iso_path
  iso_checksum     = "none"
  output_directory = "output-windows2016"
  shutdown_command = "c:\\windows\\system32\\sysprep\\sysprep.exe /oobe /generalize /mode:vm /shutdown"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  ram_size         = "4096"
  disk_size        = "51200M"
  cpus             = "4"
  format           = "qcow2"
  accelerator      = "kvm"
  communicator     = "winrm"
  winrm_insecure   = "true"
  winrm_use_ssl    = "true"
  winrm_username   = "Administrator"
  winrm_password   = "Password"
  winrm_port       = "5986"
  vm_name          = "Win2016VM"
  net_device       = "virtio-net"
  disk_interface   = "virtio-scsi"
  headless         = "false"
  cd_files         = ["./autounattend.xml", "./3rd_party_apps/*", "./ps_scripts"]
  cd_label         = "customization_media"
  boot_wait        = "5m"
  boot_command     = "<enter>"
}

build {
  sources = ["source.qemu.windows_server_2016"]

  provisioner "powershell" {
    inline = [
      "Write-Output 'Removing SNMP and SMBv1'",
      "Remove-WindowsFeature SNMP-Service,FS-SMB1 -Confirm:$false -ErrorAction SilentlyContinue"
    ]
  }

  provisioner "powershell" {
    scripts = ["${var.powershell_scripts_home}/common/win_reg.ps1", "${var.powershell_scripts_home}/common/post_install_task.ps1"]
  }

  provisioner "windows-restart" {
    pause_before          = "10s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  post-processor "shell-local" {
    inline = [
      "SOURCE=windows",
      "source ../scripts/setup-nbd",
      "OUTPUT=win${var.windows_version}.tar.gz",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
