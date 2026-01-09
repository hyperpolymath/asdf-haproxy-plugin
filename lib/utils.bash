#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="haproxy"
BINARY_NAME="haproxy"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  curl -sL "https://www.haproxy.org/download/" 2>/dev/null | \
    grep -oE 'href="[0-9]+\.[0-9]+/' | sed 's/href="//;s/\/$//' | sort -V
}

download_release() {
  local version="$1" download_path="$2"
  local major_minor="${version%.*}"
  local url="https://www.haproxy.org/download/${major_minor}/src/haproxy-${version}.tar.gz"

  echo "Downloading HAProxy $version..."
  mkdir -p "$download_path"
  curl -fsSL "$url" -o "$download_path/haproxy.tar.gz" || fail "Download failed"
  tar -xzf "$download_path/haproxy.tar.gz" -C "$download_path" --strip-components=1
  rm -f "$download_path/haproxy.tar.gz"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"

  cd "$ASDF_DOWNLOAD_PATH"
  make -j"$(nproc)" TARGET=linux-glibc PREFIX="$install_path" || fail "Build failed"
  make install PREFIX="$install_path" || fail "Install failed"
}
