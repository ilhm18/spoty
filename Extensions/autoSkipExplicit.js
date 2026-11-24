// NAME: Christian Spotify
// AUTHOR: khanhas
// DESCRIPTION: Auto skip explicit songs. Toggle in Profile menu.

/// <reference path="../globals.d.ts" />

(async function ChristianSpotify() {
  if (!Hamspot.LocalStorage) {
    setTimeout(ChristianSpotify, 1000);
    return;
  }
  await new Promise((res) => Hamspot.Events.webpackLoaded.on(res));

  let isEnabled = Hamspot.LocalStorage.get("ChristianMode") === "1";

  new Hamspot.Menu.Item("Christian mode", isEnabled, (self) => {
    isEnabled = !isEnabled;
    Hamspot.LocalStorage.set("ChristianMode", isEnabled ? "1" : "0");
    self.setState(isEnabled);
  }).register();

  Hamspot.Player.addEventListener("songchange", () => {
    if (!isEnabled) return;
    const data = Hamspot.Player.data || Hamspot.Queue;
    if (!data) return;

    const isExplicit = data.item.metadata.is_explicit;
    if (isExplicit === "true") {
      Hamspot.Player.next();
    }
  });
})();
