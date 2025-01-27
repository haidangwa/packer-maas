# Windows Packer Template for MAAS

## Introduction

The Packer template in this directory creates multiple images for Windows 2016, 2019, and 2022
for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer
* ISO files for Windows Server 2016, 2019, and 2022

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+, [MAAS](https://maas.io) 2.7+ recommended
* [Curtin](https://launchpad.net/curtin) 19.3-792+

## Customizing the Image

The deployment image may be customized by modifying http/rhel8.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy

The Packer template pulls all packages from the DVD except for Canonical's
cloud-init repository. To use a proxy during the installation add the
--proxy=$HTTP_PROXY flag to every line starting with url or repo in
http/rhel8.ks. Alternatively you may set the --mirrorlist values to a
local mirror.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/rhel-8.3-x86_64-dvd.iso
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/rhel8, where this file is located. Once in packer-maas/rhel8
you can generate an image with:

```shell
sudo packer init
sudo PACKER_LOG=1 packer build -var 'rhel8_iso_path=/PATH/TO/rhel-8.3-x86_64-dvd.iso' .
```

Note: rhel8.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
rhel8.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='rhel/8-custom' title='RHEL 8 Custom' \
    architecture='amd64/generic' filetype='tgz' \
    content@=rhel8.tar.gz
```

## Default Username

The default username is ```cloud-user```
