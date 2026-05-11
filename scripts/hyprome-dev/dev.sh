#!/bin/bash
set -euo pipefail

# Direct binary installs for tools that are large via Homebrew
# These are installed as standalone binaries to reduce image size

INSTALL_DIR="/usr/local/bin"

gh_api() {
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl -fsSL -H "Authorization: Bearer ${GITHUB_TOKEN}" "$@"
    else
        curl -fsSL "$@"
    fi
}

latest_tag() {
    local repo="$1"
    local tag
    tag=$(gh_api "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [ -z "$tag" ]; then
        echo "ERROR: failed to fetch latest tag for ${repo}" >&2
        return 1
    fi
    echo "$tag"
}

echo "=== Installing direct binaries ==="

# Install kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl "$INSTALL_DIR/"

# Install kubectx and kubens
echo "Installing kubectx/kubens..."
KUBECTX_VERSION=$(latest_tag ahmetb/kubectx)
curl -fsSLO "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz"
curl -fsSLO "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz"
tar xzf "kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" kubectx
tar xzf "kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz" kubens
chmod +x kubectx kubens
mv kubectx kubens "$INSTALL_DIR/"
rm -f kubectx_*.tar.gz kubens_*.tar.gz

# Install HashiCorp Vault
echo "Installing Vault..."
VAULT_VERSION=$(latest_tag hashicorp/vault | sed 's/^v//')
curl -fsSLO "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
unzip -o "vault_${VAULT_VERSION}_linux_amd64.zip"
chmod +x vault
mv vault "$INSTALL_DIR/"
rm -f "vault_${VAULT_VERSION}_linux_amd64.zip"

# Install HashiCorp Nomad
echo "Installing Nomad..."
NOMAD_VERSION=$(latest_tag hashicorp/nomad | sed 's/^v//')
curl -fsSLO "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip"
unzip -o "nomad_${NOMAD_VERSION}_linux_amd64.zip"
chmod +x nomad
mv nomad "$INSTALL_DIR/"
rm -f "nomad_${NOMAD_VERSION}_linux_amd64.zip"

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install --update
rm -rf aws awscliv2.zip

# Install s5cmd
echo "Installing s5cmd..."
S5CMD_VERSION=$(latest_tag peak/s5cmd | sed 's/^v//')
curl -fsSLO "https://github.com/peak/s5cmd/releases/download/v${S5CMD_VERSION}/s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz"
tar xzf "s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz" s5cmd
chmod +x s5cmd
mv s5cmd "$INSTALL_DIR/"
rm -f "s5cmd_${S5CMD_VERSION}_Linux-64bit.tar.gz"

echo "=== Direct binary installs complete ==="
