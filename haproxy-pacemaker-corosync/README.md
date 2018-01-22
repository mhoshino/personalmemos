# Steps for building a simple pacemaker + corosync Cluster

### 1. Active 3 boxes of Ubuntu

```
Mirantis:haproxy-pacemaker-corosync machi$ vagrant up
```

### 2. SSH into 1st Ubuntu

```
Mirantis:haproxy-pacemaker-corosync machi$ vagrant ssh ha-ubuntu-01
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-109-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


vagrant@ha-ubuntu-01:~$
```

### 3. Sudo to root

```
vagrant@ha-ubuntu-01:~$ sudo -s

```
### 4. Install nginx

```
root@ha-ubuntu-01:~# apt-get -y update
```

```
root@ha-ubuntu-01:~# apt-get install -y nginx
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0 libjpeg-turbo8 libjpeg8 libtiff5 libvpx3 libxpm4 libxslt1.1 nginx-common nginx-core
Suggested packages:
  libgd-tools fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0 libjpeg-turbo8 libjpeg8 libtiff5 libvpx3 libxpm4 libxslt1.1 nginx nginx-common nginx-core
0 upgraded, 14 newly installed, 0 to remove and 19 not upgraded.
Need to get 3,000 kB of archives.
```
Add the following to determine which host when http access is on

```
root@ha-ubuntu-01:~# hostname > /var/www/html/index.nginx-debian.html
```


### 5. Install pacemaker and corosync
```
root@ha-ubuntu-01:~# apt-get install pacemaker
```

### 6. Configure Corosync

```
root@ha-ubuntu-01:~# cat /etc/corosync/corosync.conf
totem {
  version: 2
  cluster_name: ha-ubuntu
  secauth: off
  transport:udpu
  interface {
    ringnumber: 0
    bindnetaddr: 192.168.0.0
    broadcast: yes
    mcastport: 5405
  }
}

nodelist {
  node {
    ring0_addr: 192.168.0.101
    name: ha-ubuntu-01
    nodeid: 1
  }
  node {
    ring0_addr: 192.168.0.102
    name: ha-ubuntu-02
    nodeid: 2
  }
  node {
    ring0_addr: 192.168.0.103
    name: ha-ubuntu-03
    nodeid: 3
  }
}

quorum {
  provider: corosync_votequorum
}
```
### 7. Repeat the steps on 2. to 7. on all nodes


### 8. Create and Share corosync key

On ha-ubuntu-01 Enter the following

```
root@ha-ubuntu-01:~# apt-get install haveged
root@ha-ubuntu-01:~# corosync-keygen
```

