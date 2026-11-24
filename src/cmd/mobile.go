package cmd

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	spotify "github.com/spicetify/cli/src/status/spotify"
	"github.com/spicetify/cli/src/utils"
)

func RunMobileClient(address string, token string, action string) error {
	if address == "" {
		address = os.Getenv("SPICETIFY_MOBILE_URL")
	}
	if token == "" {
		token = os.Getenv("SPICETIFY_MOBILE_TOKEN")
	}
	if action == "" {
		action = "status"
	}

	address = strings.TrimRight(strings.TrimSpace(address), "/")
	if address == "" {
		return fmt.Errorf("desktop address is required")
	}
	if token == "" && action != "status" {
		return fmt.Errorf("access token is required")
	}

	client := &http.Client{Timeout: 30 * time.Second}

	if action == "status" {
		if token == "" {
			return fmt.Errorf("access token is required")
		}
		req, err := http.NewRequest(http.MethodGet, address+"/api/status", nil)
		if err != nil {
			return err
		}
		req.Header.Set("Authorization", "Bearer "+token)
		res, err := client.Do(req)
		if err != nil {
			return fmt.Errorf("connect to desktop: %w", err)
		}
		defer res.Body.Close()
		body, err := io.ReadAll(res.Body)
		if err != nil {
			return err
		}
		if res.StatusCode != http.StatusOK {
			return fmt.Errorf("desktop returned %s: %s", res.Status, strings.TrimSpace(string(body)))
		}
		fmt.Println(string(body))
		return nil
	}

	switch strings.ToLower(strings.TrimSpace(action)) {
	case "backup", "apply", "restore", "refresh":
	default:
		return fmt.Errorf("unknown action %q", action)
	}

	payload, err := json.Marshal(mobileAction{Name: action})
	if err != nil {
		return err
	}
	req, err := http.NewRequest(http.MethodPost, address+"/api/action", strings.NewReader(string(payload)))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")
	res, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("connect to desktop: %w", err)
	}
	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
		return err
	}
	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("desktop returned %s: %s", res.Status, strings.TrimSpace(string(body)))
	}
	fmt.Printf("Action %q completed.\n", action)
	return nil
}

type mobileAction struct {
	Name string `json:"name"`
}

type mobileStatus struct {
	SpicetifyVersion string `json:"spicetifyVersion"`
	SpotifyPath      string `json:"spotifyPath"`
	BackupPath       string `json:"backupPath"`
	State            string `json:"state"`
	MobileAddress    string `json:"mobileAddress"`
}

func StartMobileServer(version string, address string) error {
	if address == "" {
		address = os.Getenv("SPICETIFY_MOBILE_ADDRESS")
	}
	if address == "" {
		address = "127.0.0.1:27228"
	}

	token, err := randomMobileToken()
	if err != nil {
		return fmt.Errorf("create mobile access token: %w", err)
	}

	InitPaths()

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, mobilePage)
	})
	mux.HandleFunc("/manifest.json", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/manifest+json")
		fmt.Fprint(w, `{"name":"Spicetify Mobile","short_name":"Spicetify","start_url":"/","display":"standalone","background_color":"#121212","theme_color":"#1db954","icons":[]}`)
	})
	mux.HandleFunc("/api/status", func(w http.ResponseWriter, r *http.Request) {
		if !authorizeMobile(w, r, token) {
			return
		}
		spotifyPath := GetSpotifyPath()
		state := "unknown"
		if spotifyPath != "" {
			appsPath := filepath.Join(spotifyPath, "Apps")
			if _, err := os.Stat(appsPath); err == nil {
				switch {
				case spotify.Get(appsPath).IsApplied():
					state = "applied"
				case spotify.Get(appsPath).IsBackupable():
					state = "stock"
				case spotify.Get(appsPath).IsMixed():
					state = "mixed"
				case spotify.Get(appsPath).IsInvalid():
					state = "invalid"
				}
			}
		}

		writeMobileJSON(w, http.StatusOK, mobileStatus{
			SpicetifyVersion: version,
			SpotifyPath:      spotifyPath,
			BackupPath:       utils.GetStateFolder("Backup"),
			State:            state,
			MobileAddress:    address,
		})
	})
	mux.HandleFunc("/api/action", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.Header().Set("Allow", http.MethodPost)
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		if !authorizeMobile(w, r, token) {
			return
		}

		var action mobileAction
		if err := json.NewDecoder(r.Body).Decode(&action); err != nil {
			writeMobileJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid JSON"})
			return
		}

		switch strings.ToLower(strings.TrimSpace(action.Name)) {
		case "backup":
			Backup(version, true)
		case "apply":
			CheckStates()
			InitSetting()
			Apply(version)
			SpotifyRestart()
		case "restore":
			Restore()
			SpotifyRestart()
		case "refresh":
			CheckStates()
			InitSetting()
			RefreshTheme()
			SpotifyRestart()
		default:
			writeMobileJSON(w, http.StatusBadRequest, map[string]string{"error": "unknown action"})
			return
		}

		writeMobileJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	server := &http.Server{
		Addr:              address,
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
	}

	displayAddress, err := mobileDisplayAddress(address)
	if err != nil {
		return err
	}
	utils.PrintBold("Spicetify Mobile control")
	utils.PrintInfo("Open this address on Android or iPhone:")
	fmt.Printf("  http://%s/\n", displayAddress)
	utils.PrintInfo("Access token:")
	fmt.Printf("  %s\n", token)
	utils.PrintWarning("Use only on a trusted network. The server accepts authenticated control requests.")

	return server.ListenAndServe()
}

