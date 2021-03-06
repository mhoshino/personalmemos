#!/bin/sh
set -x
apt-get install -y glusterfs-client
modprobe dm_thin_pool
echo dm_thin_pool >> /etc/modules

if [ `hostname` = "stacknamecontrol_hostname" ]
then
cp /etc/kubernetes/admin.conf /kube-gluster.conf
export KUBECTL="kubectl --kubeconfig /kube-gluster.conf"
${KUBECTL} create namespace gluster
${KUBECTL} config set-context gluster --cluster=kubernetes --user=kubernetes-admin --namespace=gluster
${KUBECTL} config use-context gluster
apt-get install -y jq
i=0
whereis kubectl || exit 1

while true
do
   if [ $i -ge computecount ]
   then
     break
   fi
   ${KUBECTL} label node stacknamecompute_hostname${i} storagenode=glusterfs
   i=$((i+1))
done

git clone https://github.com/heketi/heketi
( cd heketi/extras/kubernetes; ${KUBECTL} create -f glusterfs-daemonset.json ; ${KUBECTL} create -f heketi-service-account.json; ${KUBECTL} create clusterrolebinding heketi-gluster-admin --clusterrole=edit --serviceaccount=default:heketi-service-account; ${KUBECTL} create secret generic heketi-config-secret --from-file=./heketi.json; ${KUBECTL} create -f heketi-bootstrap.json )



HEKETI_BIN="heketi-cli"      # heketi or heketi-cli
HEKETI_VERSION="6.0.0"       # latest heketi version => https://github.com/heketi/heketi/releases
HEKETI_OS="linux"            # linux or darwin
curl -SL https://github.com/heketi/heketi/releases/download/v${HEKETI_VERSION}/heketi-v${HEKETI_VERSION}.${HEKETI_OS}.amd64.tar.gz -o /tmp/heketi-v${HEKETI_VERSION}.${HEKETI_OS}.amd64.tar.gz && \
tar xzvf /tmp/heketi-v${HEKETI_VERSION}.${HEKETI_OS}.amd64.tar.gz -C /tmp && \
rm -vf /tmp/heketi-v${HEKETI_VERSION}.${HEKETI_OS}.amd64.tar.gz && \
cp /tmp/heketi/${HEKETI_BIN} /usr/local/bin/${HEKETI_BIN}_${HEKETI_VERSION} && \
rm -vrf /tmp/heketi && \
cd /usr/local/bin && \
ln -vsnf ${HEKETI_BIN}_${HEKETI_VERSION} ${HEKETI_BIN} && cd

cd /
HEKETI_IP=`${KUBECTL} get services deploy-heketi -o json | jq .spec.clusterIP -r`
HEKETI_PORT=`${KUBECTL} get services deploy-heketi -o json | jq .spec.ports[0].port -r`
export HEKETI_CLI_SERVER=http://${HEKETI_IP}:${HEKETI_PORT}
python -c 'import json
obj={}
obj["clusters"]=[]
obj["clusters"].append(0)
obj["clusters"][0]={}
obj["clusters"][0]["nodes"]=[]

for i in range(0,computecount):
  obj["clusters"][0]["nodes"].append(i)
  obj["clusters"][0]["nodes"][i]={}
  obj["clusters"][0]["nodes"][i]["node"]={}
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]={}
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"]=[]
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"].append(0)
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"][0]="stacknamecompute_hostname"+str(i)
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"]=[]
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"].append(0)
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"][0]="compute_ip"+str(i)
  obj["clusters"][0]["nodes"][i]["node"]["zone"]=1
  obj["clusters"][0]["nodes"][i]["devices"]=[]
  obj["clusters"][0]["nodes"][i]["devices"].append(0)
  obj["clusters"][0]["nodes"][i]["devices"][0]="gluster_device"
print(json.dumps(obj))' > gluster_top.json
sleep 60
heketi-cli topology load --json=gluster_top.json || exit 0
heketi-cli setup-openshift-heketi-storage
${KUBECTL} create -f heketi-storage.json
sleep 60
${KUBECTL} get jobs
${KUBECTL} delete all,service,jobs,deployment,secret --selector="deploy-heketi"
( cd heketi/extras/kubernetes; ${KUBECTL} create -f heketi-deployment.json )

HEKETI_IP=`${KUBECTL} get services heketi -o json | jq .spec.clusterIP -r`
HEKETI_PORT=`${KUBECTL} get services heketi -o json | jq .spec.ports[0].port -r`
export HEKETI_CLI_SERVER=http://${HEKETI_IP}:${HEKETI_PORT}
echo "
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: general
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: ${HEKETI_CLI_SERVER}" > storage-class.yml
${KUBECTL} create -f storage-class.yml
    
fi



