# Digital Garden — Retro Workstation: Compatibility & Boundaries

## 1. Supported Environments

| Component | Target Version | Status | Notes |
|---|---|---|---|
| **Operating System** | elementary OS 8.1 (Noble base) | Supported | Fully compatible |
| **Desktop Environment** | XFCE 4.18 | Supported | Primary target |
| **Window Manager** | XFWM4 4.18 | Supported | Native 24-bit PNG assets + themerc |
| **GTK 3** | GTK 3.24.41 | Supported | Native CSS with Inter & paper palette |
| **GTK 4** | GTK 4.14 | Supported Subset | Uses GTK 4 / Libadwaita color tokens; portal apps may override |
| **Icons** | Chicago95 | Supported | Explicitly retained |
| **Display Server** | X11 | Supported | Tested on ThinkPad T490 1920x1080 |

---

## 2. Technical Boundaries & Nuances

### GTK 3 vs GTK 4
- **GTK 3**: Fully controlled via theme CSS (`~/.themes/Digital-Garden/gtk-3.0/gtk.css`) and user-level `~/.config/gtk-3.0/gtk.css`.
- **GTK 4 / Libadwaita**: GTK 4 applications that link against `libadwaita` enforce their own internal styling stylesheets unless overridden by specific color variables or `~/.config/gtk-4.0/gtk.css`. Digital Garden provides the supported subset of `@define-color` definitions for GTK 4 without blindly re-using GTK 3 CSS selectors.

### XFCE Panel Plugins
- The panel structure, plugin list, Whisker Menu "Start" button, pulseaudio applet, systray, and launchers are preserved entirely.
- GTK 3 styling targets `.xfce4-panel` and `#XfcePanelWindow` cleanly without modifying plugin configuration files.

### Wallpaper Cycle
- The user's system previously had `backdrop-cycle-enable: true` configured on `monitoreDP-1`. Applying the Digital Garden wallpaper temporarily sets this to `false` so the curated wallpaper remains persistent. The rollback script automatically restores `backdrop-cycle-enable: true` and the previous image path.
