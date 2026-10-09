# Digital Garden — Retro Workstation: Rollback Guide

## 1. Quick Revert to Previous Desktop State

To roll back all configuration changes made by the Digital Garden theme:

```bash
cd ~/Projects/xfce-themes-note
./scripts/rollback.sh
```

By default, `rollback.sh` reads the latest backup manifest from:
`~/.local/share/digital-garden-backups/latest/manifest.json`.

---

## 2. Revert to a Specific Timestamped Backup

If multiple changes were made, you can specify the target backup directory name:

```bash
./scripts/rollback.sh 20261009_082000
```

---

## 3. What the Rollback Script Restores

- **GTK Theme**: Restores the previous GTK theme (e.g. `WhiteSur-Light-solid-green`).
- **XFWM4 Theme**: Restores the previous window decoration theme (e.g. `WhiteSur-Dark`).
- **Icons & Cursors**: Restores previous icon and cursor settings.
- **Font & Monospace Font**: Restores previous font name and size.
- **Wallpaper & Background Cycle**: Restores previous wallpaper path and wallpaper cycling settings.
- **Configuration Files**: Restores previous `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-3.0/gtk.css`, and GTK 4 settings.
- **No Unrelated Files Modified**: Any user documents, panels, or unrelated files remain untouched.
