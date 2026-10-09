#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Installation Script
# Installs theme assets into ~/.themes/Digital-Garden
# ====================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DEST="${HOME}/.themes/Digital-Garden"
WALLPAPER_DEST="${HOME}/.local/share/backgrounds/digital-garden-1920x1080.jpg"

echo "=== Installing Digital Garden Theme ==="

# 1. Ensure assets are up-to-date
echo "[1/4] Generating decoration assets from color tokens..."
python3 "${REPO_DIR}/scripts/generate_assets.py"

# 2. Create destination directories
echo "[2/4] Preparing user theme directories..."
mkdir -p "${THEME_DEST}/gtk-3.0"
mkdir -p "${THEME_DEST}/gtk-4.0"
mkdir -p "${THEME_DEST}/xfwm4"
mkdir -p "$(dirname "${WALLPAPER_DEST}")"

# 3. Copy theme files
echo "[3/4] Copying GTK & XFWM4 theme files..."
cp "${REPO_DIR}/index.theme" "${THEME_DEST}/index.theme"
cp "${REPO_DIR}/gtk/gtk-3.0/gtk.css" "${THEME_DEST}/gtk-3.0/gtk.css"
cp "${REPO_DIR}/gtk/gtk-3.0/gtk-dark.css" "${THEME_DEST}/gtk-3.0/gtk-dark.css"
cp "${REPO_DIR}/gtk/gtk-4.0/gtk.css" "${THEME_DEST}/gtk-4.0/gtk.css"
cp "${REPO_DIR}/gtk/gtk-4.0/gtk-dark.css" "${THEME_DEST}/gtk-4.0/gtk-dark.css"

cp -r "${REPO_DIR}/xfwm4/Digital-Garden/"* "${THEME_DEST}/xfwm4/"

# 4. Copy wallpaper asset
echo "[4/4] Installing wallpaper asset..."
cp "${REPO_DIR}/assets/wallpaper/digital-garden-1920x1080.jpg" "${WALLPAPER_DEST}"

echo "Theme successfully installed to ${THEME_DEST}"
echo "Wallpaper installed to ${WALLPAPER_DEST}"
