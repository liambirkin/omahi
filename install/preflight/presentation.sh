#!/bin/bash
set -euo pipefail

# pick dnf5 if present, else dnf
PKG=${PKG:-$(command -v dnf5 || command -v dnf)}

# Install gum from Fedora repos
sudo "$PKG" install -y gum

# Install TerminalTextEffects as an app via pipx (gives you the `tte` command)
sudo "$PKG" install -y python3-pipx
# Ensure pipx's bin is on PATH for future shells; current shell may need re-login
pipx ensurepath >/dev/null 2>&1 || true

# Install only if not already present
if ! command -v tte >/dev/null 2>&1; then
  pipx install terminaltexteffects
fi
