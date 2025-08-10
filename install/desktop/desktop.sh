#!/bin/bash

sudo dnf -y install \
  brightnessctl playerctl pamixer wireplumber \
  fcitx5 fcitx5-gtk fcitx5-qt wl-clip-persist \
  nautilus sushi ffmpegthumbnailer gvfs-mtp \
  slurp satty \
  mpv evince imv \
  chromium \
  qpwgraph  # Fedora alternative to wiremix

# Create a fake 'wiremix' command that just launches qpwgraph
if ! command -v wiremix &>/dev/null; then
  sudo tee /usr/local/bin/wiremix >/dev/null <<'EOF'
#!/bin/bash
exec qpwgraph "$@"
EOF
  sudo chmod +x /usr/local/bin/wiremix
fi

# Add screen recorder based on GPU
if lspci | grep -qi 'nvidia'; then
  sudo dnf -y install wf-recorder
else
  sudo dnf -y install wl-screenrec
fi
