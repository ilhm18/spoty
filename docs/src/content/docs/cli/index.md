---
title: CLI Reference
description: Command-line interface reference for Hamspot.
---

Hamspot is primarily a command-line tool. This section covers the command reference.

## Quick Start

After [installing Hamspot](/docs/getting-started), the basic workflow is:

```bash
# Generate config (first run only)
hamspot

# Backup Spotify and apply Hamspot
hamspot backup apply

# After making changes, apply them
hamspot apply
```

## Getting Help

For help on any command:

```bash
hamspot --help
hamspot --help <command>
```

Example:

```bash
hamspot --help config
```
