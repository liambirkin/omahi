echo "Install bash-completion"
if ! rpm -q bash-completion &>/dev/null; then
  sudo dnf -y install bash-completion
fi
