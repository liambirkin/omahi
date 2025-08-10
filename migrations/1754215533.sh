echo "Enable auto-discovery of network printers"

if [[ ! -f /etc/systemd/resolved.conf.d/10-disable-multicast.conf ]]; then
  sudo dnf -y install avahi nss-mdns
  sudo mkdir -p /etc/systemd/resolved.conf.d
  echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf
  sudo systemctl enable --now avahi-daemon.service
fi

if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
  sudo dnf -y install cups-browsed
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
  sudo systemctl enable --now cups-browsed.service
fi
