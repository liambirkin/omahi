#!/bin/bash
set -euo pipefail

# --- Core packages from Fedora ---
sudo dnf -y install \
  hyprland hyprshot hyprpicker hyprlock hypridle hyprsunset polkit-gnome \
  libqalculate waybar mako swaybg swayosd \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# --- Build real 'walker' + 'hyprland-qtutils' if missing ---
need_walker=! command -v walker >/dev/null 2>&1
need_qtutils=! command -v hyprland-qtutils >/dev/null 2>&1

if $need_walker || $need_qtutils; then
  # Build deps (Fedora)
  if [[ "$PKG" =~ dnf5$ ]]; then
    sudo "$PKG" group install -y "Development Tools"
  else
    sudo "$PKG" groupinstall -y "Development Tools"
  fi
  sudo dnf -y install \
    git cmake ninja-build gcc-c++ pkgconfig \
    go \
    gtk4-devel gtk4-layer-shell-devel gobject-introspection-devel graphene-devel vips-devel \
    qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qttools-devel qt6-qtquickcontrols2-devel
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --- walker (Go + GTK4) ---
if $need_walker; then
  echo "[walker] building…"
  git clone --depth=1 https://github.com/abenz1267/walker "$tmpdir/walker"
  pushd "$tmpdir/walker/cmd" >/dev/null
  go build -o walker
  sudo install -Dm755 walker /usr/local/bin/walker
  popd >/dev/null
fi

# --- hyprland-qt-support (required by qtutils) ---
if $need_qtutils; then
  echo "[hyprland-qt-support] building…"
  git clone --depth=1 https://github.com/hyprwm/hyprland-qt-support "$tmpdir/hyprland-qt-support"
  pushd "$tmpdir/hyprland-qt-support" >/dev/null
  cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DINSTALL_QML_PREFIX=/usr/lib64/qt6/qml
  cmake --build build -j"$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)"
  sudo cmake --install build
  popd >/dev/null

  # --- hyprland-qtutils ---
  echo "[hyprland-qtutils] building…"
  git clone --depth=1 https://github.com/hyprwm/hyprland-qtutils "$tmpdir/hyprland-qtutils"
  pushd "$tmpdir/hyprland-qtutils" >/dev/null
  cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)"
  sudo cmake --install build
  popd >/dev/null
fi

echo "✅ Hyprland stack installed. Real 'walker' and 'hyprland-qtutils' built where missing."
