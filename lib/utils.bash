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
  echo '1.0.0'
}

download_release() {
  local version="$1"
  local download_path="$2"
  mkdir -p "$download_path"
  echo "$version" > "$download_path/VERSION"
  echo "Source compilation required for $TOOL_NAME $version"
}

install_version() {
  local version="$1"
  local install_path="$2"
  echo "Source compilation for $TOOL_NAME is not yet implemented"
  echo "Please install $TOOL_NAME $version manually"
  mkdir -p "$install_path/bin"
  cat > "$install_path/bin/$BINARY_NAME" << SCRIPT
#!/usr/bin/env bash
echo "$TOOL_NAME $version - source compilation required"
exit 1
SCRIPT
  chmod +x "$install_path/bin/$BINARY_NAME"
}
