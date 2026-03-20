#!/bin/bash
set -e

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

UBUNTU_CODENAME=$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs)
echo "Types: deb"                                        > /etc/apt/sources.list.d/docker.sources
echo "URIs: https://download.docker.com/linux/ubuntu"  >> /etc/apt/sources.list.d/docker.sources
echo "Suites: $UBUNTU_CODENAME"                        >> /etc/apt/sources.list.d/docker.sources
echo "Components: stable"                               >> /etc/apt/sources.list.d/docker.sources
echo "Signed-By: /etc/apt/keyrings/docker.asc"        >> /etc/apt/sources.list.d/docker.sources

DOCKER_VERSION=$(yq -r '.versions.docker' $CONFIG_FILE)

if [ "$DOCKER_VERSION" = "latest" ]; then
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    apt-get update && apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io docker-buildx-plugin docker-compose-plugin
fi

apt-get clean && rm -rf /var/lib/apt/lists/*
