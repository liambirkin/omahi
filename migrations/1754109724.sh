echo "Add hyprsunset blue light filter"
if ! command -v hyprsunset &>/dev/null; then
  sudo dnf -y install hyprsunset
fi

~/.local/share/omarchy/bin/omarchy-refresh-hyprsunset
