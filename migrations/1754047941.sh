echo "Add icon theme coloring"
if ! rpm -q yaru-icon-theme &>/dev/null; then
  sudo dnf -y install yaru-icon-theme
  if [[ -f ~/.config/omarchy/current/theme/icons.theme ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "$(<~/.config/omarchy/current/theme/icons.theme)"
  fi
fi
