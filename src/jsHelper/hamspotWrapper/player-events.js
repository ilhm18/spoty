import { waitFor } from "./shared/async.js";

(function waitOrigins() {
  if (!Hamspot?.Player?.origin?._state) {
    setTimeout(waitOrigins, 10);
    return;
  }

  const playerState = {
    cache: null,
    current: null,
  };

  const interval = setInterval(() => {
    if (!Hamspot.Player.origin._state?.item) return;
    Hamspot.Player.data = Hamspot.Player.origin._state;
    playerState.cache = Hamspot.Player.data;
    clearInterval(interval);
  }, 10);

  Hamspot.Player.origin._events.addListener("update", ({ data: playerEventData }) => {
    playerState.current = playerEventData.item ? playerEventData : null;
    Hamspot.Player.data = playerState.current;

    if (playerState.cache?.item?.uri !== playerState.current?.item?.uri) {
      const event = new Event("songchange");
      event.data = Hamspot.Player.data;
      Hamspot.Player.dispatchEvent(event);
    }

    if (playerState.cache?.isPaused !== playerState.current?.isPaused) {
      const event = new Event("onplaypause");
      event.data = Hamspot.Player.data;
      Hamspot.Player.dispatchEvent(event);
    }

    playerState.cache = playerState.current;
  });

  (function waitProductStateAPI() {
    if (!Hamspot.Platform?.UserAPI) {
      setTimeout(waitProductStateAPI, 100);
      return;
    }

    const productState = Hamspot.Platform.UserAPI._product_state || Hamspot.Platform.UserAPI._product_state_service;
    if (productState) return;

    const productStateApi = Hamspot.Platform?.ProductStateAPI?.productStateApi;
    if (!productStateApi) {
      setTimeout(waitProductStateAPI, 100);
      return;
    }

    Hamspot.Platform.UserAPI._product_state_service = productStateApi;
  })();

  void (async function setButtonsHeight() {
    const CosmosAsync = await waitFor(() => Hamspot.CosmosAsync, 100);
    const expFeatures = JSON.parse(localStorage.getItem("hamspot-exp-features") || "{}");
    const isGlobalNavbar = expFeatures?.enableGlobalNavBar?.value;

    if (typeof isGlobalNavbar !== "undefined" && isGlobalNavbar === "control") {
      await CosmosAsync.post("sp://messages/v1/container/control", {
        type: "update_titlebar",
        height: Hamspot.Platform.PlatformData.os_name === "osx" ? "42" : "40",
      });
    }
  })();

  setInterval(() => {
    if (playerState.cache?.isPaused === false) {
      const event = new Event("onprogress");
      event.data = Hamspot.Player.getProgress();
      Hamspot.Player.dispatchEvent(event);
    }
  }, 100);

  Hamspot.addToQueue = (uri) => {
    return Hamspot.Player.origin._queue?.addToQueue(uri);
  };
  Hamspot.removeFromQueue = (uri) => {
    return Hamspot.Player.origin._queue?.removeFromQueue(uri);
  };
})();
