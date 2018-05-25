#!/bin/sh
sh -x
if [ `hostname` = "stacknamecfg_hostname" ]
then
  curl -O https://raw.githubusercontent.com/mhoshino/simplemcp/master/install_salt_master.sh
  sh -x ./install_salt_master.sh stackname
else
  curl -O https://raw.githubusercontent.com/mhoshino/simplemcp/master/install_salt_minion.sh
  sh -x ./install_salt_minion.sh cfg_ip
fi
