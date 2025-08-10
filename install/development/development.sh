#!/bin/bash

sudo dnf -y install \
  rust cargo clang llvm mise \
  ImageMagick \
  mariadb-connector-c postgresql \
  gh \
  lazygit lazydocker
