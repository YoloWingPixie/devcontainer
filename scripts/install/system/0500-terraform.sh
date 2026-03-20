#!/bin/bash
set -e

TERRAFORM_VERSION=$(yq -r '.versions.terraform' $CONFIG_FILE)

if [ "$TERRAFORM_VERSION" = "latest" ]; then
    TERRAFORM_VERSION=$(curl -fsSL https://api.releases.hashicorp.com/v1/releases/terraform/latest | jq -r '.version')
fi

curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip
unzip /tmp/terraform.zip -d /tmp/terraform-bin/
install -o root -g root -m 0755 /tmp/terraform-bin/terraform /usr/local/bin/terraform
rm -rf /tmp/terraform.zip /tmp/terraform-bin/