func randomMobileToken() (string, error) {
	b := make([]byte, 24)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func authorizeMobile(w http.ResponseWriter, r *http.Request, token string) bool {
	auth := r.Header.Get("Authorization")
	const prefix = "Bearer "
	if !strings.HasPrefix(auth, prefix) {
		writeMobileJSON(w, http.StatusUnauthorized, map[string]string{"error": "authentication required"})
		return false
	}

	provided := strings.TrimPrefix(auth, prefix)
	if subtle.ConstantTimeCompare([]byte(provided), []byte(token)) != 1 {
		writeMobileJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid token"})
		return false
	}
	return true
}

func writeMobileJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func mobileDisplayAddress(address string) (string, error) {
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return "", fmt.Errorf("invalid mobile address %q: %w", address, err)
	}

	if host == "" || host == "127.0.0.1" || host == "localhost" {
		return net.JoinHostPort("127.0.0.1", port), nil
	}
	if host == "0.0.0.0" || host == "::" {
		interfaces, err := net.Interfaces()
		if err == nil {
			for _, iface := range interfaces {
				addrs, err := iface.Addrs()
				if err != nil {
					continue
				}
				for _, addr := range addrs {
					ipNet, ok := addr.(*net.IPNet)
					if ok && ipNet.IP.To4() != nil && !ipNet.IP.IsLoopback() {
						return net.JoinHostPort(ipNet.IP.String(), port), nil
					}
				}
			}
		}
	}

	return net.JoinHostPort(host, port), nil
}

const mobilePage = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="theme-color" content="#1db954">
  <link rel="manifest" href="/manifest.json">
  <title>Spicetify Mobile</title>
  <style>
    :root { color-scheme: dark; font-family: system-ui, -apple-system, sans-serif; }
    body { margin: 0; background: #121212; color: #fff; }
    main { max-width: 520px; margin: 0 auto; padding: 24px 16px calc(24px + env(safe-area-inset-bottom)); }
    h1 { margin: 0 0 20px; color: #1db954; }
    .card { background: #202020; border-radius: 16px; padding: 16px; margin: 12px 0; }
    .row { display: flex; gap: 10px; align-items: center; }
    input { width: 100%; box-sizing: border-box; border: 1px solid #4a4a4a; border-radius: 10px; padding: 12px; background: #181818; color: #fff; font-size: 16px; }
    button { flex: 1; border: 0; border-radius: 999px; padding: 14px 10px; background: #1db954; color: #000; font-weight: 700; font-size: 15px; }
    button.secondary { background: #343434; color: #fff; }
    button:disabled { opacity: .55; }
    #actions { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    #status, #message { white-space: pre-wrap; overflow-wrap: anywhere; font-size: 14px; line-height: 1.45; }
  </style>
</head>
<body>
<main>
  <h1>Spicetify Mobile</h1>
  <div class="card">
    <label for="token">Access token</label>
    <div class="row" style="margin-top:8px">
      <input id="token" type="password" autocomplete="off" inputmode="text">
      <button id="connect" type="button" style="max-width:120px">Connect</button>
    </div>
  </div>
  <div class="card">
    <strong>Status</strong>
    <div id="status">Disconnected</div>
  </div>
  <div id="actions" class="card">
    <button data-action="backup">Backup</button>
    <button data-action="apply">Apply</button>
    <button data-action="restore" class="secondary">Restore</button>
    <button data-action="refresh" class="secondary">Refresh</button>
  </div>
  <div class="card"><div id="message"></div></div>
</main>
<script>
const tokenInput = document.querySelector("#token");
const statusEl = document.querySelector("#status");
const messageEl = document.querySelector("#message");
tokenInput.value = localStorage.getItem("spicetify-mobile-token") || "";

async function api(path, options = {}) {
  const token = tokenInput.value.trim();
  const response = await fetch(path, {
    ...options,
    headers: {
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json",
      ...(options.headers || {})
    }
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || ("HTTP " + response.status));
  return body;
}

async function refreshStatus() {
  try {
    const s = await api("/api/status");
    statusEl.textContent =
      "Version: " + s.spicetifyVersion +
      "\nState: " + s.state +
      "\nSpotify: " + s.spotifyPath +
      "\nBackup: " + s.backupPath;
  } catch (error) {
    statusEl.textContent = "Disconnected";
    throw error;
  }
}

document.querySelector("#connect").addEventListener("click", async () => {
  localStorage.setItem("spicetify-mobile-token", tokenInput.value.trim());
  messageEl.textContent = "";
  try {
    await refreshStatus();
    messageEl.textContent = "Connected.";
  } catch (error) {
    messageEl.textContent = error.message;
  }
});

document.querySelectorAll("[data-action]").forEach(button => {
  button.addEventListener("click", async () => {
    button.disabled = true;
    messageEl.textContent = "Running " + button.dataset.action + "...";
    try {
      await api("/api/action", {
        method: "POST",
        body: JSON.stringify({ name: button.dataset.action })
      });
      messageEl.textContent = "Done.";
      await refreshStatus();
    } catch (error) {
      messageEl.textContent = error.message;
    } finally {
      button.disabled = false;
    }
  });
});

if (tokenInput.value) refreshStatus().catch(() => {});
</script>
</body>
</html>`
