echo "Install Impala as new wifi selection TUI"
if ! command -v impala &>/dev/null && ! command -v impala-shell &>/dev/null; then
  sudo dnf -y install python3-pipx || true
  pipx ensurepath >/dev/null 2>&1 || true
  pipx install impala-shell || python3 -m pip install --user impala-shell
  # Provide `impala` wrapper for compatibility
  if command -v impala-shell >/dev/null 2>&1 && ! command -v impala >/dev/null 2>&1; then
    sudo tee /usr/local/bin/impala >/dev/null <<'EOF'
#!/bin/bash
exec impala-shell "$@"
EOF
    sudo chmod +x /usr/local/bin/impala
  fi
  echo "You need to update the Waybar config to use Impala Wi-Fi selector in top bar."
  ~/.local/share/omarchy/bin/omarchy-refresh-waybar
fi
