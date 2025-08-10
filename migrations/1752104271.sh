echo "Switching to polkit-gnome for better fingerprint authentication compatibility"
# Fedora's agent path is usually /usr/libexec/polkit-gnome-authentication-agent-1
if ! command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &>/dev/null \
   && ! [ -x /usr/libexec/polkit-gnome-authentication-agent-1 ]; then
  sudo dnf -y install polkit-gnome
  systemctl --user stop hyprpolkitagent.service 2>/dev/null || true
  systemctl --user disable hyprpolkitagent.service 2>/dev/null || true
  sudo dnf -y remove hyprpolkitagent 2>/dev/null || true
fi

agent="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
[ -x "$agent" ] || agent="/usr/libexec/polkit-gnome-authentication-agent-1"
setsid "$agent" &
