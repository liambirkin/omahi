#!/bin/bash

if [ -z "$OMARCHY_BARE" ]; then
  # RPM packages available in Fedora repos
  sudo dnf -y install \
    gnome-calculator gnome-keyring signal-desktop \
    libreoffice obs-studio kdenlive \
    xournalpp

  # Obsidian is not in Fedora repos — use flatpak
  flatpak install -y flathub md.obsidian.Obsidian

  # localsend isn’t packaged — use flatpak
  flatpak install -y flathub org.localsend.localsend_app

  # Packages known to be flaky on AUR → install from flatpak where possible
  flatpak install -y flathub com.github.pinta_project.Pinta \
                       io.typora.Typora \
                       com.spotify.Client \
                       us.zoom.Zoom

  # 1Password (Fedora official repo from developer)
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
  sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'
  sudo dnf -y install 1password 1password-cli || \
    echo -e "\e[31mFailed to install 1Password. Continuing without!\e[0m"
fi

# Copy over Omarchy applications
source ~/.local/share/omarchy/bin/omarchy-refresh-applications || true
