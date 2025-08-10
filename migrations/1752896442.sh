echo "Replace volume control GUI with a TUI"
if ! command -v wiremix &>/dev/null; then
  sudo dnf -y install qpwgraph
  sudo dnf -y remove pavucontrol || true
  # keep compatibility: create `wiremix` wrapper
  if ! command -v wiremix &>/dev/null; then
    sudo tee /usr/local/bin/wiremix >/dev/null <<'EOF'
#!/bin/bash
exec qpwgraph "$@"
EOF
    sudo chmod +x /usr/local/bin/wiremix
  fi
  ~/.local/share/omarchy/bin/omarchy-refresh-applications
  ~/.local/share/omarchy/bin/omarchy-refresh-waybar
fi
