#!/bin/bash

PACKAGE_NAME="k9s"
GITHUB_REPO="derailed/k9s"
ARCHIVE_NAME="${PACKAGE_NAME}.tar.gz"

# Where the binary is located (or how to get the current version)
INSTALLED_VERSION=$($PACKAGE_NAME version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [ -z "$INSTALLED_VERSION" ]; then
    echo "📦 Package $PACKAGE_NAME is not installed."
else
    echo "Installed version: v$INSTALLED_VERSION"
fi

# Get the latest version from GitHub via API
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r '.tag_name')
echo "📦 Latest available version: $LATEST_VERSION"

# Compare versions
if [ "v$INSTALLED_VERSION" == "$LATEST_VERSION" ]; then
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

if [ -f "$ARCHIVE_NAME" ]; then

  echo "✅ Archive $ARCHIVE_NAME already exists. Skipping download."
  sleep 1
else

# Download the source archive (assuming for Linux amd64)
curl -L -o $PACKAGE_NAME.tar.gz "https://github.com/derailed/k9s/archive/refs/tags/$LATEST_VERSION.tar.gz"

fi

STRIPPED_VERSION="${LATEST_VERSION#v}"
FOLDER_NAME="${PACKAGE_NAME}-${STRIPPED_VERSION}"

if [ -d "$FOLDER_NAME" ]; then
  echo "✅ Folder $FOLDER_NAME already exists."
  sleep 1
else

  echo "Extracting archive $PACKAGE_NAME.tar.gz"

  sleep 1
  tar -xzvf $PACKAGE_NAME.tar.gz

  echo "Archive $PACKAGE_NAME.tar.gz extracted"
fi

if [ -f "$FOLDER_NAME"/execs/"$PACKAGE_NAME" ]; then
   echo "✅ Binary file is already built"
else
   echo "🛠 Starting build from source..."
sleep 1

fi

cd "$PACKAGE_NAME-$STRIPPED_VERSION" || exit 1


if make build; then
  echo "✅ Binary file execs/$PACKAGE_NAME created"
  chmod +x execs/"$PACKAGE_NAME"
  sudo cp execs/"$PACKAGE_NAME" /usr/local/bin/
else
  echo "❌ Binary file execs/$PACKAGE_NAME not found after build"
  exit 1
fi

$PACKAGE_NAME version
sleep 1

echo "✅ Installation completed ✅"
sleep 1