On the other nodes create sshuser and ssh key file
```
root@ha-ubuntu-02:~# useradd -m sshuser
root@ha-ubuntu-02:~# su - sshuser
sshuser@ha-ubuntu-02:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/sshuser/.ssh/id_rsa):
Created directory '/home/sshuser/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/sshuser/.ssh/id_rsa.
Your public key has been saved in /home/sshuser/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:rAesxFl20K1o8GnHBKeOCKtPjNI5Fqnly5x1vgBgkiU sshuser@ha-ubuntu-02
The key's randomart image is:
+---[RSA 2048]----+
|E .   oo..       |
| +  .  +o .      |
|=.   o+=..       |
|o+ + B*o+        |
|. * =o+.S        |
|.B = . o         |
|= O + o .        |
|.* = + .         |
|  *   o.         |
+----[SHA256]-----+
sshuser@ha-ubuntu-02:~$ cat /home/sshuser/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDg+lE1OPTwMJTUfH3d0SCiZlhiYpyUUa5R48SxpTYx3JD3SLIlEAa6uhGRmJuHPjAbAPtzITimrX96g/eRaebneEg4yT6xbuDqzsqIRu3CJ7OqIKhwbcQAQohA+0NkHLQeGPk0KG9uLd8z1czjqlyz3D7wKiLUmCTgmecoMpiFYX0hnfCzrWFnNSJMzyN9VDSCpPARQ3GmLZ6oR4eFg0S4UVKHU3sgbsljo5Ws+zBFw8SjJn9RjKSsiVxOMqbAVwk85P4YPP9djj1RqTvQNOMfJmFnpv4ACB7TnnkD3iHU2VnKYrd/IGafKhiYFyVDUedjsV8au+/WjTT2g8IYvBlp sshuser@ha-ubuntu-02
sshuser@ha-ubuntu-02:~$ cat /home/sshuser/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA4PpRNTj08DCU1Hx93dEgomZYYmKclFGuUePEsaU2MdyQ90iy
JRAGuroRkZibhz4wGwD7cyE4pq1/eoP3kWnm53hIOMk+sW7g6s7KiEbtwiezqiCo
cG3EAEKIQPtDZBy0Hhj5NChvbi3fM9XM46pcs9w+8Coi1Jgk4JnnKDKYhWF9IZ3w
s61hZzUiTM8jfVQ0gqTwEUNxpi2eqEeHhYNEuFFSh1N7IG7JY6OVrPswRcPEoyZ/
UYykrIlcTjKmwFcJPOT+GDz/XY49Uak70DTjHyZhZ6b+AAge0555A94h1NlZymK3
fyBmnyoYmBclQ1HnY7FfGrvv1o009oPCGLwZaQIDAQABAoIBAQCHyEwu9RtPw+Jv
hFtq/wbVPTPm3WFnWwz8u51BIlddLKQJu0RZfhyxog9sclCcBXp/Mc6RI+HPJzOj
O/a1OtdzqHLeYweFi0gQL5KpQTXKUq/q5B8FDBqZlY4quftodrJ239e4FRd7xg/K
dyVb2rxsiWcrCCNRcCoBrKGI71CCXrw4jsiQLlpNH4jNLQaaMaMremVtCBc/cYdF
AURSWuY+DvcF9DKnTo5rMyqvHZkIopRQGu9IvU0RDSNa33O9bsxwu/azs+dOEboM
iw3rkaKR1ZKJH360D08wRUxrVIkJAfhJn9OhnpfAE0k+57TPdj7YrhQV376D8VZr
bZFwhJipAoGBAP6H6T0uLbmp/4/z4BdF2lQiT/ZefLQL6XzesYMWM6tyDwAtey8v
BijLtKjyUlg0mDHDxuPC9DiIRAzwMUMRQWv1KIPfK1uS0SGK7DacF9JwOZ/PzMuJ
PUMB2MIL76Lk7z8zgYy8j6+8lhQx3rq44Nx9m9bNKtXqJVeMakBpzbZnAoGBAOJG
vTlsoG1ZwlDbgRzrgRcwNS2ie4hDFMBJjNgaWXIMA8SG5W5kHQ9itXqBrUHOy1BF
AReUKF1YEpdtn78QrmJZA6l1fTavMw50cbG8CCjAD+xvNPoRh2J+tJW8f37wq/Mj
P0OhMX//La8Hu8o+XGT1nH98+6S9j6dGvF3TtK+vAoGBAIPPuH7BclaK7dkLj4od
15HobwaEKgpHfPP4k27ySXHI0HHkG730mTj5PSaczv30xrhGzbHXnQfFsZANt0Un
I30X6ZJZOSfkIT9ApVEmhsOo8H6Na14gRUR1KV5cNg5ihm9xae6LG9IDVKlCpjiG
U5R7y/9yInPDHPF4uvF+mVSTAoGAGLl0CadF7Eznf6BMflV5WIhK9z6O0vfJd61R
t3dBmMWZT8sRnLtRtZGqlMVAojUvYAj6MpJcyr5J4cP3tY/kDhj93nFZCjWglY7B
sZMDLTi3RLVuC3kI2wlPQCFFqSAxGbMbQY+Gch725e4pZdLkk5+GxyNn97tCzBtd
j78HOj8CgYEAjSOku1ri/zwRZ6jZSZcU1duweVZrIfDnO6kVsNXHlvgYkVC7qYWB
hCE8Kf27JOpGCj3dWra/TLgo+Jmm0CBfCiwtWHZVkslq6pjPkcuAf7LWOO9luM9B
jf5ZYIfrZXW8Si+A5BdXXJKcQR5qWVVq4PYHoVa+se4hEAVWZ+X+QGs=
-----END RSA PRIVATE KEY-----
sshuser@ha-ubuntu-02:~$
sshuser@ha-ubuntu-02:~$ cp -p ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
```

SCP the key from ha-ubuntu-01

