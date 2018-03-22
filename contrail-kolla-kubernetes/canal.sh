#!/bin/sh
set -x
if [ `hostname` = "stacknamecontrol_hostname" ]
then
  curl -L https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml -o rbac.yaml
  kubectl --kubeconfig="/root/.kube/config" apply -f rbac.yaml
  curl -L https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml -o canal.yaml
  sed -i "s@10.244.0.0/16@10.1.0.0/16@" canal.yaml
  kubectl --kubeconfig="/root/.kube/config" apply -f canal.yaml
  kubectl --kubeconfig="/root/.kube/config" taint nodes --all=true  node-role.kubernetes.io/master:NoSchedule- 
echo 'apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: Group
  name: system:masters
- kind: Group
  name: system:authenticated
- kind: Group
  name: system:unauthenticated' > role.yaml
  kubectl --kubeconfig="/root/.kube/config" replace -f role.yaml

fi
