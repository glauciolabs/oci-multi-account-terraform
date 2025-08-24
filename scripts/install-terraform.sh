#!/bin/bash

# Silent and unattended Terraform installation script

set -e

# Variables
TERRAFORM_VERSION="1.13.0"
INSTALL_DIR="/usr/local/bin"

# Check if Terraform is already installed
if command -v terraform &> /dev/null; then
    echo "Terraform already installed (version: $(terraform version -json | jq -r '.terraform_version')). Skipping installation."
    terraform version
    exit 0
fi

# Install dependencies
apt-get update -qq
apt-get install -y -qq curl unzip

# Download Terraform
curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip

# Unzip and install
unzip -q terraform.zip
chmod +x terraform
mv terraform ${INSTALL_DIR}/terraform

# Cleanup
rm terraform.zip

# Show installed version
terraform version