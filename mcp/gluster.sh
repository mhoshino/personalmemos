#!/bin/sh
set -x

python -c 'import json
obj={}
obj["clusters"]=[]
obj["clusters"].append(0)
obj["clusters"][0]={}
obj["clusters"][0]["nodes"]=[]

for i in range(0,2):
  obj["clusters"][0]["nodes"].append(i)
  obj["clusters"][0]["nodes"][i]={}
  obj["clusters"][0]["nodes"][i]["node"]={}
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]={}
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"]=[]
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"].append(0)
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["manage"][0]="node1"
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"]=[]
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"].append(0)
  obj["clusters"][0]["nodes"][i]["node"]["hostnames"]["storage"][0]="192.168.0.1"
  obj["clusters"][0]["nodes"][i]["node"]["zone"]="1"
  obj["clusters"][0]["nodes"][i]["devices"]=[]
  obj["clusters"][0]["nodes"][i]["devices"].append(0)
  obj["clusters"][0]["nodes"][i]["devices"][0]="/dev/gluster-loop"
print(json.dumps(obj))' > gluster_top.json


