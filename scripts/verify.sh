#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Live Environment Verification Script
# ====================================================================
set -euo pipefail

echo "=== Verifying Live Desktop Configuration ==="
ERRORS=0

check_val() {
    local desc="$1"
    local channel="$2"
    local prop="$3"
    local expected="$4"
    local actual
    actual="$(xfconf-query -c "${channel}" -p "${prop}" 2>/dev/null || echo '<NOT SET>')"
    if [ "${actual}" = "${expected}" ]; then
        echo "  [PASS] ${desc}: ${actual}"
    else
        echo "  [FAIL] ${desc}: Expected '${expected}', got '${actual}'"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "[1/5] Checking GTK and Window Manager Themes..."
check_val "GTK Theme" "xsettings" "/Net/ThemeName" "Digital-Garden"
check_val "XFWM4 Window Theme" "xfwm4" "/general/theme" "Digital-Garden"

echo "[2/5] Checking Chicago95 Preservation..."
check_val "Icon Theme" "xsettings" "/Net/IconThemeName" "Chicago95"
check_val "Cursor Theme" "xsettings" "/Gtk/CursorThemeName" "Chicago95_Standard_Cursors"

echo "[3/5] Checking Font Configuration..."
check_val "GTK Font" "xsettings" "/Gtk/FontName" "Inter 10"

echo "[4/5] Checking Wallpaper Configuration..."
WP_ACTUAL="$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image 2>/dev/null || echo '')"
if [[ "${WP_ACTUAL}" == *"digital-garden"* ]]; then
    echo "  [PASS] Wallpaper on eDP-1: ${WP_ACTUAL}"
else
    echo "  [WARN] Wallpaper on eDP-1 is: ${WP_ACTUAL}"
fi

echo "[5/5] Checking Panel Plugins & Order Preservation..."
PANEL_VER="$(xfconf-query -c xfce4-panel -p /configver 2>/dev/null || echo '')"
PANEL_COUNT="$(xfconf-query -c xfce4-panel -p /panels 2>/dev/null || echo '')"
WHISKER="$(xfconf-query -c xfce4-panel -p /plugins/plugin-7/button-title 2>/dev/null || echo '')"
if [ -n "${PANEL_VER}" ] && [ "${WHISKER}" = "Start" ]; then
    echo "  [PASS] XFCE Panel structure intact (Whisker Menu 'Start' plugin-7 active, panels=${PANEL_COUNT})"
else
    echo "  [WARN] Panel properties differ: panels=${PANEL_COUNT}"
fi

echo "=== Verification Result ==="
if [ $ERRORS -eq 0 ]; then
    echo "ALL THEME VERIFICATION CHECKS PASSED!"
    exit 0
else
    echo "VERIFICATION DETECTED ${ERRORS} MISMATCHES."
    exit 1
fi
