#!/bin/sh
set -x
export HELM_VERSION=v2.5.1
export TMP_DIR=$(mktemp -d)
if [ `hostname` = "stacknamecontrol_hostname" ]
then
	curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR}
	sudo mv ${TMP_DIR}/helm /usr/local/bin/helm
	rm -rf ${TMP_DIR}
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
