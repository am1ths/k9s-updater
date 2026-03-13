#!/bin/bash

set -e

PACKAGE_NAME="k9s"
GITHUB_REPO="derailed/k9s"
ARCHIVE_NAME="${PACKAGE_NAME}.tar.gz"
ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags"

# Where the binary is located (or how to get the current version)
INSTALLED_VERSION=$($PACKAGE_NAME version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
if [ -z "$INSTALLED_VERSION" ]; then
    echo "📦 Package $PACKAGE_NAME is not installed."
else
    echo "Installed version: v$INSTALLED_VERSION"
fi

# Get the latest version from GitHub
LATEST_VERSION=""
# Method 1: GitHub API (can hit rate limit without auth)
if command -v jq &>/dev/null; then
  LATEST_VERSION=$(curl -sf "https://api.github.com/repos/$GITHUB_REPO/releases/latest" 2>/dev/null | jq -r '.tag_name // empty')
fi
# Method 2: Fallback — parse from redirect URL (no API, no rate limit)
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  REDIRECT_URL=$(curl -sL -o /dev/null -w '%{url_effective}' "https://github.com/$GITHUB_REPO/releases/latest" 2>/dev/null)
  LATEST_VERSION=$(echo "$REDIRECT_URL" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' || true)
fi
if [ -z "$LATEST_VERSION" ]; then
  echo "❌ Error: Could not fetch latest version from GitHub."
  echo "   Check: network, proxy, firewall. GitHub API may be rate-limited."
  exit 1
fi
echo "📦 Latest available version: $LATEST_VERSION"

# Compare versions
if [ "v$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
    echo "💡 Latest version is already installed. Installation is not required."
    exit 0
fi

# Check if the binary is installed in the system PATH
if command -v "$PACKAGE_NAME" >/dev/null; then
  INSTALLED_VERSION=$($PACKAGE_NAME version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  LATEST_VERSION_CLEAN="${LATEST_VERSION#v}"

  echo "🔍 Detected installed version: v$INSTALLED_VERSION"

  if [ "$INSTALLED_VERSION" != "$LATEST_VERSION_CLEAN" ]; then
    echo "♻️ Outdated version detected. Removing /usr/local/bin/$PACKAGE_NAME..."
    sudo rm -f /usr/local/bin/"$PACKAGE_NAME"
    sleep 1
  else
    echo "✅ Latest version is already installed. Nothing to remove."
  fi
else
  echo "ℹ️ $PACKAGE_NAME is not currently installed. Nothing to remove."
fi

# If the version is different — perform installation
echo "Updating to version $LATEST_VERSION..."

# Remove old archive before downloading (prevents using stale/outdated archive)
if [ -f "$ARCHIVE_NAME" ]; then
  echo "🗑️ Removing old archive $ARCHIVE_NAME before downloading..."
  rm -f "$ARCHIVE_NAME"
fi

# Remove old extracted folder for target version (ensures clean build)
STRIPPED_VERSION="${LATEST_VERSION#v}"
FOLDER_NAME="${PACKAGE_NAME}-${STRIPPED_VERSION}"
if [ -d "$FOLDER_NAME" ]; then
  echo "🗑️ Removing old folder $FOLDER_NAME before extraction..."
  rm -rf "$FOLDER_NAME"
fi

# Download the source archive
echo "⬇️ Downloading $LATEST_VERSION..."
if ! wget -q --show-progress -O "$ARCHIVE_NAME" "${ARCHIVE_URL}/${LATEST_VERSION}.tar.gz"; then
  echo "❌ Error: Failed to download archive"
  exit 1
fi
echo "✅ Archive $ARCHIVE_NAME downloaded"

# Extract archive
echo "📂 Extracting archive $ARCHIVE_NAME..."
tar -xf "$ARCHIVE_NAME"
echo "✅ Archive extracted to $FOLDER_NAME"

echo "🛠️ Starting build from source..."
cd "$FOLDER_NAME" || exit 1

if make build; then
  echo "✅ Binary file execs/$PACKAGE_NAME created"
  chmod +x execs/"$PACKAGE_NAME"
  sudo cp execs/"$PACKAGE_NAME" /usr/local/bin/
  echo "✅ Binary installed to /usr/local/bin/$PACKAGE_NAME"
else
  echo "❌ Binary file execs/$PACKAGE_NAME not found after build"
  exit 1
fi

echo ""
$PACKAGE_NAME version
echo ""
echo "✅ Installation completed"
