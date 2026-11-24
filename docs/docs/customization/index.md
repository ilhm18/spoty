---
title: Customization
description: Customize Spotify with themes, extensions, and custom apps.
---

Hamspot lets you customize Spotify in three ways:

| Type | What it does |
|------|--------------|
| **[Themes](./themes.md)** | Change colors, fonts, and visual styling |
| **[Extensions](./extensions.md)** | Add new features and functionality |
| **[Custom Apps](./custom-apps.md)** | Add entirely new pages to the sidebar |

## Marketplace vs Manual Installation

There are two ways to install customizations:

### Marketplace (Recommended)

The **[Hamspot Marketplace](./marketplace.md)** is a built-in browser that lets you discover, install, and manage themes, extensions, and snippets directly from Spotify's sidebar.

If you followed the [Getting Started](/docs/getting-started) guide, you already have Marketplace installed.

**Use Marketplace when:**
- You want a simple, visual way to browse and install customizations
- You prefer one-click installation
- You want automatic updates

### Manual Installation

Manual installation gives you direct control over your Hamspot configuration.

**Use manual installation when:**
- The theme/extension isn't available in Marketplace
- You're developing your own customizations
- You want to use built-in extensions that ship with Hamspot
- You need precise control over what's installed

Each customization page in this section covers both Marketplace usage and manual installation.

## Configuration

All manual customizations are controlled through:

- **CLI commands**: `hamspot config <key> <value>` followed by `hamspot apply`
- **Config file**: Direct editing of `config-xpui.ini`

See the **[Configuration Reference](./config-file.md)** for details on the config file and all available options.
