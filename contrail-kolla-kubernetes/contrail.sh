#!/bin/sh
set -x
if [ `hostname` = "stacknamecontrol_hostname" ]
then
  apt-get install -y git
  git clone https://github.com/Juniper/contrail-docker.git
  cd contrail-docker/kubernetes/helm
  sed -i 's/10.87.65.155/control_ip/g' contrail/values.yaml
  sed -i 's@10.32.0.0/12@10.1.0.0/16@g' contrail/values.yaml
  sed -i 's@10.96.0.0/12@10.3.3.0/24@g' contrail/values.yaml
  ssh localhost helm install --name contrail /contrail-docker/kubernetes/helm/contrail
  sleep 60
fi
