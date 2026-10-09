# Digital Garden — Retro Workstation: Installation Guide

## 1. Quick Installation & Application

To install and immediately apply the Digital Garden desktop theme:

```bash
cd ~/Projects/xfce-themes-note

# 1. Run static checks
./tests/static-checks.sh

# 2. Install theme files to ~/.themes/Digital-Garden
./scripts/install.sh

# 3. Apply theme, wallpaper, and typography safely
./scripts/apply.sh
```

---

## 2. What `apply.sh` Does Safely

1. **Creates an automated backup** in `~/.local/share/digital-garden-backups/<timestamp>/`:
   - Records previous Xfconf settings for `xsettings`, `xfwm4`, and `xfce4-desktop`.
   - Backs up configuration files (`~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-3.0/gtk.css`, `~/.config/gtk-4.0/settings.ini`, etc.).
2. **Applies GTK Theme**: Sets `Digital-Garden` in Xfconf and user configuration.
3. **Preserves Icons**: Keeps `Chicago95` icons and `Chicago95_Standard_Cursors` active.
4. **Applies XFWM4 Decorations**: Activates `Digital-Garden` window frame.
5. **Sets Typography**: Activates `Inter 10` for GTK UI and `Inter Bold 9` for window titles.
6. **Applies Wallpaper**: Configures `digital-garden-1920x1080.jpg` on the primary monitor.
7. **Preserves Panels**: Does not touch panel plugins, launchers, or shortcuts.

---

## 3. Post-Installation Verification

Run the verification script:

```bash
./scripts/verify.sh
```
