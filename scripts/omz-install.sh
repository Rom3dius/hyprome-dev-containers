#!/usr/bin/env bash
set -euo pipefail

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
UNIT_NAME=ohmyzsh-install.service
UNIT_DIR="$HOME/.config/systemd/user"
UNIT_PATH="$UNIT_DIR/$UNIT_NAME"
USER="$USER"

install_omz() {
  echo "[OMZ] Installing for $USER ($HOME)…"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

update_omz() {
  echo "[OMZ] Updating for $USER ($HOME)…"
  "$ZSH/tools/upgrade.sh" || true
}

create_unit() {
  mkdir -p "$UNIT_DIR"
  # Write the unit only if it doesn't exist yet
  if [[ ! -f "$UNIT_PATH" ]]; then
    cat >"$UNIT_PATH" <<'EOF'
[Unit]
Description=Install or Update Oh‑My‑Zsh

[Service]
Type=oneshot
ExecStart=/usr/local/bin/omz-install.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now "$UNIT_NAME"
  fi
}

# ─── Run the installer / updater ───
if [[ -d "$ZSH" ]]; then
  update_omz
else
  install_omz
fi

# ─── Ensure the systemd‑user unit exists & is enabled ───
#     This makes future logins auto‑update OMZ.
create_unit
