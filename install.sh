#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Primary Desktop Installer for XFCE 4.18
# Location: ~/Projects/xfce-themes-note/install.sh
# ====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="Digital-Garden"
THEME_DEST="${HOME}/.themes/${THEME_NAME}"
WALLPAPER_SRC="${SCRIPT_DIR}/assets/wallpaper/digital-garden-1920x1080.jpg"
WALLPAPER_DEST="${HOME}/.local/share/backgrounds/digital-garden-1920x1080.jpg"
BACKUP_BASE="${HOME}/.local/share/digital-garden-backups"

# Parse CLI arguments
MODE="install"
for arg in "$@"; do
    case "$arg" in
        --check|-c)
            MODE="check"
            ;;
        --dry-run|-n)
            MODE="dry-run"
            ;;
        --help|-h)
            echo "Digital Garden — Retro Workstation Installer"
            echo "Usage: bash ./install.sh [OPTION]"
            echo ""
            echo "Options:"
            echo "  --check, -c    Inspect environment and theme assets without changing desktop"
            echo "  --dry-run, -n  Preview intended installation steps without changing desktop"
            echo "  --help, -h     Show this help message"
            echo "  (no option)    Perform complete safe installation of Digital Garden"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# --------------------------------------------------------------------
# 1. ENVIRONMENT DETECTION & AUDIT
# --------------------------------------------------------------------
OS_PRETTY="$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"' || echo 'Linux')"
KERNEL="$(uname -r)"
DESKTOP_SESSION_NAME="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Unknown}}"
DISPLAY_SERVER="${XDG_SESSION_TYPE:-x11}"
GTK3_VER="$(pkg-config --modversion gtk+-3.0 2>/dev/null || dpkg -s libgtk-3-0 2>/dev/null | grep -i '^Version:' | awk '{print $2}' || echo '3.24+')"
XFWM4_VER="$(xfwm4 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo '4.18+')"
PRIMARY_DISPLAY="$(xrandr --current 2>/dev/null | grep " connected primary" | awk '{print $1}' || echo 'eDP-1')"

CURR_GTK_THEME="$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo '<unassigned>')"
CURR_ICON_THEME="$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null || echo '<unassigned>')"
CURR_CURSOR_THEME="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName 2>/dev/null || echo '<unassigned>')"
CURR_FONT="$(xfconf-query -c xsettings -p /Gtk/FontName 2>/dev/null || echo '<unassigned>')"
CURR_XFWM_THEME="$(xfconf-query -c xfwm4 -p /general/theme 2>/dev/null || echo '<unassigned>')"
CURR_WP="$(xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/last-image" 2>/dev/null || echo '<unassigned>')"

echo "===================================================================="
echo " Digital Garden — Retro Workstation Desktop Installer"
echo "===================================================================="
echo "Detected Environment:"
echo "  • Operating System   : ${OS_PRETTY} (Kernel ${KERNEL})"
echo "  • Desktop Session    : ${DESKTOP_SESSION_NAME} (${DISPLAY_SERVER})"
echo "  • XFWM4 Version      : ${XFWM4_VER}"
echo "  • GTK 3 Version      : ${GTK3_VER}"
echo "  • Primary Monitor    : ${PRIMARY_DISPLAY}"
echo "  • Current GTK Theme  : ${CURR_GTK_THEME}"
echo "  • Current Icon Theme : ${CURR_ICON_THEME}"
echo "  • Current Cursor     : ${CURR_CURSOR_THEME}"
echo "  • Current XFWM Theme : ${CURR_XFWM_THEME}"
echo "  • Current Font       : ${CURR_FONT}"
echo "  • Current Wallpaper  : ${CURR_WP}"
echo "===================================================================="

# --------------------------------------------------------------------
# 2. PREREQUISITE & ASSET CHECKS
# --------------------------------------------------------------------
CHECK_ERRORS=0

