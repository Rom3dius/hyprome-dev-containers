# hyprome-dev-containers

A Fedora-based development container built on [ublue-os/boxkit](https://github.com/ublue-os/boxkit), designed for use with [distrobox](https://github.com/89luca89/distrobox) or [toolbox](https://containertoolbx.org/).

## Overview

This container is used on [hyprome](https://github.com/Rom3dius/hyprome), a custom immutable OS. The goal is to run nothing on the host system - launching a shell drops you directly into this dev container with all your tools ready.

## What's Included

### Fedora Packages

Development essentials, CLI tools, and utilities:

- **Editors/Tools:** neovim, just, make, cmake, clang
- **Languages:** python3, npm, go (via brew)
- **Shell:** zsh, fzf, ripgrep, bat, lsd, btop, ncdu
- **Git:** gh, yadm, age, gnupg
- **Utilities:** curl, jq, zstd, direnv, fastfetch, plocate

### Homebrew Packages

Additional tools installed via Linuxbrew:

- **Languages/Runtimes:** go, rustup, poetry, pnpm, uv, ruff
- **Kubernetes:** kubectl, kubectx
- **HashiCorp:** vault, nomad, tfenv
- **Git/Dev:** lazygit, gitleaks, pre-commit, shellcheck
- **CLI Tools:** yazi, zoxide, fselect, mprocs, mask, presenterm
- **Cloud:** awscli, s5cmd
- **Other:** magic-wormhole, catimg, claude-code

## Prerequisites

- [Podman](https://podman.io/) or [Docker](https://www.docker.com/)
- (Optional) [distrobox](https://github.com/89luca89/distrobox) for seamless integration

## Building Locally

### Using Podman

```bash
podman build -f ContainerFiles/hyprome-dev -t hyprome-dev:latest .
```

### Using Docker

```bash
docker build -f ContainerFiles/hyprome-dev -t hyprome-dev:latest .
```

## Running the Container

### Quick Test Run

```bash
podman run --rm -it hyprome-dev:latest zsh -l
```

### Full Development Setup

This mounts your home directory and passes through important environment variables:

```bash
podman run --rm -it \
  --userns keep-id \
  --network host \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/1password/agent.sock \
  --mount type=bind,source="$HOME",target=/home/"$USER" \
  --mount type=bind,source="$XDG_RUNTIME_DIR",target="$XDG_RUNTIME_DIR" \
  hyprome-dev:latest zsh -l
```

### Using with Distrobox

Create a persistent container with distrobox:

```bash
distrobox create --image hyprome-dev:latest --name dev
distrobox enter dev
```

Or use the pre-built image from GHCR:

```bash
distrobox create --image ghcr.io/rom3dius/hyprome-dev:latest --name dev
distrobox enter dev
```

## Quadlet Integration

A systemd quadlet is provided in `quadlets/hyprome-dev.container` for automatic container management on systems using podman quadlets. Copy it to `~/.config/containers/systemd/` and reload systemd:

```bash
cp quadlets/hyprome-dev.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user start hyprome-dev
```

## Customization

### Adding Fedora Packages

Edit `packages/hyprome-dev.packages` - one package per line.

### Adding Homebrew Packages

Edit `packages/hyprome-dev.brew` - one package per line.

### Adding Host Command Shims

Edit `scripts/hyprome-dev/dev-shims.sh` to add symlinks for commands that should execute on the host via `distrobox-host-exec`.

## Verification

Images are signed with [cosign](https://docs.sigstore.dev/quickstart/quickstart-cosign/). Verify with:

```bash
cosign verify --key cosign.pub ghcr.io/rom3dius/hyprome-dev:latest
```

### Setting Up Signing for Forks

1. [Generate a new keypair](https://docs.sigstore.dev/cosign/key_management/signing_with_self-managed_keys/) with cosign
2. Add `cosign.pub` to your repo (users need it to verify)
3. Add the private key to Settings > Secrets > Actions as `SIGNING_SECRET`

See [GitHub's secrets documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets) for details.

## CI/CD

Images are automatically built and pushed to GHCR on:
- Push to `main` branch
- Pull requests (build only, no push)
- Weekly schedule (Tuesdays at midnight UTC)
- Manual workflow dispatch
