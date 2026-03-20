#!/bin/bash
set -e

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

TERRAFORM_VERSION=$(yq -r '.versions.terraform' $CONFIG_FILE)

if [ "$TERRAFORM_VERSION" = "latest" ]; then
    apt-get update && apt-get install -y terraform
else
    apt-get update && apt-get install -y terraform=$TERRAFORM_VERSION
fi

apt-get clean && rm -rf /var/lib/apt/lists/*
