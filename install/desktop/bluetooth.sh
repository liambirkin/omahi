#!/bin/bash

# Install bluetooth controls
sudo dnf -y install blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
