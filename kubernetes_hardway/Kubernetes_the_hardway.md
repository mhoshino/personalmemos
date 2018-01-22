# Deploy Kubernetes the Hardway with Vagrant

### Deploy 3 Core os Servers

```
Mirantis:coreos-vagrant machi$ export NUM_INSTANCES=3
Mirantis:coreos-vagrant machi$ vagrant up
Bringing machine 'core-01' up with 'virtualbox' provider...
Bringing machine 'core-02' up with 'virtualbox' provider...
Bringing machine 'core-03' up with 'virtualbox' provider...
==> core-01: Importing base box 'coreos-alpha'...
==> core-01: Configuring Ignition Config Drive
==> core-01: Matching MAC address for NAT networking...
==> core-01: Checking if box 'coreos-alpha' is up to date...
==> core-01: Setting the name of the VM: coreos-vagrant_core-01_1515567326072_69333
==> core-01: Clearing any previously set network interfaces...
==> core-01: Preparing network interfaces based on configuration...
    core-01: Adapter 1: nat
    core-01: Adapter 2: hostonly
==> core-01: Forwarding ports...
    core-01: 22 (guest) => 2222 (host) (adapter 1)
==> core-01: Running 'pre-boot' VM customizations...
==> core-01: Booting VM...
==> core-01: Waiting for machine to boot. This may take a few minutes...
    core-01: SSH address: 127.0.0.1:2222
    core-01: SSH username: core
    core-01: SSH auth method: private key
	==> core-01: Machine booted and ready!
==> core-01: Setting hostname...
==> core-01: Configuring and enabling network interfaces...
==> core-02: Importing base box 'coreos-alpha'...
==> core-02: Configuring Ignition Config Drive
==> core-02: Matching MAC address for NAT networking...
==> core-02: Checking if box 'coreos-alpha' is up to date...
==> core-02: Setting the name of the VM: coreos-vagrant_core-02_1515567348055_4392
==> core-02: Fixed port collision for 22 => 2222. Now on port 2200.
==> core-02: Clearing any previously set network interfaces...
==> core-02: Preparing network interfaces based on configuration...
    core-02: Adapter 1: nat
    core-02: Adapter 2: hostonly
==> core-02: Forwarding ports...
    core-02: 22 (guest) => 2200 (host) (adapter 1)
==> core-02: Running 'pre-boot' VM customizations...
==> core-02: Booting VM...
==> core-02: Waiting for machine to boot. This may take a few minutes...
    core-02: SSH address: 127.0.0.1:2200
    core-02: SSH username: core
    core-02: SSH auth method: private key
==> core-02: Machine booted and ready!
==> core-02: Setting hostname...
==> core-02: Configuring and enabling network interfaces...
==> core-03: Importing base box 'coreos-alpha'...
==> core-03: Configuring Ignition Config Drive
==> core-03: Matching MAC address for NAT networking...
==> core-03: Checking if box 'coreos-alpha' is up to date...
==> core-03: Setting the name of the VM: coreos-vagrant_core-03_1515567369799_32107
==> core-03: Fixed port collision for 22 => 2222. Now on port 2201.
==> core-03: Clearing any previously set network interfaces...
==> core-03: Preparing network interfaces based on configuration...
    core-03: Adapter 1: nat
    core-03: Adapter 2: hostonly
==> core-03: Forwarding ports...
    core-03: 22 (guest) => 2201 (host) (adapter 1)
==> core-03: Running 'pre-boot' VM customizations...
==> core-03: Booting VM...
==> core-03: Waiting for machine to boot. This may take a few minutes...
    core-03: SSH address: 127.0.0.1:2201
    core-03: SSH username: core
    core-03: SSH auth method: private key
==> core-03: Machine booted and ready!
==> core-03: Setting hostname...
==> core-03: Configuring and enabling network interfaces...
Mirantis:coreos-vagrant machi$
```

## SSH into core-01 (which will be the master)

```
Mirantis:coreos-vagrant machi$ vagrant ssh core-01
Last login: Wed Jan 10 06:57:31 UTC 2018 from 10.0.2.2 on pts/0
Container Linux by CoreOS alpha (1649.0.0)
core@core-01 ~ $
```

## Dowonload Curlssl
```
core@core-01 ~ $ mkdir bin
core@core-01 ~ $ sudo curl -s -L -o ~/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
core@core-01 ~ $ curl -s -L -o ~/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
core@core-01 ~ $ sudo chmod +x ~/bin/{cfssl,cfssljson}
core@core-01 ~ $ export PATH=$PATH:~/bin
core@core-01 ~ $
```

