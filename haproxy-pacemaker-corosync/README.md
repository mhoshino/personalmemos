Step 1. Active 2 boxes of Ubuntu

```
Mirantis:haproxy-pacemaker-corosync machi$ vagrant up
```

Step 2. SSH into 1st Ubuntu

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

```
vagrant@ha-ubuntu-01:~$ sudo -s

```


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

```
root@ha-ubuntu-01:~# vim /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>This is primary node</p>
</body>
</html>
```


```
root@ha-ubuntu-01:~# apt-get install pacemaker
```

```
root@ha-ubuntu-01:~# apt-get install haveged
```

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
```

```
root@ha-ubuntu-01:~# scp -i sshkeytmp /etc/corosync/authkey sshuser@192.168.0.102:/tmp
authkey                                                                                                                                                                   100%  128     0.1KB/s   00:00
root@ha-ubuntu-01:~#
```


```
root@ha-ubuntu-02:~# apt-get install pacemaker
```


