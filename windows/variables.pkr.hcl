locals {
  qemu_arch = {
    "amd64" = "x86_64"
    "arm64" = "aarch64"
  }
  qemu_machine = {
    "amd64" = "pc,accel=kvm"
    "arm64" = "virt"
  }
  qemu_cpu = {
    "amd64" = "host"
    "arm64" = "cortex-a57"
  }
  uefi_imp = {
    "amd64" = "OVMF"
    "arm64" = "AAVMF"
  }
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "chef_client_url" {
  type = string
}

variable "powershell_scripts_home" {
  type    = string
  default = "ps_scripts"
}

variable "tanium_init_dat_url" {
  type = string
}

variable "taniumclient_url" {
  type = string
}

variable "trend_micro_ds_agent_url" {
  type = string
}

variable "win2019_iso_path" {
  type    = string
  default = "${env("WIN2019_ISO_PATH")}"
}

variable "windows_version" {
  type    = string
  default = "${env("WINVER")}"
}

variable "winsshd_installer_url" {
  type = string
}

variable "winsshd_settings_url" {
  type = string
}