## Create CA Key
```
core@core-01 ~ $ cat > ca-config.json <<EOF
> {
>   "signing": {
>     "default": {
>       "expiry": "8760h"
>     },
>     "profiles": {
>       "kubernetes": {
>         "usages": ["signing", "key encipherment", "server auth", "client auth"],
>         "expiry": "8760h"
>       }
>     }
>   }
> }
> EOF
core@core-01 ~ $ cat > ca-csr.json <<EOF
> {
>   "CN": "Kubernetes",
>   "key": {
>     "algo": "rsa",
>     "size": 2048
>   },
>   "names": [
>     {
>       "C": "US",
>       "L": "Portland",
>       "O": "Kubernetes",
>       "OU": "CA",
>       "ST": "Oregon"
>     }
>   ]
> }
> EOF
```
```
core@core-01 ~ $ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
2018/01/10 07:06:15 [INFO] generating a new CA key and certificate from CSR
2018/01/10 07:06:15 [INFO] generate received request
2018/01/10 07:06:15 [INFO] received CSR
2018/01/10 07:06:15 [INFO] generating key: rsa-2048
2018/01/10 07:06:15 [INFO] encoded CSR
2018/01/10 07:06:15 [INFO] signed certificate with serial number 267087463808363400360413569907485857134176242093
core@core-01 ~ $ ls -l
total 48
drwxr-xr-x. 2 core core 4096 Jan 10 07:04 bin
-rw-r--r--. 1 core core  232 Jan 10 06:58 ca-config.json
-rw-r--r--. 1 core core  211 Jan 10 06:59 ca-csr.json
-rw-------. 1 core core 1675 Jan 10 07:06 ca-key.pem
-rw-r--r--. 1 core core 1005 Jan 10 07:06 ca.csr
-rw-r--r--. 1 core core 1367 Jan 10 07:06 ca.pem
core@core-01 ~ $
```
## Generate Administrator Key
```
core@core-01 ~ $ cat > admin-csr.json <<EOF
> {
>   "CN": "admin",
>   "key": {
>     "algo": "rsa",
>     "size": 2048
>   },
>   "names": [
>     {
>       "C": "US",
>       "L": "Portland",
>       "O": "system:masters",
>       "OU": "Kubernetes The Hard Way",
>       "ST": "Oregon"
>     }
>   ]
> }
> EOF
core@core-01 ~ $ cfssl gencert \
>   -ca=ca.pem \
>   -ca-key=ca-key.pem \
>   -config=ca-config.json \
>   -profile=kubernetes \
>   admin-csr.json | cfssljson -bare admin
2018/01/10 07:07:18 [INFO] generate received request
2018/01/10 07:07:18 [INFO] received CSR
2018/01/10 07:07:18 [INFO] generating key: rsa-2048
2018/01/10 07:07:18 [INFO] encoded CSR
2018/01/10 07:07:18 [INFO] signed certificate with serial number 289217158605514474546693698136611908427598085752
2018/01/10 07:07:18 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
core@core-01 ~ $ ks 0k
-bash: ks: command not found
core@core-01 ~ $ ls -l
total 80
-rw-r--r--. 1 core core  231 Jan 10 07:07 admin-csr.json
-rw-------. 1 core core 1679 Jan 10 07:07 admin-key.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:07 admin.csr
-rw-r--r--. 1 core core 1428 Jan 10 07:07 admin.pem
drwxr-xr-x. 2 core core 4096 Jan 10 07:04 bin
-rw-r--r--. 1 core core  232 Jan 10 06:58 ca-config.json
-rw-r--r--. 1 core core  211 Jan 10 06:59 ca-csr.json
-rw-------. 1 core core 1675 Jan 10 07:06 ca-key.pem
-rw-r--r--. 1 core core 1005 Jan 10 07:06 ca.csr
-rw-r--r--. 1 core core 1367 Jan 10 07:06 ca.pem
core@core-01 ~ $
```

## Generate Client Key
```
for instance in 2 3; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:core-0${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
     cfssl gencert   -ca=ca.pem   -ca-key=ca-key.pem   -config=ca-config.json   -hostname=core-0${instance},172.17.8.10${instance}   -profile=kubernetes   ${instance}-csr.json | cfssljson -bare ${instance}; done

core@core-01 ~ $ for instance in 2 3; do   kubectl config set-cluster kubernetes-the-hard-way     --certificate-authority=ca.pem     --embed-certs=true     --server=https://172.17.8.101:6443     --kubeconfig=core-0${instance}.kubeconfig;    kubectl config set-credentials system:node:core-0${instance}     --client-certificate=${instance}.pem     --client-key=${instance}-key.pem     --embed-certs=true     --kubeconfig=core-0${instance}.kubeconfig;    kubectl config set-context default     --cluster=kubernetes-the-hard-way     --user=system:node:core-0${instance}     --kubeconfig=core-0${instance}.kubeconfig;    kubectl config use-context default --kubeconfig=core-0${instance}.kubeconfig; done
Cluster "kubernetes-the-hard-way" set.
User "system:node:core-02" set.
Context "default" modified.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:core-03" set.
Context "default" modified.
Switched to context "default".
```
## Generate Kube Proxy Key

