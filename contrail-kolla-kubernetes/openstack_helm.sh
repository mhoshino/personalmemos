#!/bin/sh
set -x
if [ `hostname` = "stacknamecontrol_hostname" ]
then
cp /etc/kubernetes/admin.conf /kube-openstack.conf
export KUBECTL="kubectl --kubeconfig /kube-openstack.conf"
${KUBECTL} config set-context openstack --cluster=kubernetes --user=kubernetes-admin --namespace=openstack
${KUBECTL} config use-context openstack

apt-get install -y git python-pip

i=0
while true
do
   if [ $i -ge servercount ]
   then
     break
   fi
   ${KUBECTL} label node stacknamecompute_hostname${i} openstack-control-plane=enabled
   i=$((i+1))
done

git clone https://git.openstack.org/openstack/openstack-helm.git /opt/openstack-helm
/opt/openstack-helm/tools/deployment/multinode/010-setup-client.sh
    
fi



