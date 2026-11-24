#!/data/data/com.termux/files/usr/bin/bash
set -e

GITHUB_REPO="${HAMSPOT_MOBILE_REPO:-ilhm18/spoty}"
BINARY_NAME="hamspot-mobile-android-arm64"
INSTALL_PATH="$PREFIX/bin/hamspot-mobile"

if [ "$GITHUB_REPO" = "YOUR_GITHUB_USERNAME/YOUR_REPO" ]; then
    echo "Set HAMSPOT_MOBILE_REPO first."
    echo "Example: export HAMSPOT_MOBILE_REPO=username/hamspot"
    exit 1
fi

pkg install -y curl

DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/${BINARY_NAME}"
if curl -fL "$DOWNLOAD_URL" -o "$HOME/$BINARY_NAME"; then
    install -m 700 "$HOME/$BINARY_NAME" "$INSTALL_PATH"
else
    pkg install -y git golang
    WORK_DIR="${TMPDIR:-/tmp}/hamspot-mobile-source"
    rm -rf "$WORK_DIR"
    git clone --depth 1 "https://github.com/${GITHUB_REPO}.git" "$WORK_DIR"
    cd "$WORK_DIR"
    CGO_ENABLED=0 GOOS=android GOARCH=arm64 go build -o "$INSTALL_PATH" .
fi

echo "Installed: $INSTALL_PATH"
echo "Run: hamspot-mobile --help"
echo "Configure:"
echo "  export HAMSPOT_MOBILE_URL=http://DESKTOP_LAN_IP:27228"
echo "  export HAMSPOT_MOBILE_TOKEN=TOKEN_FROM_DESKTOP"
echo "  hamspot-mobile mobile-client \$HAMSPOT_MOBILE_URL \$HAMSPOT_MOBILE_TOKEN status"