```
core@core-01 ~ $ cat > kube-proxy-csr.json <<EOF
> {
>   "CN": "system:kube-proxy",
>   "key": {
>     "algo": "rsa",
>     "size": 2048
>   },
>   "names": [
>     {
>       "C": "US",
>       "L": "Portland",
>       "O": "system:node-proxier",
>       "OU": "Kubernetes The Hard Way",
>       "ST": "Oregon"
>     }
>   ]
> }
> EOF
core@core-01 ~ $ cfssl gencert \
>   -ca=ca.pem \
>   -ca-key=ca-key.pem \
>   -config=ca-config.json \
>   -profile=kubernetes \
>   kube-proxy-csr.json | cfssljson -bare kube-proxy
2018/01/10 07:23:55 [INFO] generate received request
2018/01/10 07:23:55 [INFO] received CSR
2018/01/10 07:23:55 [INFO] generating key: rsa-2048
2018/01/10 07:23:56 [INFO] encoded CSR
2018/01/10 07:23:56 [INFO] signed certificate with serial number 706062672027554315998388035977923483613009152828
2018/01/10 07:23:56 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
core@core-01 ~ $ ls -l
total 176
-rw-r--r--. 1 core core  237 Jan 10 07:11 2-csr.json
-rw-------. 1 core core 1679 Jan 10 07:11 2-key.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 2.csr
-rw-r--r--. 1 core core 1476 Jan 10 07:11 2.pem
-rw-r--r--. 1 core core  237 Jan 10 07:11 3-csr.json
-rw-------. 1 core core 1675 Jan 10 07:11 3-key.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 3.csr
-rw-r--r--. 1 core core 1476 Jan 10 07:11 3.pem
-rw-r--r--. 1 core core  231 Jan 10 07:07 admin-csr.json
-rw-------. 1 core core 1679 Jan 10 07:07 admin-key.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:07 admin.csr
-rw-r--r--. 1 core core 1428 Jan 10 07:07 admin.pem
drwxr-xr-x. 2 core core 4096 Jan 10 07:04 bin
-rw-r--r--. 1 core core  232 Jan 10 06:58 ca-config.json
-rw-r--r--. 1 core core  211 Jan 10 06:59 ca-csr.json
-rw-------. 1 core core 1675 Jan 10 07:06 ca-key.pem
-rw-r--r--. 1 core core 1005 Jan 10 07:06 ca.csr
-rw-r--r--. 1 core core 1367 Jan 10 07:06 ca.pem
-rw-r--r--. 1 core core  248 Jan 10 07:23 kube-proxy-csr.json
-rw-------. 1 core core 1679 Jan 10 07:23 kube-proxy-key.pem
-rw-r--r--. 1 core core 1058 Jan 10 07:23 kube-proxy.csr
-rw-r--r--. 1 core core 1452 Jan 10 07:23 kube-proxy.pem
core@core-01 ~ $
```

## Generate Kubernetes CSR Key
```
core@core-01 ~ $ cat > kubernetes-csr.json <<EOF
> {
>   "CN": "kubernetes",
>   "key": {
>     "algo": "rsa",
>     "size": 2048
>   },
>   "names": [
>     {
>       "C": "US",
>       "L": "Portland",
>       "O": "Kubernetes",
>       "OU": "Kubernetes The Hard Way",
>       "ST": "Oregon"
>     }
>   ]
> }
> EOF

core@core-01 ~ $ cfssl gencert \
>   -ca=ca.pem \
>   -ca-key=ca-key.pem \
>   -config=ca-config.json \
>   -hostname=core-01,172.17.8.101 \
>   -profile=kubernetes \
>   kubernetes-csr.json | cfssljson -bare kubernetes
2018/01/10 07:25:56 [INFO] generate received request
2018/01/10 07:25:56 [INFO] received CSR
2018/01/10 07:25:56 [INFO] generating key: rsa-2048
2018/01/10 07:25:57 [INFO] encoded CSR
2018/01/10 07:25:57 [INFO] signed certificate with serial number 494807202360969123212271598080492596293248179994
core@core-01 ~ $ ls -l
total 208
-rw-r--r--. 1 core core  237 Jan 10 07:11 2-csr.json
-rw-------. 1 core core 1679 Jan 10 07:11 2-key.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 2.csr
-rw-r--r--. 1 core core 1476 Jan 10 07:11 2.pem
-rw-r--r--. 1 core core  237 Jan 10 07:11 3-csr.json
-rw-------. 1 core core 1675 Jan 10 07:11 3-key.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 3.csr
-rw-r--r--. 1 core core 1476 Jan 10 07:11 3.pem
-rw-r--r--. 1 core core  231 Jan 10 07:07 admin-csr.json
-rw-------. 1 core core 1679 Jan 10 07:07 admin-key.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:07 admin.csr
-rw-r--r--. 1 core core 1428 Jan 10 07:07 admin.pem
drwxr-xr-x. 2 core core 4096 Jan 10 07:04 bin
-rw-r--r--. 1 core core  232 Jan 10 06:58 ca-config.json
-rw-r--r--. 1 core core  211 Jan 10 06:59 ca-csr.json
-rw-------. 1 core core 1675 Jan 10 07:06 ca-key.pem
-rw-r--r--. 1 core core 1005 Jan 10 07:06 ca.csr
-rw-r--r--. 1 core core 1367 Jan 10 07:06 ca.pem
-rw-r--r--. 1 core core  248 Jan 10 07:23 kube-proxy-csr.json
-rw-------. 1 core core 1679 Jan 10 07:23 kube-proxy-key.pem
-rw-r--r--. 1 core core 1058 Jan 10 07:23 kube-proxy.csr
-rw-r--r--. 1 core core 1452 Jan 10 07:23 kube-proxy.pem
-rw-r--r--. 1 core core  232 Jan 10 07:25 kubernetes-csr.json
-rw-------. 1 core core 1679 Jan 10 07:25 kubernetes-key.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:25 kubernetes.csr
-rw-r--r--. 1 core core 1468 Jan 10 07:25 kubernetes.pem
core@core-01 ~ $
```
## Send Key to instance

