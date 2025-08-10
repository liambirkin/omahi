echo "Install wf-recorder for screen recording for nvidia"
if lspci | grep -qi 'nvidia'; then
  if ! command -v wf-recorder &>/dev/null; then
    sudo dnf -y install wf-recorder
  fi
  if command -v wl-screenrec &>/dev/null; then
    sudo dnf -y remove wl-screenrec || true
  fi
fi
