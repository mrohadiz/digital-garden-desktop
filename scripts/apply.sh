#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Apply Script
# Safely backs up existing configuration and applies Digital Garden theme
# ====================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_BASE="${HOME}/.local/share/digital-garden-backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"
WALLPAPER_SRC="${HOME}/.local/share/backgrounds/digital-garden-1920x1080.jpg"

if [ ! -f "${WALLPAPER_SRC}" ]; then
    WALLPAPER_SRC="${REPO_DIR}/assets/wallpaper/digital-garden-1920x1080.jpg"
fi

echo "=== Applying Digital Garden — Retro Workstation ==="

# --------------------------------------------------------------------
# STEP 1: CREATE TIMESTAMPED BACKUP
# --------------------------------------------------------------------
echo "[1/6] Creating backup in ${BACKUP_DIR}..."
mkdir -p "${BACKUP_DIR}/config_gtk3"
mkdir -p "${BACKUP_DIR}/config_gtk4"

# Query existing xfconf values
OLD_GTK_THEME="$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo '')"
OLD_ICON_THEME="$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null || echo '')"
OLD_CURSOR_THEME="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName 2>/dev/null || echo '')"
OLD_FONT="$(xfconf-query -c xsettings -p /Gtk/FontName 2>/dev/null || echo '')"
OLD_MONO_FONT="$(xfconf-query -c xsettings -p /Gtk/MonospaceFontName 2>/dev/null || echo '')"

OLD_XFWM4_THEME="$(xfconf-query -c xfwm4 -p /general/theme 2>/dev/null || echo '')"
OLD_XFWM4_TITLE_FONT="$(xfconf-query -c xfwm4 -p /general/title_font 2>/dev/null || echo '')"

OLD_WP_CYCLE="$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/backdrop-cycle-enable 2>/dev/null || echo 'false')"
OLD_WP_IMAGE="$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image 2>/dev/null || echo '')"
OLD_WP_STYLE="$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/image-style 2>/dev/null || echo '0')"

# Backup config files if they exist
[ -f "${HOME}/.config/gtk-3.0/settings.ini" ] && cp "${HOME}/.config/gtk-3.0/settings.ini" "${BACKUP_DIR}/config_gtk3/settings.ini"
[ -f "${HOME}/.config/gtk-3.0/gtk.css" ] && cp "${HOME}/.config/gtk-3.0/gtk.css" "${BACKUP_DIR}/config_gtk3/gtk.css"
[ -f "${HOME}/.config/gtk-4.0/settings.ini" ] && cp "${HOME}/.config/gtk-4.0/settings.ini" "${BACKUP_DIR}/config_gtk4/settings.ini"

# Record GTK 4 gtk.css (file or symlink)
if [ -L "${HOME}/.config/gtk-4.0/gtk.css" ]; then
    readlink "${HOME}/.config/gtk-4.0/gtk.css" > "${BACKUP_DIR}/config_gtk4/gtk.css.symlink"
elif [ -f "${HOME}/.config/gtk-4.0/gtk.css" ]; then
    cp "${HOME}/.config/gtk-4.0/gtk.css" "${BACKUP_DIR}/config_gtk4/gtk.css"
fi

# Write manifest JSON
cat <<EOF > "${BACKUP_DIR}/manifest.json"
{
  "timestamp": "${TIMESTAMP}",
  "created_at": "$(date -Iseconds)",
  "xfconf": {
    "xsettings": {
      "/Net/ThemeName": "${OLD_GTK_THEME}",
      "/Net/IconThemeName": "${OLD_ICON_THEME}",
      "/Gtk/CursorThemeName": "${OLD_CURSOR_THEME}",
      "/Gtk/FontName": "${OLD_FONT}",
      "/Gtk/MonospaceFontName": "${OLD_MONO_FONT}"
    },
    "xfwm4": {
      "/general/theme": "${OLD_XFWM4_THEME}",
      "/general/title_font": "${OLD_XFWM4_TITLE_FONT}"
    },
    "xfce4-desktop": {
      "/backdrop/screen0/monitoreDP-1/workspace0/backdrop-cycle-enable": "${OLD_WP_CYCLE}",
      "/backdrop/screen0/monitoreDP-1/workspace0/last-image": "${OLD_WP_IMAGE}",
      "/backdrop/screen0/monitoreDP-1/workspace0/image-style": "${OLD_WP_STYLE}"
    }
  },
  "files_backed_up": [
    "~/.config/gtk-3.0/settings.ini",
    "~/.config/gtk-3.0/gtk.css",
    "~/.config/gtk-4.0/settings.ini",
    "~/.config/gtk-4.0/gtk.css"
  ]
}
EOF

