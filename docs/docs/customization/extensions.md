---
title: Extensions
description: Add features to Spotify with extensions.
---

Extensions are JavaScript files that add new features to Spotify. They run alongside Spotify's main code and can add buttons, modify behavior, and integrate with external services.

## Installing Extensions

### Via Marketplace

The easiest way to install extensions is through the **[Marketplace](./marketplace.md)**. Open Marketplace from Spotify's sidebar and browse the Extensions tab.

### Manual Installation

For extensions not in Marketplace, or for Hamspot's built-in extensions:

1. Place the extension file in your Extensions folder:

   | Platform | Path |
   |----------|------|
   | **Windows** | `%appdata%\hamspot\Extensions\` |
   | **Linux / macOS** | `~/.config/hamspot/Extensions/` |

2. Enable the extension:

   ```bash
   hamspot config extensions <filename.js>
   hamspot apply
   ```

:::tip
The `config extensions` command **appends** to your existing extensions. It doesn't replace them.
:::

## Removing Extensions

To remove an extension, append a `-` after the filename:

```bash
hamspot config extensions <filename.js>-
hamspot apply
```

## Manual Config Editing

You can also edit the config file directly. Extensions are listed in the `extensions` key, separated by `|`:

```ini
[AdditionalOptions]
extensions = fullAppDisplay.js|keyboardShortcut.js|trashbin.js
```

After editing, run `hamspot apply`.

---

## Built-in Extensions

These extensions ship with Hamspot and are available immediately after installation.

### Full App Display

A minimal, full-screen album art display with blur effect background.

**Filename:** `fullAppDisplay.js`

```bash
hamspot config extensions fullAppDisplay.js
hamspot apply
```

**Usage:** Click the button in the top bar to activate. Double-click anywhere to exit. Right-click to open settings.

![Full App Display](/images/extensions/full-app-display.png)

---

### Keyboard Shortcut

Extends Spotify's keyboard shortcuts with vim-like navigation.

**Filename:** `keyboardShortcut.js`

```bash
hamspot config extensions keyboardShortcut.js
hamspot apply
```

**Shortcuts:**
- <kbd>Ctrl</kbd> + <kbd>Tab</kbd> / <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd>: Navigate sidebar items
- <kbd>Page Up</kbd> / <kbd>Page Down</kbd>: Scroll the main page
- <kbd>J</kbd> / <kbd>K</kbd>: Scroll down/up (vim-style)
- <kbd>G</kbd> / <kbd>Shift</kbd> + <kbd>G</kbd>: Jump to top/bottom
- <kbd>F</kbd>: Open keyboard-driven navigation

![Keyboard Shortcut](/images/extensions/keyboard-demo.png)

---

### Bookmark

Save and quickly access pages, tracks, or specific timestamps.

**Filename:** `bookmark.js`

```bash
hamspot config extensions bookmark.js
hamspot apply
```

**Usage:** Useful for bookmarking artists, albums, or playlists to check out later without following them.

![Bookmark](/images/extensions/bookmark.png)

---

### Trash Bin

Skip songs or artists automatically. They'll never play again.

**Filename:** `trashbin.js`

```bash
hamspot config extensions trashbin.js
hamspot apply
```

**Usage:** Right-click any track or artist and select "Throw to Trashbin". Trashed items are automatically skipped.

![Trash Bin](/images/extensions/trash.png)

---

### Shuffle+

True shuffle using the Fisher-Yates algorithm (zero bias).

**Filename:** `shuffle+.js`

```bash
hamspot config extensions shuffle+.js
hamspot apply
```

**Usage:** Right-click any album, playlist, or artist and select "Play with Shuffle+". Also works with multi-selected tracks.

![Shuffle+](/images/extensions/shuffle.png)

---

### Loopy Loop

Loop a specific portion of a track.

**Filename:** `loopyLoop.js`

```bash
hamspot config extensions loopyLoop.js
hamspot apply
```

**Usage:** Mark start and end points on the progress bar to loop that section automatically.

![Loopy Loop](/images/extensions/loopy-loop.png)

---

### Pop-up Lyrics

Display lyrics in a separate pop-up window.

**Filename:** `popupLyrics.js`

```bash
hamspot config extensions popupLyrics.js
hamspot apply
```

**Usage:** Click the microphone icon in the top bar. Right-click for settings and lyrics provider options.

![Pop-up Lyrics](/images/extensions/popup-lyrics.png)

:::note
If lyrics aren't loading, see the [FAQ](/docs/faq#sometimes-popup-lyrics-andor-lyrics-plus-seem-to-not-work) for Musixmatch token instructions.
:::

---

### Auto Skip Videos

Automatically skip video content that can't play in your region.

**Filename:** `autoSkipVideo.js`

```bash
hamspot config extensions autoSkipVideo.js
hamspot apply
```

**Why:** Some video content is region-locked. Without this extension, playback just stops instead of moving to the next track.

---

### Christian Spotify

Automatically skip explicit tracks.

**Filename:** `autoSkipExplicit.js`

```bash
hamspot config extensions autoSkipExplicit.js
hamspot apply
```

**Usage:** Toggle in the profile menu (top-right button).

![Christian Spotify](/images/extensions/christian-demo.png)

---

### Web Now Playing

Send track metadata to Rainmeter's WebNowPlaying plugin.

**Filename:** `webnowplaying.js`

```bash
hamspot config extensions webnowplaying.js
hamspot apply
```

**For minimal setup** (no UI changes):

```bash
hamspot config inject_css 0 replace_colors 0
hamspot config extensions webnowplaying.js
hamspot apply
```

---

## Creating Extensions

Want to build your own extension? See the **[Development Guide](/docs/development)** and **[Hamspot Creator](/docs/development/hamspot-creator/the-basics)** for tools and tutorials.
