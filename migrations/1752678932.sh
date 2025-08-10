echo "Install missing docker-buildx package for out-of-the-box Kamal compatibility"
if ! docker buildx version &>/dev/null; then
  sudo dnf -y install docker-buildx
fi
