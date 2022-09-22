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