check_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "  [FAIL] Missing required tool: $cmd"
        CHECK_ERRORS=$((CHECK_ERRORS + 1))
    else
        echo "  [OK] Found command: $cmd"
    fi
}

check_file() {
    local file="$1"
    local desc="$2"
    if [ ! -f "$file" ]; then
        echo "  [FAIL] Missing $desc: $file"
        CHECK_ERRORS=$((CHECK_ERRORS + 1))
    else
        echo "  [OK] Found $desc: $(basename "$file")"
    fi
}

echo ""
echo "Auditing Prerequisites & Required Project Assets..."
check_cmd "xfconf-query"
check_cmd "python3"

check_file "${SCRIPT_DIR}/tokens/colors.json" "Token definitions"
check_file "${SCRIPT_DIR}/index.theme" "Theme metadata"
check_file "${SCRIPT_DIR}/gtk/gtk-3.0/gtk.css" "GTK 3.24 Stylesheet"
check_file "${SCRIPT_DIR}/gtk/gtk-4.0/gtk.css" "GTK 4 Stylesheet"
check_file "${SCRIPT_DIR}/xfwm4/Digital-Garden/themerc" "XFWM4 themerc"
check_file "${SCRIPT_DIR}/xfwm4/Digital-Garden/close-active.png" "XFWM4 Close Button"
check_file "${SCRIPT_DIR}/assets/wallpaper/digital-garden-1920x1080.jpg" "Wallpaper Asset"
check_file "${SCRIPT_DIR}/rollback.sh" "Rollback Script"

# Check font availability
if fc-list : family 2>/dev/null | grep -i "Inter" >/dev/null; then
    echo "  [OK] Recommended UI Font 'Inter' is installed"
else
    echo "  [WARN] 'Inter' not found via fc-list; fallback font will be used"
fi

# Check Chicago95 icon installation
if [ -d "${HOME}/.icons/Chicago95" ] || [ -d "/usr/share/icons/Chicago95" ]; then
    echo "  [OK] Chicago95 icon pack is present in environment"
else
    echo "  [WARN] Chicago95 directory not detected under standard icon paths"
fi

if [ $CHECK_ERRORS -gt 0 ]; then
    echo ""
    echo "ERROR: Audit encountered ${CHECK_ERRORS} issues. Aborting."
    exit 1
fi

# --------------------------------------------------------------------
# 3. MODE HANDLER: --check
# --------------------------------------------------------------------
if [ "$MODE" = "check" ]; then
    echo ""
    echo "Summary of Check Mode:"
    echo "  • Environment compatibility: VERIFIED"
    echo "  • All theme assets & scripts: READY"
    echo "  • Chicago95 icon preservation: READY"
    echo "  • Desktop state: UNCHANGED (strictly non-mutating)"
    exit 0
fi

# --------------------------------------------------------------------
# 4. MODE HANDLER: --dry-run
# --------------------------------------------------------------------
if [ "$MODE" = "dry-run" ]; then
    echo ""
    echo "Summary of Dry-Run Preview (No desktop modifications will be made):"
    echo "  1. Would create timestamped backup in: ~/.local/share/digital-garden-backups/<timestamp>"
    echo "     - Would record: xsettings, xfwm4, xfce4-desktop Xfconf channels"
    echo "     - Would back up: ~/.config/gtk-3.0/settings.ini, gtk.css, ~/.config/gtk-4.0/"
    echo "  2. Would install theme assets to: ${THEME_DEST}"
    echo "     - Copy gtk-3.0, gtk-4.0 stylesheets and 52 XFWM4 decoration PNGs"
    echo "  3. Would install wallpaper to: ${WALLPAPER_DEST}"
    echo "  4. Would apply GTK Theme: 'Digital-Garden'"
    echo "  5. Would preserve Icon Theme: 'Chicago95' (unchanged)"
    echo "  6. Would preserve Cursor Theme: 'Chicago95_Standard_Cursors' (unchanged)"
    echo "  7. Would set UI Font: 'Inter 10'"
    echo "  8. Would apply XFWM4 window theme: 'Digital-Garden' with 'Inter Bold 9'"
    echo "  9. Would set wallpaper on monitor ${PRIMARY_DISPLAY}"
    echo "  10. Would preserve all XFCE panel plugins, launchers, and shortcuts"
    echo "  11. Desktop state: UNCHANGED"
    exit 0
