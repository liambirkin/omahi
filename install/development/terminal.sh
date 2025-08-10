#!/bin/bash
set -euo pipefail

# Base packages (Fedora names)
sudo dnf -y install \
  wget curl unzip inetutils \
  fd-find eza fzf ripgrep zoxide bat jq xmlstarlet \
  wl-clipboard fastfetch btop \
  man tldr less whois plocate bash-completion \
  alacritty

# --- Impala CLI (not in Fedora repos) ---
# Try to provide an `impala` (and/or `impala-shell`) command via pipx.
if ! command -v impala >/dev/null 2>&1 && ! command -v impala-shell >/dev/null 2>&1; then
  # Ensure pipx
  sudo dnf -y install python3-pipx || true
  pipx ensurepath >/dev/null 2>&1 || true

  # Install impala-shell from PyPI
  if ! command -v impala-shell >/dev/null 2>&1; then
    pipx install impala-shell || python3 -m pip install --user impala-shell
  fi

  # Create a wrapper named `impala` for compatibility with Arch scripts
  if command -v impala-shell >/dev/null 2>&1 && ! command -v impala >/dev/null 2>&1; then
    sudo tee /usr/local/bin/impala >/dev/null <<'EOF'
#!/bin/bash
exec impala-shell "$@"
EOF
    sudo chmod +x /usr/local/bin/impala
  fi
fi
