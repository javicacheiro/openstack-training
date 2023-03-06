#!/bin/bash

# Be careful to escape the dollars
cat <<EOF > /etc/yum.repos.d/docker.repo
[docker]
baseurl = https://download.docker.com/linux/centos/\$releasever/\$basearch/stable
gpgcheck = 1
gpgkey = https://download.docker.com/linux/centos/gpg
name = Docker main Repository
module_hotfixes = True
EOF

dnf install -y --enablerepo docker docker-ce docker-compose-plugin
systemctl start docker
systemctl enable docker
