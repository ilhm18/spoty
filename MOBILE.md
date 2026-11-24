# Spicetify Mobile

Spicetify modifies the desktop Spotify client. Android and iPhone Spotify applications
are sandboxed and do not expose the desktop `Apps` directory, so this project cannot
patch or replace the official mobile app directly.

This feature provides a mobile-friendly control panel in a browser. The mobile phone
does not run Spicetify; it sends authenticated commands to Spicetify running on the
Windows, macOS, or Linux desktop.

## Start the server

Windows PowerShell:

```powershell
spicetify mobile 0.0.0.0:27228
```

macOS/Linux:

```sh
spicetify mobile 0.0.0.0:27228
```

The command prints the desktop's LAN address and a generated access token.

## Android

1. Connect the Android phone and desktop to the same Wi-Fi network.
2. Open `http://DESKTOP-LAN-IP:27228/` in Chrome.
3. Enter the access token printed by the desktop command.
4. Tap `Backup`, `Apply`, `Refresh`, or `Restore`.

## iPhone

1. Connect the iPhone and desktop to the same Wi-Fi network.
2. Open `http://DESKTOP-LAN-IP:27228/` in Safari.
3. Enter the access token printed by the desktop command.
4. Use the control buttons.

## Security

- Use `127.0.0.1:27228` for local desktop-only access.
- Use `0.0.0.0:27228` only on a trusted network.
- Keep the generated token private. It is required for every API request.
- Rotating the token requires restarting `spicetify mobile`.
- HTTP does not encrypt traffic. Do not expose the server to the public internet.
- Stop the server with `Ctrl+C` on the desktop.

## Termux Android

Android can run the Spicetify mobile client through Termux. It remains a remote
controller for the desktop: it does not patch the Spotify Android app.

From a desktop with the repository, build the Android/Termux binary:

```powershell
scripts\build-mobile.ps1
```

Copy `dist/spicetify-mobile-android-arm64` into Termux:

```sh
termux-setup-storage
cp ~/storage/shared/Download/spicetify-mobile-android-arm64 ~/spicetify
chmod +x ~/spicetify
```

Set the desktop address and token:

```sh
export SPICETIFY_MOBILE_URL=http://DESKTOP-LAN-IP:27228
export SPICETIFY_MOBILE_TOKEN=TOKEN_FROM_DESKTOP

~/spicetify mobile-client "$SPICETIFY_MOBILE_URL" "$SPICETIFY_MOBILE_TOKEN" status
~/spicetify mobile-client "$SPICETIFY_MOBILE_URL" "$SPICETIFY_MOBILE_TOKEN" backup
~/spicetify mobile-client "$SPICETIFY_MOBILE_URL" "$SPICETIFY_MOBILE_TOKEN" apply
~/spicetify mobile-client "$SPICETIFY_MOBILE_URL" "$SPICETIFY_MOBILE_TOKEN" restore
```

## Install from GitHub in Termux

Deploy this repository to GitHub, then create a release tag:

```sh
git tag mobile-v1
git push origin mobile-v1
```

On an Android phone in Termux:

```sh
pkg update -y
pkg install -y curl bash
export SPICETIFY_MOBILE_REPO=YOUR_GITHUB_USERNAME/YOUR_REPO
bash <(curl -fsSL "https://raw.githubusercontent.com/$SPICETIFY_MOBILE_REPO/main/termux/install.sh")
```

Replace `YOUR_REPO` with the repository name and `main` with the default branch if it
is different. The installer downloads the release binary; if no release binary exists,
it builds the latest source locally in Termux.

## iPhone

Termux is not available as a native iPhone application. iPhone support in this
repository is browser-based only, through Safari. An iPhone cannot run the mobile
native binary or patch the official Spotify iOS app.
