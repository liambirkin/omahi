echo "Install ffmpegthumbnailer for video thumbnails in the file manager"
if ! command -v ffmpegthumbnailer &>/dev/null; then
  sudo dnf -y install ffmpegthumbnailer
fi
