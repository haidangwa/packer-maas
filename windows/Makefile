PACKER ?= packer

.PHONY: all clean

all: win2016.tar.gz

win2016.tar.gz: clean
  ISO ?= ${WIN2016_ISO_PATH}
	sudo ${PACKER} init && sudo PACKER_LOG=1 ${PACKER} build \
	-var "win2016_iso_path=${ISO}" \
	-var "windows_version=2016" \
	-var-file="win2016.pkrvars.hcl" .
	reset

clean:
	sudo ${RM} -rf output-qemu win2016.tar.gz