```
core@core-01 ~ $ for instance in 2 3; do   scp ca.pem ${instance}-key.pem ${instance}.pem 172.17.8.10${instance}:~/; done
Password:
ca.pem                                                                                                                                                                    100% 1367     1.2MB/s   00:00
2-key.pem                                                                                                                                                                 100% 1679     2.2MB/s   00:00
2.pem                                                                                                                                                                     100% 1476     1.7MB/s   00:00
The authenticity of host '172.17.8.103 (172.17.8.103)' can't be established.
ECDSA key fingerprint is SHA256:0ope09jrqm/o8j2SF04Bt1guisQY5ireWkwbmj/QRhQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.17.8.103' (ECDSA) to the list of known hosts.
Password:
ca.pem                                                                                                                                                                    100% 1367     1.4MB/s   00:00
3-key.pem                                                                                                                                                                 100% 1675     1.9MB/s   00:00
3.pem                                                                                                                                                                     100% 1476     1.8MB/s   00:00
core@core-01 ~ $
```

## Download and configure Kubectl

```
core@core-01 ~ $ wget https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl
--2018-01-10 07:33:09--  https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl
Resolving storage.googleapis.com... 216.58.197.176
Connecting to storage.googleapis.com|216.58.197.176|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 67390552 (64M) [application/octet-stream]
Saving to: 'kubectl'

kubectl                                            100%[================================================================================================================>]  64.27M  41.3MB/s    in 1.6s

2018-01-10 07:33:12 (41.3 MB/s) - 'kubectl' saved [67390552/67390552]

core@core-01 ~ $ chmod +x kubectl
core@core-01 ~ $ sudo mv kubectl /usr/local/bin/
mv: inter-device move failed: 'kubectl' to '/usr/local/bin/kubectl'; unable to remove target: Read-only file system
core@core-01 ~ $ sudo mv kube bin/
mv: cannot stat 'kube': No such file or directory
core@core-01 ~ $ sudo mv kubectl bin/
core@core-01 ~ $
```

## Register client Keys
```
core@core-01 ~ $ for instance in 2 3; do
>   kubectl config set-cluster kubernetes-the-hard-way \
>     --certificate-authority=ca.pem \
>     --embed-certs=true \
>     --server=https://172.17.8.101:6443 \
>     --kubeconfig=core-0${instance}.kubeconfig
>
>   kubectl config set-credentials system:node:core-0${instance} \
>     --client-certificate=${instance}.pem \
>     --client-key=${instance}-key.pem \
>     --embed-certs=true \
>     --kubeconfig=core-0${instance}.kubeconfig
>
>   kubectl config set-context default \
>     --cluster=kubernetes-the-hard-way \
>     --user=system:node:core-0${instance} \
>     --kubeconfig=core-0${instance}.kubeconfig
>
>   kubectl config use-context default --kubeconfig=core-0${instance}.kubeconfig
> done
Cluster "kubernetes-the-hard-way" set.
User "system:node:core-02" set.
Context "default" modified.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:core-03" set.
Context "default" modified.
Switched to context "default".
core@core-01 ~ $
```

## Create Kube config URL

```
core@core-01 ~ $ export KUBERNETES_PUBLIC_ADDRESS=172.17.8.101
core@core-01 ~ $
core@core-01 ~ $
core@core-01 ~ $ kubectl config set-cluster kubernetes-the-hard-way \
>   --certificate-authority=ca.pem \
>   --embed-certs=true \
>   --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
>   --kubeconfig=kube-proxy.kubeconfig
Cluster "kubernetes-the-hard-way" set.
core@core-01 ~ $ kubectl config set-credentials kube-proxy \
>   --client-certificate=kube-proxy.pem \
>   --client-key=kube-proxy-key.pem \
>   --embed-certs=true \
>   --kubeconfig=kube-proxy.kubeconfig
User "kube-proxy" set.
core@core-01 ~ $ kubectl config set-context default \
>   --cluster=kubernetes-the-hard-way \
>   --user=kube-proxy \
>   --kubeconfig=kube-proxy.kubeconfig
Context "default" created.
core@core-01 ~ $ kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
Switched to context "default".
core@core-01 ~ $ ls -ltr
total 260
-rw-r--r--. 1 core core  232 Jan 10 06:58 ca-config.json
-rw-r--r--. 1 core core  211 Jan 10 06:59 ca-csr.json
-rw-r--r--. 1 core core 1367 Jan 10 07:06 ca.pem
-rw-r--r--. 1 core core 1005 Jan 10 07:06 ca.csr
-rw-------. 1 core core 1675 Jan 10 07:06 ca-key.pem
-rw-r--r--. 1 core core  231 Jan 10 07:07 admin-csr.json
-rw-r--r--. 1 core core 1428 Jan 10 07:07 admin.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:07 admin.csr
-rw-------. 1 core core 1679 Jan 10 07:07 admin-key.pem
-rw-r--r--. 1 core core  237 Jan 10 07:11 3-csr.json
-rw-r--r--. 1 core core 1476 Jan 10 07:11 2.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 2.csr
-rw-------. 1 core core 1679 Jan 10 07:11 2-key.pem
-rw-r--r--. 1 core core  237 Jan 10 07:11 2-csr.json
-rw-r--r--. 1 core core 1476 Jan 10 07:11 3.pem
-rw-r--r--. 1 core core 1041 Jan 10 07:11 3.csr
-rw-------. 1 core core 1675 Jan 10 07:11 3-key.pem
-rw-r--r--. 1 core core  248 Jan 10 07:23 kube-proxy-csr.json
-rw-r--r--. 1 core core 1452 Jan 10 07:23 kube-proxy.pem
-rw-r--r--. 1 core core 1058 Jan 10 07:23 kube-proxy.csr
-rw-------. 1 core core 1679 Jan 10 07:23 kube-proxy-key.pem
-rw-r--r--. 1 core core  232 Jan 10 07:25 kubernetes-csr.json
-rw-r--r--. 1 core core 1468 Jan 10 07:25 kubernetes.pem
-rw-r--r--. 1 core core 1033 Jan 10 07:25 kubernetes.csr
-rw-------. 1 core core 1679 Jan 10 07:25 kubernetes-key.pem
drwxr-xr-x. 2 core core 4096 Jan 10 07:57 bin
-rw-------. 1 core core 2035 Jan 10 08:02 2.kubeconfig
-rw-------. 1 core core 2035 Jan 10 08:02 3.kubeconfig
-rw-------. 1 core core 6446 Jan 10 08:09 core-02.kubeconfig
-rw-------. 1 core core 6442 Jan 10 08:09 core-03.kubeconfig
-rw-------. 1 core core 6396 Jan 10 08:12 kube-proxy.kubeconfig
```

