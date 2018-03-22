#!/bin/sh
set -x
echo "control_ip  stacknamecontrol_hostname" >> /etc/hosts
ssh-keyscan localhost >> /root/.ssh/known_hosts
ssh-keyscan stacknamecontrol_hostname >> /root/.ssh/known_hosts
ssh-keyscan 127.0.0.1 >> /root/.ssh/known_hosts
ssh-keyscan control_ip >> /root/.ssh/known_hosts
i=0
while true
do
   if [ $i -ge servercount ]
   then
     break
   fi
   echo "compute_ip$i stacknamecompute_hostname$i" >> /etc/hosts
   ssh-keyscan stacknamecompute_hostname$i >> /root/.ssh/known_hosts
   ssh-keyscan compute_ip$i >> /root/.ssh/known_hosts
   i=$((i+1))
done
apt-get install -y python docker docker.io
python -c 'import json; obj={}; obj["bip"]="docker_bridge_ip"; print(json.dumps(obj))' > /etc/docker/daemon.json
systemctl restart docker