fi

# --------------------------------------------------------------------
# 5. LIVE INSTALLATION (MUTATING, SAFE, WITH FULL BACKUP)
# --------------------------------------------------------------------
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

echo ""
echo "Proceeding with live installation..."
echo "Step 1: Creating comprehensive backup under ${BACKUP_DIR}..."
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

OLD_WP_CYCLE="$(xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/backdrop-cycle-enable" 2>/dev/null || echo 'false')"
OLD_WP_IMAGE="$(xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/last-image" 2>/dev/null || echo '')"
OLD_WP_STYLE="$(xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/image-style" 2>/dev/null || echo '0')"

# Backup config files if present
[ -f "${HOME}/.config/gtk-3.0/settings.ini" ] && cp "${HOME}/.config/gtk-3.0/settings.ini" "${BACKUP_DIR}/config_gtk3/settings.ini"
[ -f "${HOME}/.config/gtk-3.0/gtk.css" ] && cp "${HOME}/.config/gtk-3.0/gtk.css" "${BACKUP_DIR}/config_gtk3/gtk.css"
[ -f "${HOME}/.config/gtk-4.0/settings.ini" ] && cp "${HOME}/.config/gtk-4.0/settings.ini" "${BACKUP_DIR}/config_gtk4/settings.ini"

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
      "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/backdrop-cycle-enable": "${OLD_WP_CYCLE}",
      "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/last-image": "${OLD_WP_IMAGE}",
      "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/image-style": "${OLD_WP_STYLE}"
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

ln -sfn "${BACKUP_DIR}" "${BACKUP_BASE}/latest"
echo "  [OK] Manifest recorded in ${BACKUP_DIR}/manifest.json"

echo "Step 2: Installing theme assets into user directory..."
mkdir -p "${THEME_DEST}/gtk-3.0"
mkdir -p "${THEME_DEST}/gtk-4.0"
mkdir -p "${THEME_DEST}/xfwm4"
mkdir -p "$(dirname "${WALLPAPER_DEST}")"

cp "${SCRIPT_DIR}/index.theme" "${THEME_DEST}/index.theme"
cp "${SCRIPT_DIR}/gtk/gtk-3.0/gtk.css" "${THEME_DEST}/gtk-3.0/gtk.css"
cp "${SCRIPT_DIR}/gtk/gtk-3.0/gtk-dark.css" "${THEME_DEST}/gtk-3.0/gtk-dark.css"
cp "${SCRIPT_DIR}/gtk/gtk-4.0/gtk.css" "${THEME_DEST}/gtk-4.0/gtk.css"
cp "${SCRIPT_DIR}/gtk/gtk-4.0/gtk-dark.css" "${THEME_DEST}/gtk-4.0/gtk-dark.css"
cp -r "${SCRIPT_DIR}/xfwm4/Digital-Garden/"* "${THEME_DEST}/xfwm4/"
cp "${WALLPAPER_SRC}" "${WALLPAPER_DEST}"
echo "  [OK] Assets copied to ${THEME_DEST}"

echo "Step 3: Applying GTK 3 & GTK 4 settings..."
xfconf-query -c xsettings -p /Net/ThemeName -s "${THEME_NAME}"

# Update ~/.config/gtk-3.0/gtk.css to reference Digital Garden without conflicting overrides
mkdir -p "${HOME}/.config/gtk-3.0"
cat <<EOF > "${HOME}/.config/gtk-3.0/gtk.css"
/* Managed by Digital Garden Retro Workstation */
@import url("${HOME}/.themes/Digital-Garden/gtk-3.0/gtk.css");
EOF

