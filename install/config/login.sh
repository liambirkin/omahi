#!/bin/bash

# Hyprland launched via UWSM and login directly as user, rely on disk encryption + hyprlock for security
if ! command -v uwsm &>/dev/null || ! command -v plymouth &>/dev/null; then
  sudo dnf -y install uwsm plymouth
fi

# ==============================================================================
# PLYMOUTH SETUP (Fedora/Dracut)
# ==============================================================================

# On Fedora, initramfs is built by dracut (not mkinitcpio). Ensure plymouth is included.
sudo mkdir -p /etc/dracut.conf.d
if ! grep -q plymouth /etc/dracut.conf.d/omarchy-plymouth.conf 2>/dev/null; then
  echo 'add_dracutmodules+=" plymouth "' | sudo tee /etc/dracut.conf.d/omarchy-plymouth.conf >/dev/null
  # Rebuild initramfs so Plymouth module is present
  sudo dracut -f
fi

# Add kernel parameters for Plymouth
if [ -d "/boot/loader/entries" ]; then # systemd-boot (rare on Fedora, but keep behavior)
  echo "Detected systemd-boot"

  for entry in /boot/loader/entries/*.conf; do
    if [ -f "$entry" ]; then
      if [[ "$(basename "$entry")" == *"fallback"* ]]; then
        echo "Skipped: $(basename "$entry") (fallback entry)"
        continue
      fi
      # Use rhgb (Fedora) + quiet
      if ! grep -q "rhgb" "$entry"; then
        sudo sed -i '/^options/ s/$/ rhgb quiet/' "$entry"
      else
        echo "Skipped: $(basename "$entry") (rhgb already present)"
      fi
    fi
  done
elif [ -f "/etc/default/grub" ]; then # GRUB (typical Fedora)
  echo "Detected grub"

  # Backup GRUB config before modifying
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/default/grub "/etc/default/grub.bak.${backup_timestamp}"

  # Current line
  current_cmdline=$(grep "^GRUB_CMDLINE_LINUX=" /etc/default/grub | cut -d'"' -f2)
  [ -z "$current_cmdline" ] && current_cmdline=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | cut -d'"' -f2)

  new_cmdline="$current_cmdline"
  [[ ! "$current_cmdline" =~ rhgb ]] && new_cmdline="$new_cmdline rhgb"
  [[ ! "$current_cmdline" =~ quiet ]] && new_cmdline="$new_cmdline quiet"
  new_cmdline=$(echo "$new_cmdline" | xargs)

  if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
    sudo sed -i "s/^GRUB_CMDLINE_LINUX=\".*\"/GRUB_CMDLINE_LINUX=\"$new_cmdline\"/" /etc/default/grub
  else
    sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$new_cmdline\"/" /etc/default/grub
  fi

  # Regenerate GRUB config (works for both BIOS/UEFI via the /etc/grub2.cfg symlink)
  sudo grub2-mkconfig -o "$(readlink -f /etc/grub2.cfg)"
elif [ -d "/etc/cmdline.d" ]; then # UKI with cmdline.d
  echo "Detected a UKI setup"
  grep -q rhgb /etc/cmdline.d/*.conf 2>/dev/null || echo "rhgb" | sudo tee -a /etc/cmdline.d/omarchy.conf
  grep -q quiet /etc/cmdline.d/*.conf 2>/dev/null || echo "quiet" | sudo tee -a /etc/cmdline.d/omarchy.conf
elif [ -f "/etc/kernel/cmdline" ]; then # UKI Alternate (kernel-install)
  echo "Detected a UKI setup"

  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/kernel/cmdline "/etc/kernel/cmdline.bak.${backup_timestamp}"

  current_cmdline=$(cat /etc/kernel/cmdline)
  new_cmdline="$current_cmdline"
  [[ ! "$current_cmdline" =~ rhgb ]] && new_cmdline="$new_cmdline rhgb"
  [[ ! "$current_cmdline" =~ quiet ]] && new_cmdline="$new_cmdline quiet"
  new_cmdline=$(echo "$new_cmdline" | xargs)
  echo "$new_cmdline" | sudo tee /etc/kernel/cmdline >/dev/null
else
  echo ""
  echo " None of systemd-boot, GRUB, or UKI detected. Please manually add these kernel parameters:"
  echo "  - rhgb (to see the graphical splash screen)"
  echo "  - quiet (for silent boot)"
  echo ""
fi

if [ "$(plymouth-set-default-theme)" != "omarchy" ]; then
  sudo cp -r "$HOME/.local/share/omarchy/default/plymouth" /usr/share/plymouth/themes/omarchy/
  # -R: set theme and rebuild initramfs (calls dracut on Fedora)
  sudo plymouth-set-default-theme -R omarchy
fi

# ==============================================================================
# SEAMLESS LOGIN
# ==============================================================================

if [ ! -x /usr/local/bin/seamless-login ]; then
  # Compile the seamless login helper -- needed to prevent seeing terminal between loader and desktop
  cat <<'CCODE' >/tmp/seamless-login.c
/*
* Seamless Login - Minimal SDDM-style Plymouth transition
* Replicates SDDM's VT management for seamless auto-login
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int vt_fd;
    int vt_num = 1; // TTY1
    char vt_path[32];

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <session_command>\n", argv[0]);
        return 1;
    }

    snprintf(vt_path, sizeof(vt_path), "/dev/tty%d", vt_num);
    vt_fd = open(vt_path, O_RDWR);
    if (vt_fd < 0) {
        perror("Failed to open VT");
        return 1;
    }

    if (ioctl(vt_fd, VT_ACTIVATE, vt_num) < 0) {
        perror("VT_ACTIVATE failed");
        close(vt_fd);
        return 1;
    }

    if (ioctl(vt_fd, VT_WAITACTIVE, vt_num) < 0) {
        perror("VT_WAITACTIVE failed");
        close(vt_fd);
        return 1;
    }

    if (ioctl(vt_fd, KDSETMODE, KD_GRAPHICS) < 0) {
        perror("KDSETMODE KD_GRAPHICS failed");
        close(vt_fd);
        return 1;
    }

    const char *clear_seq = "\33[H\33[2J";
    if (write(vt_fd, clear_seq, strlen(clear_seq)) < 0) {
        perror("Failed to clear VT");
    }

    close(vt_fd);

    const char *home = getenv("HOME");
    if (home) chdir(home);

    execvp(argv[1], &argv[1]);
    perror("Failed to exec session");
    return 1;
}
CCODE

  gcc -o /tmp/seamless-login /tmp/seamless-login.c
  sudo mv /tmp/seamless-login /usr/local/bin/seamless-login
  sudo chmod +x /usr/local/bin/seamless-login
  rm /tmp/seamless-login.c
fi

if [ ! -f /etc/systemd/system/omarchy-seamless-login.service ]; then
  cat <<EOF | sudo tee /etc/systemd/system/omarchy-seamless-login.service
[Unit]
Description=Omarchy Seamless Auto-Login
Documentation=https://github.com/basecamp/omarchy
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service plymouth-quit.service systemd-logind.service
PartOf=graphical.target

[Service]
Type=simple
ExecStart=/usr/local/bin/seamless-login uwsm start -- hyprland.desktop
Restart=always
RestartSec=2
User=$USER
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
StandardInput=tty
StandardOutput=journal
StandardError=journal+console
PAMName=login

[Install]
WantedBy=graphical.target
EOF
fi

if [ ! -f /etc/systemd/system/plymouth-quit.service.d/wait-for-graphical.conf ]; then
  # Make plymouth remain until graphical.target
  sudo mkdir -p /etc/systemd/system/plymouth-quit.service.d
  sudo tee /etc/systemd/system/plymouth-quit.service.d/wait-for-graphical.conf <<'EOF'
[Unit]
After=multi-user.target
EOF
fi

# Mask plymouth-quit-wait.service only if not already masked
if ! systemctl is-enabled plymouth-quit-wait.service | grep -q masked; then
  sudo systemctl mask plymouth-quit-wait.service
  sudo systemctl daemon-reload
fi

# Enable omarchy-seamless-login.service only if not already enabled
if ! systemctl is-enabled omarchy-seamless-login.service | grep -q enabled; then
  sudo systemctl enable omarchy-seamless-login.service
fi

# Disable getty@tty1.service only if not already disabled
if ! systemctl is-enabled getty@tty1.service | grep -q disabled; then
  sudo systemctl disable getty@tty1.service
fi
