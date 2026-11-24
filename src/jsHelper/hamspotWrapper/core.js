window.Hamspot = {
  Player: {
    addEventListener: (type, callback) => {
      if (!(type in Hamspot.Player.eventListeners)) {
        Hamspot.Player.eventListeners[type] = [];
      }
      Hamspot.Player.eventListeners[type].push(callback);
    },
    dispatchEvent: (event) => {
      if (!(event.type in Hamspot.Player.eventListeners)) {
        return true;
      }
      const stack = Hamspot.Player.eventListeners[event.type];
      for (let i = 0; i < stack.length; i++) {
        if (typeof stack[i] === "function") {
          stack[i](event);
        }
      }
      return !event.defaultPrevented;
    },
    eventListeners: {},
    seek: (p) => {
      const duration = !Number.isInteger(p) && p >= 0 && p <= 1 ? Math.round(p * Hamspot.Player.origin._state.duration) : p;
      Hamspot.Player.origin.seekTo(duration);
    },
    getProgress: () => {
      const state = Hamspot.Player.origin._state;
      return (state.isPaused ? 0 : Date.now() - state.timestamp) + state.positionAsOfTimestamp;
    },
    getProgressPercent: () => {
      const state = Hamspot.Player.origin._state;
      return Hamspot.Player.getProgress() / state.duration;
    },
    getDuration: () => Hamspot.Player.origin._state.duration,
    setVolume: (v) => {
      Hamspot.Platform.PlaybackAPI.setVolume(v);
    },
    increaseVolume: () => {
      Hamspot.Platform.PlaybackAPI.raiseVolume();
    },
    decreaseVolume: () => {
      Hamspot.Platform.PlaybackAPI.lowerVolume();
    },
    getVolume: () => Hamspot.Platform.PlaybackAPI._volume,
    next: () => {
      Hamspot.Player.origin.skipToNext();
    },
    back: () => {
      Hamspot.Player.origin.skipToPrevious();
    },
    togglePlay: () => {
      if (Hamspot.Player.isPlaying()) Hamspot.Player.pause();
      else Hamspot.Player.play();
    },
    isPlaying: () => !Hamspot.Player.origin._state.isPaused,
    toggleShuffle: () => {
      Hamspot.Player.origin.setShuffle(!Hamspot.Player.origin._state.shuffle);
    },
    getShuffle: () => Hamspot.Player.origin._state.shuffle,
    setShuffle: (b) => {
      Hamspot.Player.origin.setShuffle(b);
    },
    toggleRepeat: () => {
      Hamspot.Player.origin.setRepeat((Hamspot.Player.origin._state.repeat + 1) % 3);
    },
    getRepeat: () => Hamspot.Player.origin._state.repeat,
    setRepeat: (r) => {
      Hamspot.Player.origin.setRepeat(r);
    },
    getMute: () => Hamspot.Player.getVolume() === 0,
    toggleMute: () => {
      Hamspot.Player.setMute(!Hamspot.Player.getMute());
    },
    setMute: (b) => {
      if (b !== Hamspot.Player.getMute()) {
        document.querySelector(".volume-bar__icon-button")?.click();
      }
    },
    formatTime: (ms) => {
      let seconds = Math.floor(ms / 1e3);
      const minutes = Math.floor(seconds / 60);
      seconds -= minutes * 60;
      return `${minutes}:${seconds > 9 ? "" : "0"}${String(seconds)}`;
    },
    getHeart: () => Hamspot.Player.origin._state.item?.metadata["collection.in_collection"] === "true",
    pause: () => {
      Hamspot.Player.origin.pause();
    },
    play: () => {
      Hamspot.Player.origin.resume();
    },
    playUri: async (uri, context = {}, options = {}) => {
      return await Hamspot.Player.origin.play({ uri: uri }, context, options);
    },
    removeEventListener: (type, callback) => {
      if (!(type in Hamspot.Player.eventListeners)) return;
      const stack = Hamspot.Player.eventListeners[type];
      for (let i = 0; i < stack.length; i++) {
        if (stack[i] === callback) {
          stack.splice(i, 1);
          return;
        }
      }
    },
    skipBack: (amount = 15e3) => {
      Hamspot.Player.origin.seekBackward(amount);
    },
    skipForward: (amount = 15e3) => {
      Hamspot.Player.origin.seekForward(amount);
    },
    setHeart: (b) => {
      const uris = [Hamspot.Player.origin._state.item.uri];
      if (b) {
        Hamspot.Platform.LibraryAPI.add({ uris });
      } else {
        Hamspot.Platform.LibraryAPI.remove({ uris });
      }
    },
    toggleHeart: () => {
      Hamspot.Player.setHeart(!Hamspot.Player.getHeart());
    },
  },
  test: () => {
    function checkObject(object) {
      const { objectToCheck, methods, name } = object;
      let count = methods.size;

      for (const method of methods) {
        if (objectToCheck[method] === undefined || objectToCheck[method] === null) {
          console.error(`${name}.${method} is not available. Please open an issue in the Hamspot repository to inform us about it.`);
          count--;
        }
      }
      console.log(`${count}/${methods.size} ${name} methods and objects are OK.`);

      for (const key of Object.keys(objectToCheck)) {
        if (!methods.has(key)) {
          console.warn(`${name} method ${key} exists but is not in the method list. Consider adding it.`);
        }
      }
    }

    const objectsToCheck = new Set([
      {
        objectToCheck: Hamspot,
        name: "Hamspot",
        methods: new Set([
          "Player",
          "addToQueue",
          "CosmosAsync",
          "getAudioData",
          "Keyboard",
          "URI",
          "LocalStorage",
          "Queue",
          "removeFromQueue",
          "showNotification",
          "Menu",
          "ContextMenu",
          "React",
          "Mousetrap",
          "Locale",
          "ReactDOM",
          "Topbar",
          "ReactComponent",
          "PopupModal",
          "SVGIcons",
          "colorExtractor",
          "test",
          "Platform",
          "_platform",
          "Config",
          "expFeatureOverride",
          "createInternalMap",
          "RemoteConfigResolver",
          "Playbar",
          "Tippy",
          "_getStyledClassName",
          "GraphQL",
          "ReactHook",
          "AppTitle",
          "_reservedPanelIds",
          "ReactFlipToolkit",
          "classnames",
          "ReactQuery",
          "Color",
          "extractColorPreset",
          "ReactDOMServer",
          "Snackbar",
          "ContextMenuV2",
          "ReactJSX",
          "_renderNavLinks",
          "Events",
        ]),
      },
      {
        objectToCheck: Hamspot.Player,
        name: "Hamspot.Player",
        methods: new Set([
          "addEventListener",
          "back",
          "data",
          "decreaseVolume",
          "dispatchEvent",
          "eventListeners",
          "formatTime",
          "getDuration",
          "getHeart",
          "getMute",
          "getProgress",
          "getProgressPercent",
          "getRepeat",
          "getShuffle",
          "getVolume",
          "increaseVolume",
          "isPlaying",
          "next",
          "pause",
          "play",
          "removeEventListener",
          "seek",
          "setMute",
          "setRepeat",
          "setShuffle",
          "setVolume",
          "skipBack",
          "skipForward",
          "toggleHeart",
          "toggleMute",
          "togglePlay",
          "toggleRepeat",
          "toggleShuffle",
          "origin",
          "playUri",
          "setHeart",
        ]),
      },
      {
        objectToCheck: Hamspot.ReactComponent,
        name: "Hamspot.ReactComponent",
        methods: new Set([
          "RightClickMenu",
          "ContextMenu",
          "Menu",
          "MenuItem",
          "AlbumMenu",
          "PodcastShowMenu",
          "ArtistMenu",
          "PlaylistMenu",
          "TrackMenu",
          "TooltipWrapper",
          "TextComponent",
          "IconComponent",
          "ConfirmDialog",
          "Slider",
          "RemoteConfigProvider",
          "ButtonPrimary",
          "ButtonSecondary",
          "ButtonTertiary",
          "Snackbar",
          "Chip",
          "Toggle",
          "Cards",
          "Router",
          "Routes",
          "Route",
          "StoreProvider",
          "PlatformProvider",
          "Dropdown",
          "MenuSubMenuItem",
          "Navigation",
          "ScrollableContainer",
        ]),
      },
      {
        objectToCheck: Hamspot.ReactComponent.Cards,
        name: "Hamspot.ReactComponent.Cards",
        methods: new Set([
          "Default",
          "Hero",
          "CardImage",
          "Album",
          "Artist",
          "Audiobook",
          "Episode",
          "Playlist",
          "Profile",
          "Show",
          "Track",
          "FeatureCard",
        ]),
      },
      {
        objectToCheck: Hamspot.ReactHook,
        name: "Hamspot.ReactHook",
        methods: new Set(["DragHandler", "useExtractedColor"]),
      },
    ]);

    for (const object of objectsToCheck) {
      checkObject(object);
    }
  },
  GraphQL: {
    Definitions: {},
  },
  ReactComponent: {},
  ReactHook: {},
  ReactFlipToolkit: {},
  Snackbar: {},
  Platform: {},
};
