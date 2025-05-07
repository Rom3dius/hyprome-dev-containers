# hyprome-dev-containers

This repo was made with the template [boxkit](https://github.com/ublue-os/boxkit)

## What is this ?

These images are used on my [custom OS](https://github.com/Rom3dius/hyprome). The goal is to run absolutely nothing on the host operating system, launching a shell will drop you into the dev container.

## Build and test locally

```
# build “dev” containerfile → hyprome-dev-container:latest
podman build -f ContainerFiles/dev \
  --build-arg DOTFILES_REPO=https://github.com/Rom3dius/hyprome-dev-dots.git \
  -t hyprome-dev-container:latest .
podman run --rm -it \
  --userns keep-id \
  --network host \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/1password/agent.sock \
  --mount type=bind,source="$HOME",target=/home/"$USER" \
  --mount type=bind,source="$XDG_RUNTIME_DIR",target="$XDG_RUNTIME_DIR" \
  hyprome-dev-container:latest zsh -l
```

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/quickstart/quickstart-cosign/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ublue-os/boxkit

If you're forking this repo you should [read the docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets) on keeping secrets in github. You need to [generate a new keypair](https://docs.sigstore.dev/cosign/key_management/signing_with_self-managed_keys/) with cosign. The public key can be in your public repo (your users need it to check the signatures), and you can paste the private key in Settings -> Secrets -> Actions.

![Alt](https://repobeats.axiom.co/api/embed/7c5f037d792c6deb1946e5bc040f64a0fc8abeab.svg "Repobeats analytics image")
