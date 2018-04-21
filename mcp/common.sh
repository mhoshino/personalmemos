#!/bin/sh
set -x
HOSTNAME=`hostname`
HOSTNAME_IP=`hostname -I | awk '{print $1}'`
echo "$HOSTNAME_IP $HOSTNAME $HOSTNAME.local" >> /etc/hosts
echo "cfg_ip  stacknamecfg_hostname stacknamecfg_hostname.local" >> /etc/hosts

apt-get install --no-install-recommends -y git
apt-get install git vim tree python-pip -y
pip install --upgrade pip

wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
cat > /etc/apt/sources.list.d/saltstack.list << EOF
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.3 xenial main
EOF
apt-get update
apt-get install salt-common salt-minion -y

cat > /etc/salt/minion.d/minion.conf << EOF
master: stacknamecfg_hostname
EOF

if [ `hostname` = "stacknamecfg_hostname" ]
then

  # Install and config(temporary) salt master
  apt-get install reclass salt-master -y
cat > /etc/salt/master.d/master.conf <<EOF
file_roots:
  base:
  - /usr/share/salt-formulas/env
  prd:
  - /usr/salt/env/prd
  dev:
  - /usr/salt/env/dev
pillar_opts: False
open_mode: True
reclass: &reclass
  storage_type: yaml_fs
  inventory_base_uri: /srv/salt/reclass
ext_pillar:
  - reclass: *reclass
master_tops:
  reclass: *reclass
EOF
  # Install and config reclass
  systemctl restart salt-master
  mkdir /etc/reclass
cat > /etc/reclass/reclass-config.yml <<EOF
storage_type: yaml_fs
pretty_print: True
output: yaml
inventory_base_uri: /srv/salt/reclass
EOF

  # Make base directories
  mkdir -p /srv/salt/reclass/nodes
  mkdir -p /srv/salt/reclass/classes

  # Install basic salt-formulas
  apt-get install reclass salt-master -y
cat > /etc/apt/sources.list.d/mcp_salt.list << EOF
deb [arch=amd64] http://apt-mk.mirantis.com/xenial stable salt
EOF
  wget -qO - http://apt-mk.mirantis.com/public.gpg | sudo apt-key add -
  apt-get update
  
  apt-get install salt-formula-linux salt-formula-git salt-formula-reclass salt-formula-salt salt-formula-openssh -y --allow-unauthenticated

  # Create service level reclass
  mkdir -p /srv/salt/reclass/classes/service
  for pkg in linux git reclass salt openssh
  do
    ln -s /usr/share/salt-formulas/reclass/service/$pkg /srv/salt/reclass/classes/service/$pkg
  done

  # Create system level reclass
  git clone https://github.com/Mirantis/reclass-system-salt-model.git /srv/salt/reclass/classes/system
  
  # Create cluster level reclass
  mkdir -p /srv/salt/reclass/classes/cluster

  # Create environment
  mkdir -p /src/salt/env
  ln -s /usr/share/salt-formulas/env /src/salt/env/prd

  # Create salt config for master node
cat > /srv/salt/reclass/nodes/stacknamecfg_hostname.local.yml <<EOF
classes:
- cluster.stackname.infra.config
parameters:
  _param:
    linux_system_codename: xenial
    reclass_data_revision: master
    stack_name: stackname
    salt_master_host: stacknamecfg_hostname.local
    domain: local
  linux:
    system:
      name: stacknamecfg_hostname
      domain: local
  salt:
    master:
      worker_threads: 5
EOF
fi

sleep 30
systemctl restart salt-minion
