echo "Add Terminal Text Effects for rizzing Omarchy"
if ! python3 -c 'import terminaltexteffects' 2>/dev/null; then
  sudo dnf -y install python3-pipx || true
  pipx ensurepath >/dev/null 2>&1 || true
  pipx install terminaltexteffects || python3 -m pip install --user terminaltexteffects
fi
