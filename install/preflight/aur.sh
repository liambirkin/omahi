#!/bin/bash
# Fedora replacement for Omarchy's aur.sh

set -e

echo "[Omarchy Fedora Port] Setting up extra repos and dev tools..."

# Enable RPM Fusion (Free & Non-Free) — needed for drivers, codecs, etc.
if ! dnf repolist | grep -q "rpmfusion"; then
  sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

# Optional: Enable some common COPR repos (uncomment if you need them)
# Example: latest Neovim
# sudo dnf copr enable -y agriffis/neovim-nightly

# Install Development Tools group (like base-devel in Arch)
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y git curl wget make cmake gcc gcc-c++ kernel-devel

# For NVIDIA (if needed later)
# sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

echo "[Omarchy Fedora Port] Repo setup complete."
