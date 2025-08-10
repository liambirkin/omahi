#!/bin/bash

if ! command -v ufw &>/dev/null; then
  sudo dnf -y install ufw

  # Install ufw-docker from upstream if missing
  if ! command -v ufw-docker &>/dev/null; then
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    git clone --depth=1 https://github.com/chaifeng/ufw-docker.git "$tmpdir/ufw-docker"
    sudo install -m 755 "$tmpdir/ufw-docker/ufw-docker" /usr/local/bin/ufw-docker
  fi

  # Allow nothing in, everything out
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Allow ports for LocalSend
  sudo ufw allow 53317/udp
  sudo ufw allow 53317/tcp

  # Allow SSH in
  sudo ufw allow 22/tcp

  # Allow Docker containers to use DNS on host
  sudo ufw allow in on docker0 to any port 53

  # Turn on the firewall
  sudo ufw enable

  # Turn on Docker protections
  sudo ufw-docker install
  sudo ufw reload
fi