## Send kubeconfig files to client

```
core@core-01 ~ $ for instance in 2 3; do
>   scp core-0${instance}.kubeconfig kube-proxy.kubeconfig 172.17.8.10${instance}:~/
> done
Password:
core-02.kubeconfig                                                                                                                                                        100% 6446     6.0MB/s   00:00
kube-proxy.kubeconfig                                                                                                                                                     100% 6396     7.8MB/s   00:00
Password:
core-03.kubeconfig                                                                                                                                                        100% 6442     5.9MB/s   00:00
kube-proxy.kubeconfig                                                                                                                                                     100% 6396     6.9MB/s   00:00
core@core-01 ~ $
```

## Create Encryption Key

```
core@core-01 ~ $ ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
core@core-01 ~ $ echo $ENCRYPTION_KEY
Hmkpr7e55Wkh7aGxRrlyd2hX0AtY8BpDpKRMBPugPTM=
core@core-01 ~ $
core@core-01 ~ $ cat > encryption-config.yaml <<EOF
> kind: EncryptionConfig
> apiVersion: v1
> resources:
>   - resources:
>       - secrets
>     providers:
>       - aescbc:
>           keys:
>             - name: key1
>               secret: ${ENCRYPTION_KEY}
>       - identity: {}
> EOF
core@core-01 ~ $
```

## Configure ETCD

```
core@core-01 ~ $ wget -q --show-progress --https-only --timestamping \
>   "https://github.com/coreos/etcd/releases/download/v3.2.11/etcd-v3.2.11-linux-amd64.tar.gz"
etcd-v3.2.11-linux-amd64.tar.gz                    100%[================================================================================================================>]  10.06M  2.78MB/s    in 4.0s
core@core-01 ~ $
```

```
core@core-01 /etc $ sudo mkdir -p /etc/etcd /var/lib/etcd
core@core-01 /etc $ cd
core@core-01 ~ $
core@core-01 ~ $ sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
core@core-01 ~ $ INTERNAL_IP=172.17.8.101
core@core-01 ~ $ ETCD_NAME=$(hostname -s)
```

```
core@core-01 /var/lib/etcd2 $ cd /etc/
core@core-01 /etc $ sudo mkdir -p /etc/etcd /var/lib/etcd
core@core-01 /etc $ cd
core@core-01 ~ $
core@core-01 ~ $ sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
core@core-01 ~ $ INTERNAL_IP=172.17.8.101
core@core-01 ~ $ ETCD_NAME=$(hostname -s)
core@core-01 ~ $ systemctl list-unit-files | grep etcd
etcd-member.service                    disabled
etcd2.service                          disabled
core@core-01 ~ $ mv etcd* bin/
core@core-01 ~ $
```

