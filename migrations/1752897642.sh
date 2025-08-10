echo "Remove needless fcitx5-configtool package"
if rpm -q fcitx5-configtool &>/dev/null; then
  sudo dnf -y remove fcitx5-configtool
fi
