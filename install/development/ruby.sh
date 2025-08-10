#!/bin/bash
set -euo pipefail

pick_compilers() {
  if command -v gcc-14 >/dev/null 2>&1 && command -v g++-14 >/dev/null 2>&1; then
    CC_BIN=gcc-14
    CXX_BIN=g++-14
    return 0
  fi

  # GCC 14 via gcc-toolset-14 (SCL style)
  if [ -x /opt/rh/gcc-toolset-14/root/usr/bin/gcc ] && [ -x /opt/rh/gcc-toolset-14/root/usr/bin/g++ ]; then
    CC_BIN=/opt/rh/gcc-toolset-14/root/usr/bin/gcc
    CXX_BIN=/opt/rh/gcc-toolset-14/root/usr/bin/g++
    return 0
  fi

  # Fallback to system gcc/g++
  if command -v gcc >/dev/null 2>&1 && command -v g++ >/dev/null 2>&1; then
    CC_BIN=gcc
    CXX_BIN=g++
    return 0
  fi

  return 1
}

# Try to get gcc-14 first (preferred on newer Fedora)
sudo dnf -y install gcc14 || true

# If that didn't provide gcc-14/g++-14, try toolset
if ! command -v gcc-14 >/dev/null 2>&1; then
  sudo dnf -y install gcc-toolset-14 || true
fi

if pick_compilers; then
  echo "Using CC=${CC_BIN}, CXX=${CXX_BIN}"
  mise settings set ruby.ruby_build_opts "CC=${CC_BIN} CXX=${CXX_BIN}"
else
  echo "ERROR: No usable C/C++ compiler found." >&2
  exit 1
fi

# Trust .ruby-version
mise settings add idiomatic_version_file_enable_tools ruby