```
core@core-01 ~ $ INTERNAL_IP=172.17.8.101
core@core-01 ~ $ ETCD_NAME=$(hostname -s)
core@core-01 ~ $ systemctl list-unit-files | grep etcd
etcd-member.service                    disabled
etcd2.service                          disabled
core@core-01 ~ $ mv etcd* bin/
core@core-01 ~ $ whereis etcd
etcd: /etc/etcd /home/core/bin/etcd
core@core-01 ~ $ cat > etcd.service <<EOF
> [Unit]
> Description=etcd
> Documentation=https://github.com/coreos
>
> [Service]
> ExecStart=/home/core/bin/etcd \\
>   --name ${ETCD_NAME} \\
>   --cert-file=/etc/etcd/kubernetes.pem \\
>   --key-file=/etc/etcd/kubernetes-key.pem \\
>   --peer-cert-file=/etc/etcd/kubernetes.pem \\
>   --peer-key-file=/etc/etcd/kubernetes-key.pem \\
>   --trusted-ca-file=/etc/etcd/ca.pem \\
>   --peer-trusted-ca-file=/etc/etcd/ca.pem \\
>   --peer-client-cert-auth \\
>   --client-cert-auth \\
>   --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
>   --listen-peer-urls https://${INTERNAL_IP}:2380 \\
>   --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
>   --advertise-client-urls https://${INTERNAL_IP}:2379 \\
>   --initial-cluster-token etcd-cluster-0 \\
>   --initial-cluster core-01=https://172.17.8.101:2380 \\
>   --initial-cluster-state new \\
>   --data-dir=/var/lib/etcd
> Restart=on-failure
> RestartSec=5
>
> [Install]
> WantedBy=multi-user.target
> EOF
```

```
core@core-01 ~ $ sudo mv etcd.service /etc/systemd/system/
core@core-01 ~ $ sudo systemctl daemon-reload
core@core-01 ~ $ sudo systemctl enable etcd
Created symlink /etc/systemd/system/multi-user.target.wants/etcd.service → /etc/systemd/system/etcd.service.
core@core-01 ~ $ sudo systemctl start etcd
core@core-01 ~ $ ETCDCTL_API=3 etcdctl member list
6ec2deaa952b731e, started, core-01, https://172.17.8.101:2380, https://172.17.8.101:2379
core@core-01 ~ $
```

## Download Kube Master Binaries

```
core@core-01 ~ $ wget -q --show-progress --https-only --timestamping \
>   "https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kube-apiserver" \
>   "https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kube-controller-manager" \
>   "https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kube-scheduler" \
>   "https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl"
kube-apiserver                                     100%[================================================================================================================>] 199.55M  45.7MB/s    in 5.3s
kube-controller-manager                            100%[================================================================================================================>] 130.29M  35.4MB/s    in 3.7s
kube-scheduler                                     100%[================================================================================================================>]  58.71M  45.9MB/s    in 1.3s
kubectl                                            100%[================================================================================================================>]  64.27M  43.3MB/s    in 1.5s
core@core-01 ~ $ chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
core@core-01 ~ $ sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /home/core/bin/
core@core-01 ~ $ sudo mkdir -p /var/lib/kubernetes/
core@core-01 ~ $ sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem encryption-config.yaml /var/lib/kubernetes/
core@core-01 ~ $ env | grep INTER
core@core-01 ~ $ INTERNAL_IP=172.17.8.101
core@core-01 ~ $ cat > kube-apiserver.service <<EOF
> [Unit]
> Description=Kubernetes API Server
> Documentation=https://github.com/kubernetes/kubernetes
>
> [Service]
> ExecStart=/home/core/bin/kube-apiserver \\
>   --admission-control=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
>   --advertise-address=${INTERNAL_IP} \\
>   --allow-privileged=true \\
>   --apiserver-count=3 \\
>   --audit-log-maxage=30 \\
>   --audit-log-maxbackup=3 \\
>   --audit-log-maxsize=100 \\
>   --audit-log-path=/var/log/audit.log \\
>   --authorization-mode=Node,RBAC \\
>   --bind-address=0.0.0.0 \\
>   --client-ca-file=/var/lib/kubernetes/ca.pem \\
>   --enable-swagger-ui=true \\
>   --etcd-cafile=/var/lib/kubernetes/ca.pem \\
>   --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
>   --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
>   --etcd-servers=https://172.17.8.101:2379 \\
>   --event-ttl=1h \\
>   --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
>   --insecure-bind-address=127.0.0.1 \\
>   --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
>   --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
>   --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
>   --kubelet-https=true \\
>   --runtime-config=api/all \\
>   --service-account-key-file=/var/lib/kubernetes/ca-key.pem \\
>   --service-cluster-ip-range=10.32.0.0/24 \\
>   --service-node-port-range=30000-32767 \\
>   --tls-ca-file=/var/lib/kubernetes/ca.pem \\
>   --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
>   --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
>   --v=2
> Restart=on-failure
> RestartSec=5
>
> [Install]
> WantedBy=multi-user.target
> EOF
core@core-01 ~ $ cat > kube-controller-manager.service <<EOF
> [Unit]
> Description=Kubernetes Controller Manager
> Documentation=https://github.com/kubernetes/kubernetes
>
> [Service]
> ExecStart=/home/core/bin/kube-controller-manager \\
>   --address=0.0.0.0 \\
>   --cluster-cidr=10.200.0.0/16 \\
>   --cluster-name=kubernetes \\
>   --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
>   --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
>   --leader-elect=true \\
>   --master=http://127.0.0.1:8080 \\
>   --root-ca-file=/var/lib/kubernetes/ca.pem \\
>   --service-account-private-key-file=/var/lib/kubernetes/ca-key.pem \\
>   --service-cluster-ip-range=10.32.0.0/24 \\
>   --v=2
> Restart=on-failure
> RestartSec=5
>
> [Install]
> WantedBy=multi-user.target
> EOF
core@core-01 ~ $ '
>
> ^C
core@core-01 ~ $ cat > kube-scheduler.service <<EOF
> [Unit]
> Description=Kubernetes Scheduler
> Documentation=https://github.com/kubernetes/kubernetes
>
> [Service]
> ExecStart=/home/core/bin/kube-scheduler \\
>   --leader-elect=true \\
>   --master=http://127.0.0.1:8080 \\
>   --v=2
> Restart=on-failure
> RestartSec=5
>
> [Install]
> WantedBy=multi-user.target
> EOF
core@core-01 ~ $
```

