echo "Adding gnome-keyring to make 1password work with 2FA codes"
if ! command -v gnome-keyring-daemon &>/dev/null; then
  sudo dnf -y install gnome-keyring
fi