```
root@ha-ubuntu-01:~# cat <<EOF > sshkeytmp
> -----BEGIN RSA PRIVATE KEY-----
> MIIEpQIBAAKCAQEA4PpRNTj08DCU1Hx93dEgomZYYmKclFGuUePEsaU2MdyQ90iy
> JRAGuroRkZibhz4wGwD7cyE4pq1/eoP3kWnm53hIOMk+sW7g6s7KiEbtwiezqiCo
> cG3EAEKIQPtDZBy0Hhj5NChvbi3fM9XM46pcs9w+8Coi1Jgk4JnnKDKYhWF9IZ3w
> s61hZzUiTM8jfVQ0gqTwEUNxpi2eqEeHhYNEuFFSh1N7IG7JY6OVrPswRcPEoyZ/
> UYykrIlcTjKmwFcJPOT+GDz/XY49Uak70DTjHyZhZ6b+AAge0555A94h1NlZymK3
> fyBmnyoYmBclQ1HnY7FfGrvv1o009oPCGLwZaQIDAQABAoIBAQCHyEwu9RtPw+Jv
> hFtq/wbVPTPm3WFnWwz8u51BIlddLKQJu0RZfhyxog9sclCcBXp/Mc6RI+HPJzOj
> O/a1OtdzqHLeYweFi0gQL5KpQTXKUq/q5B8FDBqZlY4quftodrJ239e4FRd7xg/K
> dyVb2rxsiWcrCCNRcCoBrKGI71CCXrw4jsiQLlpNH4jNLQaaMaMremVtCBc/cYdF
> AURSWuY+DvcF9DKnTo5rMyqvHZkIopRQGu9IvU0RDSNa33O9bsxwu/azs+dOEboM
> iw3rkaKR1ZKJH360D08wRUxrVIkJAfhJn9OhnpfAE0k+57TPdj7YrhQV376D8VZr
> bZFwhJipAoGBAP6H6T0uLbmp/4/z4BdF2lQiT/ZefLQL6XzesYMWM6tyDwAtey8v
> BijLtKjyUlg0mDHDxuPC9DiIRAzwMUMRQWv1KIPfK1uS0SGK7DacF9JwOZ/PzMuJ
> PUMB2MIL76Lk7z8zgYy8j6+8lhQx3rq44Nx9m9bNKtXqJVeMakBpzbZnAoGBAOJG
> vTlsoG1ZwlDbgRzrgRcwNS2ie4hDFMBJjNgaWXIMA8SG5W5kHQ9itXqBrUHOy1BF
> AReUKF1YEpdtn78QrmJZA6l1fTavMw50cbG8CCjAD+xvNPoRh2J+tJW8f37wq/Mj
> P0OhMX//La8Hu8o+XGT1nH98+6S9j6dGvF3TtK+vAoGBAIPPuH7BclaK7dkLj4od
> 15HobwaEKgpHfPP4k27ySXHI0HHkG730mTj5PSaczv30xrhGzbHXnQfFsZANt0Un
> I30X6ZJZOSfkIT9ApVEmhsOo8H6Na14gRUR1KV5cNg5ihm9xae6LG9IDVKlCpjiG
> U5R7y/9yInPDHPF4uvF+mVSTAoGAGLl0CadF7Eznf6BMflV5WIhK9z6O0vfJd61R
> t3dBmMWZT8sRnLtRtZGqlMVAojUvYAj6MpJcyr5J4cP3tY/kDhj93nFZCjWglY7B
> sZMDLTi3RLVuC3kI2wlPQCFFqSAxGbMbQY+Gch725e4pZdLkk5+GxyNn97tCzBtd
> j78HOj8CgYEAjSOku1ri/zwRZ6jZSZcU1duweVZrIfDnO6kVsNXHlvgYkVC7qYWB
> hCE8Kf27JOpGCj3dWra/TLgo+Jmm0CBfCiwtWHZVkslq6pjPkcuAf7LWOO9luM9B
> jf5ZYIfrZXW8Si+A5BdXXJKcQR5qWVVq4PYHoVa+se4hEAVWZ+X+QGs=
> -----END RSA PRIVATE KEY-----
> EOF
root@ha-ubuntu-01:~# chmod 600 sshkeytmp
root@ha-ubuntu-01:~# scp -i sshkeytmp /etc/corosync/authkey sshuser@192.168.0.102:/tmp
authkey                                                                                                                                                                   100%  128     0.1KB/s   00:00
root@ha-ubuntu-01:~#
```

On ha-ubuntu-02 and ha-ubuntu-03 move the corosync key

```
root@ha-ubuntu-02:~# mv /tmp/authkey /etc/corosync/
root@ha-ubuntu-02:~# chown root: /etc/corosync/authkey
root@ha-ubuntu-02:~# chmod 400 /etc/corosync/authkey
```


### 9. Restart corosync