```
core@core-01 ~ $ sudo mv kube-apiserver.service kube-scheduler.service kube-controller-manager.service /etc/systemd/system/
core@core-01 ~ $ sudo systemctl daemon-reload
core@core-01 ~ $ sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
Created symlink /etc/systemd/system/multi-user.target.wants/kube-apiserver.service → /etc/systemd/system/kube-apiserver.service.
Created symlink /etc/systemd/system/multi-user.target.wants/kube-controller-manager.service → /etc/systemd/system/kube-controller-manager.service.
Created symlink /etc/systemd/system/multi-user.target.wants/kube-scheduler.service → /etc/systemd/system/kube-scheduler.service.
core@core-01 ~ $ sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
core@core-01 ~ $ sudo systemctl starus kube-apiserver kube-controller-manager kube-scheduler
Unknown operation starus.
core@core-01 ~ $ sudo systemctl status kube-apiserver kube-controller-manager kube-scheduler
● kube-apiserver.service - Kubernetes API Server
   Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2018-01-10 08:53:00 UTC; 14s ago
     Docs: https://github.com/kubernetes/kubernetes
 Main PID: 1610 (kube-apiserver)
    Tasks: 6 (limit: 32768)
   CGroup: /system.slice/kube-apiserver.service
           └─1610 /home/core/bin/kube-apiserver --admission-control=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota --advertise-address=172.17.

Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.302377    1610 wrap.go:42] GET /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system:controller:replication-controller: (1.309179ms) 40
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.325249    1610 wrap.go:42] POST /apis/rbac.authorization.k8s.io/v1/clusterrolebindings: (2.590417ms) 201 [[kube-apiserver/v1.9.0 (linux/amd64)
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.325731    1610 storage_rbac.go:236] created clusterrolebinding.rbac.authorization.k8s.io/system:controller:replication-controller
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.343053    1610 wrap.go:42] GET /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system:controller:resourcequota-controller: (1.272449ms)
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.365820    1610 wrap.go:42] POST /apis/rbac.authorization.k8s.io/v1/clusterrolebindings: (2.492133ms) 201 [[kube-apiserver/v1.9.0 (linux/amd64)
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.366235    1610 storage_rbac.go:236] created clusterrolebinding.rbac.authorization.k8s.io/system:controller:resourcequota-controller
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.382393    1610 wrap.go:42] GET /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system:controller:route-controller: (1.22378ms) 404 [[kub
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.404455    1610 wrap.go:42] POST /apis/rbac.authorization.k8s.io/v1/clusterrolebindings: (3.004022ms) 201 [[kube-apiserver/v1.9.0 (linux/amd64)
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.404868    1610 storage_rbac.go:236] created clusterrolebinding.rbac.authorization.k8s.io/system:controller:route-controller
Jan 10 08:53:14 core-01 kube-apiserver[1610]: I0110 08:53:14.428135    1610 wrap.go:42] GET /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system:controller:service-account-controller: (6.432125ms

● kube-controller-manager.service - Kubernetes Controller Manager
   Loaded: loaded (/etc/systemd/system/kube-controller-manager.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2018-01-10 08:53:00 UTC; 14s ago
     Docs: https://github.com/kubernetes/kubernetes
 Main PID: 1613 (kube-controller)
    Tasks: 4 (limit: 32768)
   CGroup: /system.slice/kube-controller-manager.service
           └─1613 /home/core/bin/kube-controller-manager --address=0.0.0.0 --cluster-cidr=10.200.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem --cluster-signing-k

Jan 10 08:53:00 core-01 kube-controller-manager[1613]: I0110 08:53:00.342874    1613 flags.go:52] FLAG: --vmodule=""
Jan 10 08:53:00 core-01 kube-controller-manager[1613]: I0110 08:53:00.342889    1613 controllermanager.go:108] Version: v1.9.0
Jan 10 08:53:00 core-01 kube-controller-manager[1613]: I0110 08:53:00.343347    1613 leaderelection.go:174] attempting to acquire leader lease...
Jan 10 08:53:00 core-01 kube-controller-manager[1613]: E0110 08:53:00.344222    1613 leaderelection.go:224] error retrieving resource lock kube-system/kube-controller-manager: Get http://127.0.0.1:8080/ap
Jan 10 08:53:03 core-01 kube-controller-manager[1613]: E0110 08:53:03.808562    1613 leaderelection.go:224] error retrieving resource lock kube-system/kube-controller-manager: Get http://127.0.0.1:8080/ap
Jan 10 08:53:12 core-01 kube-controller-manager[1613]: I0110 08:53:12.077799    1613 leaderelection.go:184] successfully acquired lease kube-system/kube-controller-manager
Jan 10 08:53:12 core-01 kube-controller-manager[1613]: I0110 08:53:12.078652    1613 event.go:218] Event(v1.ObjectReference{Kind:"Endpoints", Namespace:"kube-system", Name:"kube-controller-manager", UID:"
Jan 10 08:53:12 core-01 kube-controller-manager[1613]: E0110 08:53:12.084988    1613 controllermanager.go:386] Server isn't healthy yet.  Waiting a little while.
Jan 10 08:53:13 core-01 kube-controller-manager[1613]: E0110 08:53:13.087849    1613 controllermanager.go:386] Server isn't healthy yet.  Waiting a little while.
Jan 10 08:53:14 core-01 kube-controller-manager[1613]: E0110 08:53:14.090943    1613 controllermanager.go:386] Server isn't healthy yet.  Waiting a little while.

● kube-scheduler.service - Kubernetes Scheduler
   Loaded: loaded (/etc/systemd/system/kube-scheduler.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2018-01-10 08:53:00 UTC; 14s ago
     Docs: https://github.com/kubernetes/kubernetes
 Main PID: 1614 (kube-scheduler)
    Tasks: 5 (limit: 32768)
   CGroup: /system.slice/kube-scheduler.service
           └─1614 /home/core/bin/kube-scheduler --leader-elect=true --master=http://127.0.0.1:8080 --v=2

Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.384988    1614 reflector.go:205] k8s.io/kubernetes/vendor/k8s.io/client-go/informers/factory.go:86: Failed to list *v1.Service: Get http://127.
Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.385128    1614 reflector.go:205] k8s.io/kubernetes/vendor/k8s.io/client-go/informers/factory.go:86: Failed to list *v1.ReplicationController: G
Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.385262    1614 reflector.go:205] k8s.io/kubernetes/vendor/k8s.io/client-go/informers/factory.go:86: Failed to list *v1.PersistentVolume: Get ht
Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.388835    1614 reflector.go:205] k8s.io/kubernetes/vendor/k8s.io/client-go/informers/factory.go:86: Failed to list *v1beta1.StatefulSet: Get ht
Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.388976    1614 reflector.go:205] k8s.io/kubernetes/vendor/k8s.io/client-go/informers/factory.go:86: Failed to list *v1.Node: Get http://127.0.0
Jan 10 08:53:04 core-01 kube-scheduler[1614]: E0110 08:53:04.394796    1614 reflector.go:205] k8s.io/kubernetes/plugin/cmd/kube-scheduler/app/server.go:590: Failed to list *v1.Pod: Get http://127.0.0.1:80
Jan 10 08:53:06 core-01 kube-scheduler[1614]: I0110 08:53:06.153591    1614 controller_utils.go:1019] Waiting for caches to sync for scheduler controller
Jan 10 08:53:06 core-01 kube-scheduler[1614]: I0110 08:53:06.253824    1614 controller_utils.go:1026] Caches are synced for scheduler controller
Jan 10 08:53:06 core-01 kube-scheduler[1614]: I0110 08:53:06.253864    1614 leaderelection.go:174] attempting to acquire leader lease...
Jan 10 08:53:10 core-01 kube-scheduler[1614]: I0110 08:53:10.263718    1614 leaderelection.go:184] successfully acquired lease kube-system/kube-scheduler
core@core-01 ~ $ kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health": "true"}
core@core-01 ~ $
```
## Set RBAC

