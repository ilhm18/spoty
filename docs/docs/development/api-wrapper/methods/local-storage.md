---
title: LocalStorage
description: Get and set data in local storage.
---

Hamspot provides a wrapper for `localStorage` to make it easier to use.

:::tip

All keys created via this method are generic and stored as-is.

If you wish to store values that are specific for each user account, you can use [`Platform.LocalStorageAPI`](/docs/development/api-wrapper/methods/platform#localstorageapi) instead.

:::

```ts
namespace LocalStorage {
    function clear(): void;
    function get(key: string): string | null;
    function remove(key: string): void;
    function set(key: string, value: string): void;
};
```

## Methods

### `clear`

Empties the list associated with the object of all key/value pairs, if there are any.

:::warning

This method will remove all data in local storage, not just the data that Hamspot uses. This essentially resets the client to its default state.

It will also wipe all data stored by extensions and custom apps (e.g. Marketplace, Lyrics Plus, etc.)

:::

```ts
clear(): void
```

### `get`

Get key value from local storage.

```ts
get(key: string): string | null
```

| Parameter | Type | Description |
| :--- | :--- | :--- |
| key | `string` | Key to get value from. |

#### Example

```ts
const value = Hamspot.LocalStorage.get("foo");
```

### `remove`

Delete key from local storage.

```ts
remove(key: string): void
```

| Parameter | Type | Description |
| :--- | :--- | :--- |
| key | `string` | Key to delete. |

#### Example

```ts
Hamspot.LocalStorage.remove("foo");
```

### `set`

Set new value for key in local storage.

```ts
set(key: string, value: string): void
```

| Parameter | Type | Description |
| :--- | :--- | :--- |
| key | `string` | Key to set value for. |
| value | `string` | Value to set. |

#### Example

```ts
Hamspot.LocalStorage.set("foo", "bar");
```
