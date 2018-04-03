#!/bin/sh
set -x
export KUBECTL="${KUBECTL} --kubeconfig /etc/kubernetes/admin.conf"
if [ `hostname` = "stacknamecontrol_hostname" ]
then
  apt-get install -y git
  git clone https://github.com/Juniper/contrail-docker.git
  ${KUBECTL} label nodes stacknamecontrol_hostname opencontrail.org/controller=true
  cd contrail-docker/kubernetes/manifests/
  sed -i 's/10.87.65.155/control_ip/g'  contrail-host-ubuntu.yaml
  ${KUBECTL} patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:8081/readiness"]}}}]' -n kube-system
  ${KUBECTL} patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/kubedns"]}}}]' -n kube-system && ${KUBECTL} patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/1/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/healthcheck/dnsmasq"]}}}]' -n kube-system && ${KUBECTL} patch deploy/kube-dns --type json  -p='[{"op": "replace", "path": "/spec/template/spec/containers/2/livenessProbe", "value": {"exec": {"command": ["wget", "-O", "-", "http://127.0.0.1:10054/metrics"]}}}]' -n kube-system

  ${KUBECTL} apply -f contrail-host-ubuntu.yaml
  sleep 60
  ${KUBECTL} get pods -n kube-system
  for pod_name in `${KUBECTL} get pods -n kube-system -o wide | grep contrail | awk '{print $1}'`; do ${KUBECTL} exec -it  $pod_name -n kube-system -- contrail-status ; done
fi

