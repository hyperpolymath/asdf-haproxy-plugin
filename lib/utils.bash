#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="haproxy"
BINARY_NAME="haproxy"

fail() {
  echo -e "\e[31mFail:\e[m $*" >&2
  exit 1
}

list_all_versions() {
  curl -sL "https://www.haproxy.org/download/" |
grep -oE '[0-9]+\.[0-9]+\.[0-9]+' |
sort -V |
uniq
}

download_release() {
  local version="$1"
  local download_path="$2"

  # Source compile - download source tarball
  local url="https://www.haproxy.org/download/{major}.{minor}/src/haproxy-{version}.tar.gz"
  url="$(echo "$url" | sed "s/{version}/$version/g")"

  # Extract major.minor for some URLs
  local major minor
  major="$(echo "$version" | cut -d. -f1)"
  minor="$(echo "$version" | cut -d. -f2)"
  url="$(echo "$url" | sed "s/{major}/$major/g" | sed "s/{minor}/$minor/g")"

  echo "Downloading $TOOL_NAME $version source from $url"
  mkdir -p "$download_path"

  local ext
  if [[ "$url" == *.tar.xz ]]; then
    curl -fsSL "$url" | tar -xJ -C "$download_path" --strip-components=1
  elif [[ "$url" == *.tar.gz ]] || [[ "$url" == *.tgz ]]; then
    curl -fsSL "$url" | tar -xz -C "$download_path" --strip-components=1
  else
    fail "Unknown archive format: $url"
  fi
}

install_version() {
  local version="$1"
  local install_path="$2"

  cd "$ASDF_DOWNLOAD_PATH"

  echo "Compiling $TOOL_NAME $version..."

  # Standard configure/make/install
  if [[ -f "configure" ]]; then
    ./configure --prefix="$install_path"
    make -j"$(nproc 2>/dev/null || echo 4)"
    make install
  elif [[ -f "Makefile" ]]; then
    make PREFIX="$install_path" -j"$(nproc 2>/dev/null || echo 4)"
    make PREFIX="$install_path" install
  else
    fail "No build system found"
  fi
}
