echo "Update and restart Walker to resolve stuck Omarchy menu"
# Rebuild/update walker on Fedora
~/.local/share/omarchy/bin/build-walker || true
~/.local/share/omarchy/bin/omarchy-restart-walker
