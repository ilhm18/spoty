---
title: Commands
description: Complete Hamspot command reference.
---

This page documents all Hamspot CLI commands.

## Core Commands

### `hamspot` (no arguments)

Run with no arguments to generate the config file on first run, or verify your setup.

```bash
hamspot
```

### `backup`

Create a backup of vanilla Spotify files. Required before applying Hamspot for the first time.

```bash
hamspot backup
```

### `apply`

Apply Hamspot modifications to Spotify.

```bash
hamspot apply
```

This injects your theme, extensions, custom apps, and other modifications into Spotify.

### `restore`

Remove all Hamspot modifications and restore Spotify to vanilla state.

```bash
hamspot restore
```

Your config file and customization files are preserved.

### `update`

Hot-reload theme changes without full restart. Use this during theme development.

```bash
hamspot update
```

After running, press <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> (or <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> on macOS) in Spotify to see changes.

### `upgrade`

Upgrade Hamspot to the latest version (only works with script-based installations).

```bash
hamspot upgrade
```

---

## Configuration Commands

### `config`

View or modify configuration values.

**View all settings:**

```bash
hamspot config
```

**View a specific setting:**

```bash
hamspot config current_theme
```

**Set a value:**

```bash
hamspot config current_theme Sleek
```

**Set multiple values:**

```bash
hamspot config current_theme Sleek color_scheme Dark
```

**Add to a list (extensions, custom_apps):**

```bash
hamspot config extensions fullAppDisplay.js
```

This appends to existing extensions, not replaces.

**Remove from a list:**

```bash
hamspot config extensions fullAppDisplay.js-
```

Note the trailing `-`.

### `config-dir`

Open the Hamspot config directory in your file manager.

```bash
hamspot config-dir
```

### `-c` / `--config`

Print the config file path.

```bash
hamspot -c
```

---

## Utility Commands

### `enable-devtools`

Enable Chromium DevTools in Spotify. Useful for debugging themes and extensions.

```bash
hamspot enable-devtools
```

Access DevTools with <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd>.

### `watch`

Watch for theme changes and auto-apply. Useful during development.

```bash
hamspot watch
```

Monitors `color.ini` and `user.css` in your current theme folder.

### `path`

Print various Hamspot-related paths.

```bash
hamspot path
hamspot path userdata   # Config directory
hamspot path spotify    # Spotify installation
```

### `auto`

Automatically backup (if needed) and apply, then launch Spotify.

```bash
hamspot auto
```

Useful as a shortcut target instead of the Spotify executable.

---

## Combined Commands

Commands can be combined in a single call:

```bash
# First-time setup
hamspot backup apply enable-devtools

# After Spotify updates
hamspot backup apply

# Full restore and reapply
hamspot restore backup apply
```

---

## Flags

### `--help` / `-h`

Show help for a command.

```bash
hamspot --help
hamspot --help config
```

### `--version` / `-v`

Show Hamspot version.

```bash
hamspot --version
```

### `--no-restart`

Apply changes without restarting Spotify.

```bash
hamspot apply --no-restart
```

### `--quiet` / `-q`

Suppress non-error output.

```bash
hamspot apply -q
```

### `--extension` / `-e`

Specify a single extension to apply (useful for testing).

```bash
hamspot apply -e myExtension.js
```

---

## Examples

### Fresh Install Workflow

```bash
# Install Hamspot (see Installation page)
# Generate config
hamspot

# First-time setup
hamspot backup apply enable-devtools
```

### Enable an Extension

```bash
hamspot config extensions fullAppDisplay.js
hamspot apply
```

### Change Theme

```bash
hamspot config current_theme Sleek color_scheme Dark
hamspot apply
```

### After Spotify Updates

```bash
hamspot backup apply
```

### Theme Development

```bash
# One-time: apply your theme
hamspot config current_theme MyTheme
hamspot apply

# During development: watch for changes
hamspot watch
```
