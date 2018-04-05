#!/bin/sh
set -x
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo -E apt-key add -
cat <<EOF > kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp -aR kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl
sudo apt-get install -y kubelet
sudo apt-get install -y kubeadm
if [ `hostname` = "stacknamecontrol_hostname" ]
then
  sudo kubeadm init 
  mkdir -p /root/.kube
  sudo -H cp /etc/kubernetes/admin.conf /root/.kube/config
  sudo -H chown $(id -u):$(id -g) /root/.kube/config

  TOKEN=`kubeadm token generate`
  JOIN_CMD=`kubeadm token create ${TOKEN} --print-join-command --ttl=0`
  i=0
  ssh stacknamecontrail_hostname ${JOIN_CMD}
  while true
  do
     if [ $i -ge computecount ]
     then
       break
     fi
     ssh stacknamecompute_hostname${i} ${JOIN_CMD}
     i=$((i+1))
  done
  sleep 30
fi
