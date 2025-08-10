#!/bin/bash

# Base fonts (Fedora equivalents where available)
sudo dnf -y install \
  fontawesome-fonts \
  cascadia-code-fonts \
  google-noto-emoji-fonts

# These have no direct Fedora RPM equivalent — use Nerd Fonts via Flatpak or manual install
# - ttf-cascadia-mono-nerd
# - ttf-ia-writer
# If you want them, you can pull from Nerd Fonts GitHub or set up wrappers for their font files.

if [ -z "$OMARCHY_BARE" ]; then
  sudo dnf -y install \
    jetbrains-mono-fonts \
    google-noto-cjk-fonts \
    google-noto-sans-fonts \
    google-noto-serif-fonts
fi
