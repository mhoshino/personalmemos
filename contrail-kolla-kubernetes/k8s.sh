#!/bin/sh
set -x
apt-get install --no-install-recommends -y \
        git
if [ `hostname` = "stacknamecontrol_hostname" ]
then
	apt-get install --no-install-recommends -y \
        ca-certificates \
        git \
        make \
        jq \
        nmap \
        curl \
        uuid-runtime \
        ipcalc
	cat > /opt/openstack-helm-infra/tools/gate/devel/multinode-inventory.yaml <<EOF
all:
  children:
    primary:
      hosts:
        stacknamecontrol_hostname:
          ansible_port: 22
          ansible_host: stacknamecontrol_hostname
          ansible_user: root
    nodes:
      hosts:
EOF
        i=0
	while true
	do
          if [ $i -ge servercount ]
          then
             break
          fi
	  cat >> /opt/openstack-helm-infra/tools/gate/devel/multinode-inventory.yaml <<EOF
        stacknamecompute_hostname$i:
          ansible_port: 22
          ansible_host: stacknamecompute_hostname$i
          ansible_user: root
EOF
           i=$((i+1))
       done
       cat > /opt/openstack-helm-infra/tools/gate/devel/multinode-vars.yaml <<EOF
kubernetes:
  network:
    default_device: external_device
  cluster:
    cni: calico
    pod_subnet: 172.16.0.0/16
    domain: cluster.local
EOF
       ( cd /opt/openstack-helm-infra ; make dev-deploy setup-host multinode )
       ( cd /opt/openstack-helm-infra ; make dev-deploy k8s multinode )
fi