```
root@ha-ubuntu-01:~# systemctl restart corosync
root@ha-ubuntu-01:~# systemctl status corosync
● corosync.service - Corosync Cluster Engine
   Loaded: loaded (/lib/systemd/system/corosync.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2018-01-22 20:46:32 UTC; 2s ago
 Main PID: 7025 (corosync)
    Tasks: 2
   Memory: 54.7M
      CPU: 225ms
   CGroup: /system.slice/corosync.service
           └─7025 /usr/sbin/corosync -f

Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [QB    ] server name: cpg
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [QB    ] server name: votequorum
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [QB    ] server name: quorum
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [TOTEM ] adding new UDPU member {192.168.0.101}
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [TOTEM ] adding new UDPU member {192.168.0.102}
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [TOTEM ] adding new UDPU member {192.168.0.103}
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [TOTEM ] A new membership (192.168.0.101:64) was formed. Members joined: 1
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]: notice  [TOTEM ] A new membership (192.168.0.101:68) was formed. Members joined: 2 3
Jan 22 20:46:32 ha-ubuntu-01 corosync[7025]:  [TOTEM ] A new membership (192.168.0.101:68) was formed. Members joined: 2 3
Jan 22 20:46:32 ha-ubuntu-01 systemd[1]: Started Corosync Cluster Engine.
root@ha-ubuntu-01:~#
root@ha-ubuntu-01:~#
```
Check corosync cluster status
```
root@ha-ubuntu-01:~# crm status
Last updated: Mon Jan 22 20:46:39 2018		Last change: Mon Jan 22 20:35:29 2018 by hacluster via crmd on ha-ubuntu-01
Stack: corosync
Current DC: ha-ubuntu-02 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 0 resources configured

Online: [ ha-ubuntu-01 ha-ubuntu-02 ha-ubuntu-03 ]

Full list of resources:
```

### 10. start pacemaker
```
root@ha-ubuntu-01:~# sudo systemctl start pacemaker
```

### 11. create resources

Create a virtual ip resource

```
root@ha-ubuntu-01:~# SHARED_VIP="192.168.0.200"
root@ha-ubuntu-01:~# crm configure <<EOF
>   primitive virtual-ip ocf:heartbeat:IPaddr \
>     params ip="$SHARED_VIP"
>
>   property stonith-enabled=false
>   commit
> EOF
```

### 12. Create a nginx lsb resource

```
root@ha-ubuntu-02:/etc/systemd/system# crm configure primitive failover-nginx lsb::nginx op monitor interval=15s
root@ha-ubuntu-02:/etc/systemd/system# crm status
Last updated: Mon Jan 22 21:00:49 2018		Last change: Mon Jan 22 21:00:40 2018 by root via cibadmin on ha-ubuntu-02
Stack: corosync
Current DC: ha-ubuntu-02 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 2 resources configured

Online: [ ha-ubuntu-01 ha-ubuntu-02 ha-ubuntu-03 ]

Full list of resources:

 virtual-ip	(ocf::heartbeat:IPaddr):	Started ha-ubuntu-02
 failover-nginx	(lsb:nginx):	Started ha-ubuntu-01

root@ha-ubuntu-02:/etc/systemd/system#
```
Group the resources

```
root@ha-ubuntu-02:/etc/systemd/system# crm configure group nginx-group virtual-ip failover-nginx
root@ha-ubuntu-02:/etc/systemd/system#
```
Configure resource order

```
root@ha-ubuntu-02:/etc/systemd/system# crm configure order nginx-order virtual-ip failover-nginx
root@ha-ubuntu-02:/etc/systemd/system# crm status
Last updated: Mon Jan 22 21:08:32 2018		Last change: Mon Jan 22 21:08:31 2018 by root via cibadmin on ha-ubuntu-02
Stack: corosync
Current DC: ha-ubuntu-02 (version 1.1.14-70404b0) - partition with quorum
3 nodes and 2 resources configured

Online: [ ha-ubuntu-01 ha-ubuntu-02 ha-ubuntu-03 ]

Full list of resources:

 Resource Group: nginx-group
     virtual-ip	(ocf::heartbeat:IPaddr):	Started ha-ubuntu-02
     failover-nginx	(lsb:nginx):	Started ha-ubuntu-02

root@ha-ubuntu-02:/etc/systemd/system# crm configure show
node 1: ha-ubuntu-01
node 2: ha-ubuntu-02
node 3: ha-ubuntu-03
primitive failover-nginx lsb:nginx \
	op monitor interval=15s \
	meta target-role=Started
primitive virtual-ip IPaddr \
	params ip=192.168.0.200
group nginx-group virtual-ip failover-nginx
order nginx-order virtual-ip failover-nginx
property cib-bootstrap-options: \
	have-watchdog=false \
	dc-version=1.1.14-70404b0 \
	cluster-infrastructure=corosync \
	cluster-name=debian \
	stonith-enabled=false
root@ha-ubuntu-02:/etc/systemd/system#
```
