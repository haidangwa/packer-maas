PACKER ?= packer
.PHONY: all clean

all: win2019.tar.gz

win2019.tar.gz: clean
	sudo ${PACKER} init && sudo PACKER_LOG=1 ${PACKER} build -var "win2019_iso_path=${ISO}" -var "windows_version=2019" .
	reset

clean:
	sudo ${RM} -rf output-win* win*.tar.gz