```
core@core-01 ~ $ cat <<EOF | kubectl apply -f -
> apiVersion: rbac.authorization.k8s.io/v1beta1
> kind: ClusterRole
> metadata:
>   annotations:
>     rbac.authorization.kubernetes.io/autoupdate: "true"
>   labels:
>     kubernetes.io/bootstrapping: rbac-defaults
>   name: system:kube-apiserver-to-kubelet
> rules:
>   - apiGroups:
>       - ""
>     resources:
>       - nodes/proxy
>       - nodes/stats
>       - nodes/log
>       - nodes/spec
>       - nodes/metrics
>     verbs:
>       - "*"
> EOF
clusterrole "system:kube-apiserver-to-kubelet" created
core@core-01 ~ $ cat <<EOF | kubectl apply -f -
> apiVersion: rbac.authorization.k8s.io/v1beta1
> kind: ClusterRoleBinding
> metadata:
>   name: system:kube-apiserver
>   namespace: ""
> roleRef:
>   apiGroup: rbac.authorization.k8s.io
>   kind: ClusterRole
>   name: system:kube-apiserver-to-kubelet
> subjects:
>   - apiGroup: rbac.authorization.k8s.io
>     kind: User
>     name: kubernetes
> EOF
clusterrolebinding "system:kube-apiserver" created
core@core-01 ~ $
```
## List Nodes
```
core@core-01 ~/bin $ ./kubectl get nodes -o wide
NAME      STATUS    ROLES     AGE       VERSION   EXTERNAL-IP   OS-IMAGE                                       KERNEL-VERSION   CONTAINER-RUNTIME
core-02   Ready     <none>    3m        v1.9.0    <none>        Container Linux by CoreOS 1649.0.0 (Ladybug)   4.14.11-coreos   cri-containerd://1.0.0-beta.0
```


