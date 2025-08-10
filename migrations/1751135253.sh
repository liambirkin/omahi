echo "Add missing installation of bat (used by the ff alias)"
if ! command -v bat &>/dev/null; then
  sudo dnf -y install bat
fi
