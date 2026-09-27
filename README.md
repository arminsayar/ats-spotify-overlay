# 🎵 ATS/ETS2 Spotify Overlay

In-game Spotify **radio-style overlay** for **American Truck Simulator** and **Euro Truck Simulator 2**.
Shows the current track with cover art and a live progress bar right on the game screen — works with
**free Spotify accounts** (no Premium needed).

Made by **Armin Sayar**

---

## ✨ Features

- 🖼 Radio-style in-game card: **cover art + track/artist + progress bar** (bottom-center, like the game radio)
- 🎨 Cover art is fetched automatically from the free iTunes Search API and cached locally
- ⌨️ **Hotkeys** while driving (see below)
- 📱 Web player: full mouse control from any browser or your phone
- 🎮 Wheel/joystick button support
- 🔌 Works with **Spotify Free** (Windows media session) and **Premium** (optional Web API mode)
- 👁 `Del` instantly shows/hides the overlay card

---

## 🚀 Fast setup (3 steps)

### 1. Run the app
Double-click **`ATS Spotify Overlay.exe`** → accept the **UAC prompt**
(required for reading game telemetry and drawing the overlay).

### 2. Install the game plugin
Click **"Install plugin for American Truck Simulator"** (or ETS2) and pick your game folder, e.g.:
```
C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator
```
This copies one DLL into the game's `bin\win_x64\plugins\` folder. Done once, ever.

### 3. Play music + drive
Play music in the **Spotify desktop app** (or browser) and start ATS/ETS2.
The card appears at the bottom-center while driving and hides in menus. That's it! 🚛

> **Optional (Premium users):** click *Connect to Spotify* and paste a Client ID/Secret from
> [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard) (Redirect URI:
> `http://127.0.0.1:4002/auth`). This adds seek-by-click, shuffle/repeat and favourites.
> Not required — free accounts get everything above via the Windows media session.

---

## ⌨️ Hotkeys (in game)

| Key | Action |
|---|---|
| **PgUp** | ⏭ Next song |
| **PgDn** | ⏮ Previous song |
| **End** | ▶ / ⏸ Play–pause |
| **Home** | 🔊 Volume up |
| **Ins** | 🔉 Volume down |
| **Del** | 👁 Show / hide overlay card |

The keys are also printed on the overlay card so you never forget them.
Wheel/joystick buttons can be assigned in `settings.json` → `"buttons"`.

---

## 📱 Web player (mouse control)

Open **http://localhost:8330** on your PC, or `http://<your-pc-ip>:8330` from your phone
(same Wi-Fi) for a full Spotify-style player with play/pause, next/prev and volume.

---

## 🛠 Troubleshooting

| Problem | Fix |
|---|---|
| Card never appears | Install the plugin (step 2), restart the game; drive a bit — it hides in menus |
| No track shown | Make sure something is **playing** in Spotify on this PC |
| Play/pause does nothing | Some Spotify versions block external media keys — use the web player then |
| Port 8330 busy | Change `"port"` in `settings.json` |
| SmartScreen warning | *More info → Run anyway* (unsigned open-source app) |

## 📦 Folder contents

| File | Purpose |
|---|---|
| `ATS Spotify Overlay.exe` | The app — run this |
| `media_bridge.ps1` | Reads the Windows media session (required) |
| `web\` | Web player files (required) |
| `plugins\` | Game plugin DLL used by the install button |
| `covers\`, `*.json`, `Error log.txt` | Created at runtime |

## 📜 Credits

Based on the open-source [ets2-spotify-overlay](https://github.com/MBCustoms/ets2-spotify-overlay)
(MBCustoms, RenCloud's SCSSDK client, Koenvh1's ETS2 Local Radio). Rebuilt & extended by **Armin Sayar**.