# Update symlink to latest backup
ln -sfn "${BACKUP_DIR}" "${BACKUP_BASE}/latest"
echo "  [OK] Backup manifest written to ${BACKUP_DIR}/manifest.json"

# --------------------------------------------------------------------
# STEP 2: INSTALL THEME ASSETS
# --------------------------------------------------------------------
echo "[2/6] Ensuring theme files are installed..."
"${REPO_DIR}/scripts/install.sh"

# --------------------------------------------------------------------
# STEP 3: APPLY GTK 3 & GTK 4 SETTINGS
# --------------------------------------------------------------------
echo "[3/6] Applying GTK Theme (Digital-Garden)..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Digital-Garden"

# Neutralize conflicting user-level neon override in ~/.config/gtk-3.0/gtk.css
# Keep user informed and backed up
if [ -f "${HOME}/.config/gtk-3.0/gtk.css" ]; then
    # Point user override to theme import or keep clean
    cat <<EOF > "${HOME}/.config/gtk-3.0/gtk.css"
/* Managed by Digital Garden Retro Workstation */
@import url("${HOME}/.themes/Digital-Garden/gtk-3.0/gtk.css");
EOF
fi

# Update settings.ini for GTK 3 & 4
mkdir -p "${HOME}/.config/gtk-3.0"
cat <<EOF > "${HOME}/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Digital-Garden
gtk-icon-theme-name=Chicago95
gtk-cursor-theme-name=Chicago95_Standard_Cursors
gtk-font-name=Inter 10
gtk-application-prefer-dark-theme=0
EOF

mkdir -p "${HOME}/.config/gtk-4.0"
cat <<EOF > "${HOME}/.config/gtk-4.0/settings.ini"
[Settings]
gtk-theme-name=Digital-Garden
gtk-icon-theme-name=Chicago95
gtk-cursor-theme-name=Chicago95_Standard_Cursors
gtk-font-name=Inter 10
gtk-application-prefer-dark-theme=0
EOF

# GTK 4 user-level stylesheet: point to Digital Garden GTK 4 CSS
if [ -L "${HOME}/.config/gtk-4.0/gtk.css" ] || [ -f "${HOME}/.config/gtk-4.0/gtk.css" ]; then
    rm -f "${HOME}/.config/gtk-4.0/gtk.css"
fi
ln -sfn "${HOME}/.themes/Digital-Garden/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"

# --------------------------------------------------------------------
# STEP 4: PRESERVE CHICAGO95 & SET INTER FONT
# --------------------------------------------------------------------
echo "[4/6] Preserving Chicago95 icons & configuring Inter font..."
xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Chicago95_Standard_Cursors"
xfconf-query -c xsettings -p /Gtk/FontName -s "Inter 10"

# --------------------------------------------------------------------
# STEP 5: APPLY XFWM4 THEME & TITLE FONT
# --------------------------------------------------------------------
echo "[5/6] Applying XFWM4 window decorations (Digital-Garden)..."
xfconf-query -c xfwm4 -p /general/theme -s "Digital-Garden"
xfconf-query -c xfwm4 -p /general/title_font -s "Inter Bold 9"

# --------------------------------------------------------------------
# STEP 6: APPLY WALLPAPER SAFELY
# --------------------------------------------------------------------
echo "[6/6] Applying Digital Garden wallpaper..."
# Disable cyclic wallpaper change on eDP-1 workspace 0 so our wallpaper is persistent
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/backdrop-cycle-enable -s false || true
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/image-style -s 5 || true
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image -s "${WALLPAPER_SRC}" || true

# Also update monitor0 workspace0 for compatibility
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "${WALLPAPER_SRC}" 2>/dev/null || true

echo "=== Digital Garden Theme Applied Successfully ==="
echo "Backup saved in: ${BACKUP_DIR}"
echo "To revert changes at any time, run: ./scripts/rollback.sh ${TIMESTAMP}"
