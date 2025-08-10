#!/bin/bash

# Use dark mode for QT apps too (like kdenlive)
if ! rpm -q kvantum-qt5 >/dev/null 2>&1; then
  sudo dnf -y install kvantum-qt5
fi

# Prefer dark mode everything
if ! rpm -q gnome-themes-extra >/dev/null 2>&1; then
  sudo dnf -y install gnome-themes-extra   # Adds Adwaita-dark theme
fi

# Allow icons to match the theme
if ! rpm -q yaru-icon-theme >/dev/null 2>&1; then
  sudo dnf -y install yaru-icon-theme
fi

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

# Setup theme links
mkdir -p ~/.config/omarchy/themes
for f in ~/.local/share/omarchy/themes/*; do ln -nfs "$f" ~/.config/omarchy/themes/; done

# Set initial theme
mkdir -p ~/.config/omarchy/current
ln -snf ~/.config/omarchy/themes/tokyo-night ~/.config/omarchy/current/theme
ln -snf ~/.config/omarchy/current/theme/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ~/.config/omarchy/current/background

# Set specific app links for current theme
ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua

mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config
