echo "Add LocalSend as new default application"
if ! command -v localsend &>/dev/null; then
  sudo dnf -y install localsend || true
fi
