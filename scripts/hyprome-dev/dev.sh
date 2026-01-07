#!/bin/bash
set -e

# Direct binary installs for tools that are large via Homebrew
# These are installed as standalone binaries to reduce image size

INSTALL_DIR="/usr/local/bin"

echo "=== Installing direct binaries ==="

# Install kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl "$INSTALL_DIR/"

# Install kubectx and kubens
echo "Installing kubectx/kubens..."
KUBECTX_VERSION=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -LO "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz"
curl -LO "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz"
tar xzf "kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" kubectx
tar xzf "kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz" kubens
chmod +x kubectx kubens
mv kubectx kubens "$INSTALL_DIR/"
rm -f kubectx_*.tar.gz kubens_*.tar.gz

# Install HashiCorp Vault
echo "Installing Vault..."
VAULT_VERSION=$(curl -s https://api.github.com/repos/hashicorp/vault/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
curl -LO "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
unzip -o "vault_${VAULT_VERSION}_linux_amd64.zip"
chmod +x vault
mv vault "$INSTALL_DIR/"
rm -f "vault_${VAULT_VERSION}_linux_amd64.zip"

# Install HashiCorp Nomad
echo "Installing Nomad..."
NOMAD_VERSION=$(curl -s https://api.github.com/repos/hashicorp/nomad/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
curl -LO "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip"
unzip -o "nomad_${NOMAD_VERSION}_linux_amd64.zip"
chmod +x nomad
mv nomad "$INSTALL_DIR/"
rm -f "nomad_${NOMAD_VERSION}_linux_amd64.zip"

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install --update
rm -rf aws awscliv2.zip

# Install s5cmd
echo "Installing s5cmd..."
S5CMD_VERSION=$(curl -s https://api.github.com/repos/peak/s5cmd/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
curl -LO "https://github.com/peak/s5cmd/releases/download/v${S5CMD_VERSION}/s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz"
tar xzf "s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz" s5cmd
chmod +x s5cmd
mv s5cmd "$INSTALL_DIR/"
rm -f "s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz"

echo "=== Direct binary installs complete ==="
