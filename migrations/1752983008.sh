if [[ ! -f ~/.local/state/omarchy/bare.mode ]]; then
  echo "Add missing installation of Zoom"
  if ! command -v zoom &>/dev/null && ! flatpak list | grep -q "us.zoom.Zoom"; then
    command -v flatpak >/dev/null 2>&1 || sudo dnf -y install flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub us.zoom.Zoom
  fi
fi
