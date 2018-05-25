#!/bin/sh
set -x
PARAM1=$1
PARAM2=$2
PARAM3=$3
PARAM4=$4
CLUSTERNAME=$1
UBUNTUVERSION=${PARAM2:-16.04}
UBUNTUCODE=${PARAM3:-xenial}
SALTVERSION=${PARAM4:-2016.3}

HOSTNAME=`hostname`
HOSTNAME_IP=`hostname -I | awk '{print $1}'`

# Add domain to etc_hosts if not configured 
sed -i "/^$HOSTNAME_IP  */d" /etc/hosts
echo "$HOSTNAME_IP $HOSTNAME $HOSTNAME.local" >> /etc/hosts

# Install software
apt-get update
apt-get install --no-install-recommends -y git
apt-get install git vim tree python-pip -y
pip install --upgrade pip

# Add salt repository
wget -O - https://repo.saltstack.com/apt/ubuntu/$UBUNTUVERSION/amd64/$SALTVERSION/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
cat > /etc/apt/sources.list.d/saltstack.list << EOF
deb http://repo.saltstack.com/apt/ubuntu/$UBUNTUVERSION/amd64/$SALTVERSION $UBUNTUCODE main
EOF
apt-get update  


# Install salt_minion
apt-get install salt-common salt-minion -y

cat > /etc/salt/minion.d/minion.conf << EOF
id: $HOSTNAME.local
master: $HOSTNAME_IP
EOF

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
deb [arch=amd64] http://apt-mk.mirantis.com/$UBUNTUCODE stable salt
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
cat > /srv/salt/reclass/nodes/$HOSTNAME.local.yml <<EOF
classes:
- cluster.$CLUSTERNAME.infra.config
parameters:
  _param:
    linux_system_codename: $UBUNTUCODE
    reclass_data_revision: master
    salt_master_host: $HOSTNAME.local
    domain: local
  linux:
    system:
      name: $HOSTNAME
      domain: local
  salt:
    master:
      worker_threads: 5
  reclass:
    storage:
      data_source:
        engine: local
EOF

sleep 30
systemctl restart salt-minion
