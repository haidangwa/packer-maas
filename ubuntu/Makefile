PACKER ?= packer

.PHONY: all clean

all: custom-cloudimg.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-cloudimg.tar.gz: clean
	sudo ${PACKER} init . && sudo PACKER_LOG=1 ${PACKER} build -var customize_script=scripts/customize-with-chef-solo.sh -only='cloudimg.*' .

custom-ubuntu.tar.gz: clean seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	sudo ${PACKER} init . && sudo PACKER_LOG=1 ${PACKER} build -var customize_script=scripts/customize-with-chef-solo.sh -only=qemu.flat .

custom-ubuntu-lvm.dd.gz: clean seeds-lvm.iso OVMF_VARS.fd
	sudo ${PACKER} init . && sudo PACKER_LOG=1 ${PACKER} build -var customize_script=scripts/customize-with-chef-solo.sh -only=qemu.lvm .

clean:
	sudo ${RM} -rf output-* custom-*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
	tar czf $@ -C packages ${notdir $^}

.INTERMEDIATE: OVMF_VARS.fd
