#!/bin/bash
set -e

# Make all tmp files readable
chmod 644 /tmp/*.packages /tmp/*.brew 2>/dev/null || true

# Run shim setup
/tmp/dev-shims.sh

# Add COPRs
dnf -y copr enable cdayjr/yadm

# Update and install packages using dnf
dnf -y update
dnf -y install $(grep -v '^#' /tmp/hyprome-dev-base.packages | xargs)

# Clean up DNF cache immediately
dnf clean all
rm -rf /var/cache/dnf

# Install Homebrew
useradd -m -u 1000 linuxbrew
echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# Switch to linuxbrew user for brew installation
su - linuxbrew -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

# Add brew to path for subsequent commands
export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# Install brew packages
su - linuxbrew -c 'export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH && \
    brew update --force && \
    xargs brew install </tmp/hyprome-dev-base.brew && \
    brew cleanup --prune=all && \
    rm -rf "$(brew --cache)"'

# Make linuxbrew home world writable
chmod -R o+w /home/linuxbrew/

# Install Rust via rustup (system-wide installation)
echo "Installing Rust toolchain..."
export RUSTUP_HOME=/opt/rust/rustup
export CARGO_HOME=/opt/rust/cargo
mkdir -p /opt/rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
chmod -R o+rwX /opt/rust

# Create profile script to set Rust environment
cat > /etc/profile.d/rust.sh << 'EOF'
export RUSTUP_HOME=/opt/rust/rustup
export CARGO_HOME=/opt/rust/cargo
export PATH="/opt/rust/cargo/bin:$PATH"
EOF
chmod 644 /etc/profile.d/rust.sh

# Create profile script to set Homebrew environment
cat > /etc/profile.d/homebrew.sh << 'EOF'
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
EOF
chmod 644 /etc/profile.d/homebrew.sh
