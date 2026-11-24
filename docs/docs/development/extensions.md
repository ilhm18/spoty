---
title: Extensions
description: Creating extensions for Hamspot.
---

Extensions are JavaScript files that run alongside Spotify's main code. They can add UI elements, modify behavior, integrate with external services, and more.

## Extension Structure

```text
~/.config/hamspot/Extensions/   # Linux/macOS
%appdata%\hamspot\Extensions\   # Windows
├── myExtension.js
├── anotherExtension.js
└── ...
```

Extensions are single JavaScript files. For complex extensions with multiple files, use [Hamspot Creator](/docs/development/hamspot-creator/the-basics).

## Getting Started

### Location

Place your extension file in the Extensions folder:

| Platform | Path |
|----------|------|
| **Windows** | `%appdata%\hamspot\Extensions\` |
| **Linux / macOS** | `~/.config/hamspot/Extensions/` |

### Minimal Extension

```js
// myExtension.js
(function myExtension() {
    // Wait for Hamspot to be ready
    if (!Hamspot.Player || !Hamspot.Platform) {
        setTimeout(myExtension, 100);
        return;
    }

    console.log("My extension loaded!");

    // Your code here
})();
```

### Testing Your Extension

1. Save your file to the Extensions folder
2. Enable it:

   ```bash
   hamspot config extensions myExtension.js
   hamspot apply
   ```

3. Open DevTools in Spotify to see console output:
   - **Windows/Linux**: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd>
   - **macOS**: <kbd>Cmd</kbd> + <kbd>Option</kbd> + <kbd>I</kbd>


---

## The Hamspot API

Extensions access Spotify through the global `Hamspot` object. Key namespaces:

| Namespace | Purpose |
|-----------|---------|
| `Hamspot.Player` | Playback control (play, pause, skip, volume) |
| `Hamspot.Platform` | Core platform APIs (history, library, playlists) |
| `Hamspot.CosmosAsync` | HTTP requests to Spotify's internal API |
| `Hamspot.URI` | Parse and create Spotify URIs |
| `Hamspot.React` | React instance for UI components |
| `Hamspot.ReactDOM` | ReactDOM for rendering |
| `Hamspot.Topbar` | Add buttons to the top bar |
| `Hamspot.Playbar` | Add buttons to the player bar |
| `Hamspot.ContextMenu` | Add items to right-click menus |

See the **[API Wrapper Reference](/docs/development/api-wrapper)** for complete documentation.

---

## Common Patterns

### Waiting for Hamspot

Always wait for Hamspot to be ready before accessing its APIs:

```js
(function init() {
    if (!Hamspot.Player || !Hamspot.Platform) {
        setTimeout(init, 100);
        return;
    }

    main();
})();

function main() {
    // Safe to use Hamspot here
}
```

### Adding a Top Bar Button

```js
const button = new Hamspot.Topbar.Button(
    "My Button",
    `<svg>...</svg>`,  // SVG icon
    () => {
        console.log("Button clicked!");
    }
);
```

### Adding a Context Menu Item

```js
new Hamspot.ContextMenu.Item(
    "My Menu Item",
    (uris) => {
        console.log("Selected URIs:", uris);
    },
    (uris) => {
        // Return true to show this item
        return true;
    },
    `<svg>...</svg>`  // Optional icon
).register();
```

### Listening to Player Events

```js
Hamspot.Player.addEventListener("songchange", (event) => {
    const track = Hamspot.Player.data?.item;
    console.log("Now playing:", track?.name);
});
```

### Making API Requests

```js
// GET request
const response = await Hamspot.CosmosAsync.get(
    "https://api.spotify.com/v1/me/player"
);

// POST request
await Hamspot.CosmosAsync.post(
    "https://api.spotify.com/v1/me/player/play",
    { uris: ["spotify:track:..."] }
);
```

### Storing Data

```js
// Save
Hamspot.LocalStorage.set("myExtension:setting", "value");

// Load
const value = Hamspot.LocalStorage.get("myExtension:setting");
```

### Showing Notifications

```js
Hamspot.showNotification("Hello from my extension!");
```

---

## UI Development

### Using React

Hamspot exposes React for building UI:

```js
const { React, ReactDOM } = Hamspot;
const { useState, useEffect } = React;

function MyComponent() {
    const [count, setCount] = useState(0);

    return React.createElement("button", {
        onClick: () => setCount(c => c + 1)
    }, `Clicked ${count} times`);
}
```

### Using Spotify's Components

Access Spotify's internal React components:

```js
const { Button, Toggle } = Hamspot.ReactComponent;

// Use in your components
React.createElement(Button, {
    onClick: () => console.log("clicked")
}, "Click me");
```

### Creating Modals

```js
Hamspot.PopupModal.display({
    title: "My Modal",
    content: React.createElement("div", null, "Hello!"),
});
```

---

## Hamspot Creator

For a better development experience with TypeScript, JSX, and hot reloading, use **[Hamspot Creator](/docs/development/hamspot-creator/the-basics)**.

```bash
npx hamspot-creator
```

Benefits:
- TypeScript support with full type definitions
- JSX syntax (no manual `React.createElement`)
- Hot reloading during development
- Build tooling (bundling, minification)

---

## Best Practices

### Performance

- Avoid polling. Use event listeners when possible
- Debounce expensive operations
- Clean up listeners when no longer needed

### Error Handling

```js
try {
    const data = await Hamspot.CosmosAsync.get("...");
} catch (error) {
    console.error("Request failed:", error);
    Hamspot.showNotification("Something went wrong", true);
}
```

### Compatibility

- Test with both light and dark themes
- Check for API existence before using (APIs can change between Spotify versions)
- Use feature detection:

```js
if (Hamspot.Topbar?.Button) {
    // Safe to use
}
```

### Naming

- Use a unique prefix for localStorage keys: `myExtension:key`
- Use descriptive function and variable names

---

## Publishing

To share your extension:

1. **GitHub**: Create a repository with your extension file(s) and installation instructions

2. **Marketplace**: Submit to the [Hamspot Marketplace](https://github.com/spicetify/marketplace) for easy discovery and installation

---

## Resources

- **[API Wrapper Reference](/docs/development/api-wrapper)**: Complete API documentation
- **[Hamspot Creator](/docs/development/hamspot-creator/the-basics)**: TypeScript development tool
- **[Built-in Extensions](https://github.com/spicetify/cli/tree/main/Extensions)**: Reference implementations
- **[Marketplace Extensions](https://github.com/spicetify/marketplace)**: Community examples
