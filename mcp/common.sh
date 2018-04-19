#!/bin/sh
set -x
echo "cfg_ip  stacknamecfg_hostname" >> /etc/hosts

apt-get install -y python docker docker.io
python -c 'import json; obj={}; obj["bip"]="docker_bridge_ip"; print(json.dumps(obj))' > /etc/docker/daemon.json
systemctl restart docker
apt-get install --no-install-recommends -y git
apt-get install git vim tree python-pip -y
pip install --upgrade pip
apt-get install reclass salt-master -y
apt-get install salt-common salt-minion -y

cat > /etc/apt/sources.list.d/mcp_salt.list << EOF
deb [arch=amd64] http://apt.mirantis.com/xenial stable salt
EOF

cat > /etc/salt/minion.d/minion.conf << EOF
master: stacknamecfg_hostname
EOF
if [ `hostname` = "stacknamecfg_hostname" ]
then
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
  systemctl restart salt-master
  mkdir /etc/reclass
cat > /etc/reclass/reclass-config.yml <<EOF
storage_type: yaml_fs
pretty_print: True
output: yaml
inventory_base_uri: /srv/salt/reclass
EOF
  mkdir -p /srv/salt/reclass/nodes
  mkdir -p /srv/salt/reclass/classes

  reclass --inventory
  apt-get update
  apt-get install salt-formula-reclass salt-formula-salt -y --allow-unauthenticated
  ln -s "/usr/share/salt-formulas/reclass/service" /srv/salt/reclass/classes/
  git clone https://github.com/Mirantis/reclass-system-salt-model.git
  mkdir -p /srv/salt/reclass/classes/system
  cp -R /reclass-system-salt-model/* /srv/salt/reclass/classes/system/
  mkdir -p /srv/salt/reclass/classes/cluster/stackname/infra
cat > /srv/salt/reclass/nodes/stacknamecfg_hostname.yml <<EOF
classes:
- cluster.stackname.infra.config
parameters:
  _param:
    linux_system_codename: xenial
    reclass_data_revision: master
  linux:
    system:
      name: stacknamecfg_hostname
  salt:
    master:
      worker_threads: 5
EOF
fi

sleep 30
systemctl restart salt-minion
