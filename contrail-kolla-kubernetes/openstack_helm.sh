#!/bin/sh
set -x
if [ `hostname` = "stacknamecontrol_hostname" ]
then
cp /etc/kubernetes/admin.conf /kube-openstack.conf
export KUBECTL="kubectl --kubeconfig /kube-openstack.conf"
${KUBECTL} config set-context openstack --cluster=kubernetes --user=kubernetes-admin --namespace=openstack
${KUBECTL} config use-context openstack
${KUBECTL} label node stacknamecontrol_hostname openstack-control-plane=enabled
apt-get install -y git python-pip

i=0
while true
do
   if [ $i -ge computecount ]
   then
     break
   fi
   ${KUBECTL} label node stacknamecompute_hostname${i} openstack-compute-node=enabled
   i=$((i+1))
done

git clone https://git.openstack.org/openstack/openstack-helm.git /opt/openstack-helm
cd /opt/openstack-helm/
./tools/deployment/multinode/010-setup-client.sh
    
fi
