#!/bin/sh
# Copyright 2019 khanhas. GPL license.
# Edited from project Denoland install script (https://github.com/denoland/deno_install)

set -e

   
# download uri
releases_uri=https://github.com/spicetify/marketplace/releases
if [ $# -gt 0 ]; then
	tag=$1
else
	tag=$(curl -LsH 'Accept: application/json' $releases_uri/latest)
	tag=${tag%\,\"update_url*}
	tag=${tag##*tag_name\":\"}
	tag=${tag%\"}
fi

tag=${tag#v}

echo "FETCHING Version $tag"

download_uri=$releases_uri/download/v$tag/marketplace.zip
    default_color_uri="https://raw.githubusercontent.com/spicetify/marketplace/main/resources/color.ini"

HAMSPOT_CONFIG_DIR="$HAMSPOT_CONFIG"
if [ -z "$HAMSPOT_CONFIG_DIR" ]; then
	HAMSPOT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hamspot"
fi
INSTALL_DIR="$HAMSPOT_CONFIG_DIR/CustomApps"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "MAKING FOLDER  $INSTALL_DIR";
    mkdir -p "$INSTALL_DIR"
fi

TAR_FILE="$INSTALL_DIR/marketplace-dist.zip"

echo "DOWNLOADING $download_uri"
curl --fail --location --progress-bar --output "$TAR_FILE" "$download_uri"
cd "$INSTALL_DIR"

echo "EXTRACTING"
unzip -q -d "$INSTALL_DIR/marketplace-tmp" -o "$TAR_FILE"

cd "$INSTALL_DIR/marketplace-tmp"
echo "COPYING"
rm -rf "$INSTALL_DIR/marketplace/" "$INSTALL_DIR/marketplace/"
mv "$INSTALL_DIR/marketplace-tmp/marketplace-dist" "$INSTALL_DIR/marketplace"

echo "INSTALLING"
cd "$INSTALL_DIR/marketplace"

# Remove old custom app name if exists
hamspot config custom_apps hamspot-marketplace-

# Color injection fix
hamspot config inject_css 1
hamspot config replace_colors 1

current_theme=$(hamspot config current_theme)
if [ ${#current_theme} -le 3 ]; then
    echo "No theme selected, using placeholder theme"
    if [ ! -d "$HAMSPOT_CONFIG_DIR/Themes/marketplace" ]; then
        echo "MAKING FOLDER  $HAMSPOT_CONFIG_DIR/Themes/marketplace";
        mkdir -p "$HAMSPOT_CONFIG_DIR/Themes/marketplace"
    fi
    curl --fail --location --progress-bar --output "$HAMSPOT_CONFIG_DIR/Themes/marketplace/color.ini" "$default_color_uri"
    hamspot config current_theme marketplace;
fi

if hamspot config custom_apps marketplace ; then
    echo "Added to config!"
    echo "APPLYING"
    hamspot apply
else
    echo "Command failed"
    echo "Please run \`hamspot config custom_apps marketplace\` manually "
    echo "Next run \`hamspot apply\`"
fi

echo "CLEANING UP"
rm -rf "$TAR_FILE" "$INSTALL_DIR/marketplace-tmp/"
