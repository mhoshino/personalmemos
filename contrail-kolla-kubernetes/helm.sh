#!/bin/sh
set -x
if [ `hostname` = "stacknamecontrol_hostname" ]
then
	curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
	ssh localhost helm init
	echo "
[Unit]
Description=Helm Server
After=network.target

[Service]
User=root
Restart=always
ExecStart=/usr/local/bin/helm serve

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/helm-serve.service
        systemctl start helm-serve
	systemctl enable helm-serve
        ssh localhost helm repo add localhost http://localhost:8879/charts
fi
