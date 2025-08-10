echo "Replace wofi with walker as the default launcher"
if ! command -v walker &>/dev/null; then
  # install runtime dep
  sudo dnf -y install libqalculate || true
  # build walker (we set this up earlier)
  ~/.local/share/omarchy/bin/build-walker || {
    # fallback inline build
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    sudo dnf -y groupinstall "Development Tools"
    sudo dnf -y install git go gtk4-devel gtk4-layer-shell-devel gobject-introspection-devel graphene-devel vips-devel
    git clone --depth=1 https://github.com/abenz1267/walker "$tmp/walker"
    ( cd "$tmp/walker/cmd" && go build -o walker && sudo install -Dm755 walker /usr/local/bin/walker )
  }
  sudo dnf -y remove wofi || true
  rm -rf ~/.config/wofi
  mkdir -p ~/.config/walker
  cp -r ~/.local/share/omarchy/config/walker/* ~/.config/walker/
  setsid uwsm app -- walker --gapplication-service &
fi
