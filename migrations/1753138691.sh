echo "Install swayOSD to show volume status"
if ! command -v swayosd-server &>/dev/null; then
  sudo dnf -y install swayosd
  setsid uwsm app -- swayosd-server &>/dev/null &
fi
