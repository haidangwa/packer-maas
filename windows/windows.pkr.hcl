packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "windows_server_2019" {
  iso_url          = var.win2019_iso_path
  iso_checksum     = "none"
  output_directory = "output-windows2019"
  shutdown_command = "c:\\windows\\system32\\sysprep\\sysprep.exe /oobe /generalize /mode:vm /shutdown"
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"
  memory           = "8000"
  disk_size        = "50G"
  cpus             = "4"
  format           = "qcow2"
  accelerator      = "kvm"
  communicator     = "winrm"
  winrm_insecure   = "true"
  winrm_use_ssl    = "true"
  winrm_username   = "Administrator"
  winrm_password   = "Password"
  winrm_port       = "5986"
  vm_name          = "Win2019VM"
  net_device       = "virtio-net"
  machine_type     = "q35"
  disk_interface   = "virtio-scsi"
  headless         = "false"
  cd_files         = ["./autounattend.xml"]
  cd_label         = "customization_media"
  boot_wait        = "5m"
  boot_command     = ["<enter><wait><f6><wait><esc><wait>", "<enter>"]
  qemuargs = [
    ["-serial", "stdio"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-display", "none"],
    ["-net", "nic,model=rtl8139"],
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-device", "virtio-rng-pci"]
  ]

}

build {
  sources = ["source.qemu.windows_server_2019"]

  provisioner "powershell" {
    inline = [
      "if(!(test-path c:\\dtss\\installers\\ms)){ New-Item -Path c:\\dtss\\installers\\ms -ItemType Directory -Force -Confirm:$false }",
      "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
      "Write-Output 'Downloading Chef Infra Client...'",
      "Invoke-WebRequest ${var.chef_client_url} -OutFile 'c:\\dtss\\chef.msi'",
      "Write-Output 'Downloading WinSSHD settings.wst...'",
      "Invoke-WebRequest ${var.winsshd_settings_url} -OutFile 'c:\\dtss\\settings.wst'",
      "Write-Output 'Downloading WinSSHD installer...'",
      "Invoke-WebRequest ${var.winsshd_installer_url} -OutFile 'c:\\dtss\\winsshd.exe'",
      "Write-Output 'Downloading tanium-init.dat...'",
      "Invoke-WebRequest ${var.tanium_init_dat_url} -OutFile 'c:\\dtss\\installers\\ms\\tanium-init.dat'",
      "Write-Output 'Downloading taniumclient.exe...'",
      "Invoke-WebRequest ${var.taniumclient_url} -OutFile 'c:\\dtss\\installers\\ms\\taniumclient.exe'",
      "Write-Output 'Downloading Trend Micro DS Agent installer...'",
      "Invoke-WebRequest ${var.trend_micro_ds_agent_url} -OutFile 'c:\\dtss\\installers\\ms\\agent.msi'",
      "Write-Output 'Removing SNMP and SMBv1'",
      "Remove-WindowsFeature SNMP-Service,FS-SMB1 -Confirm:$false -ErrorAction SilentlyContinue"
    ]
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
