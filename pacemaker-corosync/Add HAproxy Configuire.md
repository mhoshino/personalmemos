# Add HAproxy Configuire

## 1. Install HAproxy

```
root@ha-ubuntu-01:~# sudo apt-get install haproxy
```

## 2. Configure HAproxy

```
root@ha-ubuntu-01:~# cat /etc/haproxy/haproxy.cfg
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend http
    bind    192.168.0.200:8080
    default_backend app_pool

backend app_pool
    server ha-ubuntu-01 192.168.0.101:80 check
    server ha-ubuntu-02 192.168.0.102:80 check
    server ha-ubuntu-03 192.168.0.103:80 check
```
The above file is just adding the following lines to the default configuration

```
frontend http
    bind    192.168.0.200:8080
    default_backend app_pool

backend app_pool
    server ha-ubuntu-01 192.168.0.101:80 check
    server ha-ubuntu-02 192.168.0.102:80 check
    server ha-ubuntu-03 192.168.0.103:80 check
```

## 3. Add HAproxy resource

```
root@ha-ubuntu-01:~# crm cib new conf-haproxy
INFO: cib.new: conf-haproxy shadow CIB created
root@ha-ubuntu-01:~# crm configure primitive haproxy lsb:haproxy op monitor interval="1s"
root@ha-ubuntu-01:~# crm configure clone haproxy-clone haproxy
root@ha-ubuntu-01:~# crm configure colocation vip-with-haproxy inf: virtual-ip haproxy-clone
WARNING: vip-with-haproxy: resource virtual-ip is grouped, constraints should apply to the group
root@ha-ubuntu-01:~# crm configure order haproxy-after-vip mandatory: virtual-ip haproxy-clone
```

## 4. Update Kernel Parameter
```
root@ha-ubuntu-03:~# vi /etc/sysctl.conf
root@ha-ubuntu-03:~# sysctl -p
net.ipv4.ip_nonlocal_bind = 1
```

## 5. Enable Service
```
root@ha-ubuntu-03:~# systemctl start nginx
root@ha-ubuntu-03:~# systemctl enable nginx
Synchronizing state of nginx.service with SysV init with /lib/systemd/systemd-sysv-install...
Executing /lib/systemd/systemd-sysv-install enable nginx
root@ha-ubuntu-03:~# systemctl stop haproxy
root@ha-ubuntu-03:~# systemctl disable haproxy
Synchronizing state of haproxy.service with SysV init with /lib/systemd/systemd-sysv-install...
Executing /lib/systemd/systemd-sysv-install disable haproxy
insserv: warning: current start runlevel(s) (empty) of script `haproxy' overrides LSB defaults (2 3 4 5).
insserv: warning: current stop runlevel(s) (0 1 2 3 4 5 6) of script `haproxy' overrides LSB defaults (0 1 6).
```



