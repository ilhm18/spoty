---
title: removeFromQueue
description: Removes a track or array of tracks from prioritized queue.
---

:::tip

This works similarly to [`Hamspot.Platform.PlayerAPI.removeFromQueue`](/docs/development/api-wrapper/methods/platform#removefromqueue).

:::

:::caution

If a `uid` is not provided, all tracks with the same `uri` will be removed.

:::

```ts
function removeFromQueue(uri: ContextTrack[]): Promise<void>;
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `uri` | [`ContextTrack[]`](/docs/development/api-wrapper/types/context-track) | Array of tracks to remove from queue. |

#### Example

```ts
// Remove current track from queue
const currentTrack = Hamspot.Player.data.item;

await Hamspot.removeFromQueue([currentTrack]);

// Remove a track from queue
const trackUri = "spotify:track:4iV5W9uYEdYUVa79Axb7Rh";

await Hamspot.removeFromQueue([ { uri: trackUri } ]);
```
