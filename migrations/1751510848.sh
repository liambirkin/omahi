echo "Installing missing fd terminal tool for finding files"
if ! command -v fd &>/dev/null; then
  sudo dnf -y install fd-find
fi
