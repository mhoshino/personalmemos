#!/bin/sh
set -x
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo -E apt-key add -
cat <<EOF > kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo cp -aR kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y docker.io kubelet kubeadm kubectl kubernetes-cni
CGROUP_DRIVER=$(sudo docker info | grep "Cgroup Driver" | awk '{print $3}')
sudo sed -i "s|KUBELET_KUBECONFIG_ARGS=|KUBELET_KUBECONFIG_ARGS=--cgroup-driver=$CGROUP_DRIVER |g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i 's/10.96.0.10/10.3.3.10/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl stop kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet
if [ `hostname` = "stacknamecontrol_hostname" ]
then
  sudo kubeadm init --pod-network-cidr=10.1.0.0/16 --service-cidr=10.3.3.0/24
  mkdir -p /root/.kube
  sudo -H cp /etc/kubernetes/admin.conf /root/.kube/config
  sudo -H chown $(id -u):$(id -g) /root/.kube/config

  TOKEN=`kubeadm token generate`
  JOIN_CMD=`kubeadm token create ${TOKEN} --print-join-command --ttl=0`
  i=0
  while true
  do
     if [ $i -ge computecount ]
     then
       break
     fi
     ssh stacknamecompute_hostname${i} ${JOIN_CMD}
     i=$((i+1))
  done
  sleep 60
fi
