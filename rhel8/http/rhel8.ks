cdrom
poweroff
firewall --enabled --service=ssh
firstboot --disable
ignoredisk --only-use=vda
lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto=dhcp
firewall --enabled --service=ssh
selinux --enforcing
timezone UTC --isUtc
bootloader --location=mbr --driveorder="vda" --timeout=1
rootpw --plaintext password

repo --name="AppStream" --baseurl="file:///run/install/repo/AppStream"

zerombr
clearpart --all --initlabel
part / --size=1 --grow --asprimary --fstype=ext4

%post --erroronfail
# workaround anaconda requirements and clear root password
passwd -d root
passwd -l root

curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 17
/opt/chef/embedded/bin/gem install berkshelf -N

mkdir /root/dmi-chef

echo "source 'https://supermarket.chef.io'
source 'https://supermarket.disney.com'
solver :ruby, :required

cookbook 'twdc_image_config', '~> 0.3.1'
cookbook 'twdc_msb'
" > /root/dmi-chef/Berksfile

echo "cookbook_path '/var/chef/cache/cookbooks'" > /root/dmi-chef/solo.rb

echo "{\"run_list\": [\"recipe[twdc_image_config::linux_patch]\",
      \"recipe[twdc_image_config::linux_base_packages_barebones]\",
      \"recipe[twdc_image_config::linux_base_services]\",
      \"recipe[twdc_image_config::linux_base_settings]\",
      \"recipe[twdc_image_config::agent_pbis]\",
      \"recipe[twdc_image_config::agent_tanium]\",
      \"recipe[twdc_image_config::agent_bigfix]\",
      \"recipe[twdc_image_config::agent_trend_antivirus]\",
      \"recipe[twdc_image_config::linux_final_msb]\"
]}" > /root/dmi-chef/maas-runlist.json

mkdir -p /var/chef/cache/cookbooks
/opt/chef/embedded/bin/berks vendor /var/chef/cache/cookbooks/ -b /root/dmi-chef/Berksfile

# this will run chef-solo on first boot using systemd
echo "[Unit]
Description=One time boot script that runs chef-solo
[Service]
Type=simple
ExecStart=/opt/chef/embedded/bin/chef-solo -j /root/dmi-chef/maas-runlist.json -c /root/dmi-chef/solo.rb --chef-license accept
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/firstboot.service
systemctl enable firstboot.service

# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub

dnf clean all
%end

%packages
@core
bash-completion
cloud-init
# cloud-init only requires python3-oauthlib with MAAS. As such upstream
# removed this dependency.
python3-oauthlib
rsync
tar
# grub2-efi-x64 ships grub signed for UEFI secure boot. If grub2-efi-x64-modules
# is installed grub will be generated on deployment and unsigned which breaks
# UEFI secure boot.
grub2-efi-x64
efibootmgr
shim-x64
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove Intel wireless firmware
-i*-firmware
%end