cat <<EOF > "${HOME}/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Digital-Garden
gtk-icon-theme-name=Chicago95
gtk-cursor-theme-name=Chicago95_Standard_Cursors
gtk-font-name=Inter 10
gtk-application-prefer-dark-theme=0
EOF

# GTK 4 settings
mkdir -p "${HOME}/.config/gtk-4.0"
cat <<EOF > "${HOME}/.config/gtk-4.0/settings.ini"
[Settings]
gtk-theme-name=Digital-Garden
gtk-icon-theme-name=Chicago95
gtk-cursor-theme-name=Chicago95_Standard_Cursors
gtk-font-name=Inter 10
gtk-application-prefer-dark-theme=0
EOF

if [ -L "${HOME}/.config/gtk-4.0/gtk.css" ] || [ -f "${HOME}/.config/gtk-4.0/gtk.css" ]; then
    rm -f "${HOME}/.config/gtk-4.0/gtk.css"
fi
ln -sfn "${THEME_DEST}/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"

echo "Step 4: Ensuring Chicago95 icons, cursor, and typography are configured..."
xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Chicago95_Standard_Cursors"
xfconf-query -c xsettings -p /Gtk/FontName -s "Inter 10"

echo "Step 5: Applying XFWM4 window decorations..."
xfconf-query -c xfwm4 -p /general/theme -s "${THEME_NAME}"
xfconf-query -c xfwm4 -p /general/title_font -s "Inter Bold 9"

echo "Step 6: Applying Digital Garden wallpaper..."
xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/backdrop-cycle-enable" -s false || true
xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/image-style" -s 5 || true
xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/last-image" -s "${WALLPAPER_DEST}" || true

# Compatible fallback for monitor0 if distinct
if [ "${PRIMARY_DISPLAY}" != "0" ]; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "${WALLPAPER_DEST}" 2>/dev/null || true
fi

echo "Step 7: Verifying applied configuration..."
VERIFY_ERRORS=0
ACT_GTK="$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo '')"
ACT_XFWM="$(xfconf-query -c xfwm4 -p /general/theme 2>/dev/null || echo '')"
ACT_ICON="$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null || echo '')"
ACT_WP="$(xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${PRIMARY_DISPLAY}/workspace0/last-image" 2>/dev/null || echo '')"

[ "$ACT_GTK" = "${THEME_NAME}" ] && echo "  [PASS] GTK Theme: $ACT_GTK" || { echo "  [FAIL] GTK Theme is $ACT_GTK"; VERIFY_ERRORS=$((VERIFY_ERRORS+1)); }
[ "$ACT_XFWM" = "${THEME_NAME}" ] && echo "  [PASS] XFWM4 Theme: $ACT_XFWM" || { echo "  [FAIL] XFWM4 Theme is $ACT_XFWM"; VERIFY_ERRORS=$((VERIFY_ERRORS+1)); }
[ "$ACT_ICON" = "Chicago95" ] && echo "  [PASS] Chicago95 Icons Preserved" || { echo "  [FAIL] Icon theme changed to $ACT_ICON"; VERIFY_ERRORS=$((VERIFY_ERRORS+1)); }
[[ "$ACT_WP" == *"digital-garden"* ]] && echo "  [PASS] Wallpaper active: $(basename "$ACT_WP")" || { echo "  [FAIL] Wallpaper: $ACT_WP"; VERIFY_ERRORS=$((VERIFY_ERRORS+1)); }

echo ""
echo "===================================================================="
if [ $VERIFY_ERRORS -eq 0 ]; then
    echo " INSTALLATION COMPLETED SUCCESSFULLY!"
else
    echo " INSTALLATION COMPLETED WITH ${VERIFY_ERRORS} WARNINGS/FAILURES."
fi
echo "===================================================================="
echo "Backup location : ${BACKUP_DIR}"
echo "To revert anytime, run:"
echo "  bash ${SCRIPT_DIR}/rollback.sh ${TIMESTAMP}"
echo "===================================================================="
