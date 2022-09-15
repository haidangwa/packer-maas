#!/bin/bash

# installs Chef Infra Client and Berkshelf
curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 17
/opt/chef/embedded/bin/gem install berkshelf -N

mkdir /root/dmi-chef

# creates the Berksfile that will be used to vendor the necessary cookbooks
echo "source 'https://supermarket.chef.io'
source 'https://supermarket.disney.com'
solver :ruby, :required

cookbook 'twdc_image_config', '~> 0.3.1'
cookbook 'twdc_msb'
" > /root/dmi-chef/Berksfile

# write out a barebones solo.rb config
echo "cookbook_path '/var/chef/cache/cookbooks'" > /root/dmi-chef/solo.rb

# write out a run list json file: maas-runlist.json
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

# now leverage Berkshelf to vendor the cookbooks from private and public Supermarkets
/opt/chef/embedded/bin/berks vendor /var/chef/cache/cookbooks/ -b /root/dmi-chef/Berksfile

# finally, run chef-solo
/opt/chef/embedded/bin/chef-solo -j /root/dmi-chef/maas-runlist.json -c /root/dmi-chef/solo.rb --chef-license accept
