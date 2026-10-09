#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Primary Desktop Rollback Script
# Location: ~/Projects/xfce-themes-note/rollback.sh
# ====================================================================
set -euo pipefail

BACKUP_BASE="${HOME}/.local/share/digital-garden-backups"

# Handle CLI options
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Digital Garden — Rollback Utility"
    echo "Usage:"
    echo "  bash ./rollback.sh                 # Restores the latest backup"
    echo "  bash ./rollback.sh <TIMESTAMP>     # Restores a specific backup directory"
    echo "  bash ./rollback.sh --list, -l      # Lists all available backups"
    exit 0
fi

if [ "${1:-}" = "--list" ] || [ "${1:-}" = "-l" ]; then
    echo "Available Digital Garden Backups in ${BACKUP_BASE}:"
    if [ -d "${BACKUP_BASE}" ]; then
        for b in "${BACKUP_BASE}"/*; do
            if [ -d "$b" ] && [ ! -L "$b" ] && [ -f "$b/manifest.json" ]; then
                echo "  • $(basename "$b") (created $(grep '"created_at"' "$b/manifest.json" | cut -d: -f2- | tr -d '", '))"
            fi
        done
        if [ -L "${BACKUP_BASE}/latest" ]; then
            echo ""
            echo "Current 'latest' symlink points to: $(basename "$(readlink -f "${BACKUP_BASE}/latest")")"
        fi
    else
        echo "No backup directory found."
    fi
    exit 0
fi

TARGET_DIR=""
if [ $# -ge 1 ]; then
    if [ -d "$1" ]; then
        TARGET_DIR="$1"
    elif [ -d "${BACKUP_BASE}/$1" ]; then
        TARGET_DIR="${BACKUP_BASE}/$1"
    else
        echo "Error: Specified backup '$1' was not found in ${BACKUP_BASE}"
        exit 1
    fi
else
    if [ -L "${BACKUP_BASE}/latest" ] || [ -d "${BACKUP_BASE}/latest" ]; then
        TARGET_DIR="$(readlink -f "${BACKUP_BASE}/latest")"
    else
        echo "Error: No latest backup found in ${BACKUP_BASE}."
        exit 1
    fi
fi

if [ ! -f "${TARGET_DIR}/manifest.json" ]; then
    echo "Error: manifest.json not found in ${TARGET_DIR}."
    exit 1
fi

echo "===================================================================="
echo " Digital Garden — Desktop Configuration Rollback"
echo "===================================================================="
echo "Target Backup Directory : ${TARGET_DIR}"
echo "===================================================================="

python3 -c "
import json
import subprocess
import os
import shutil

manifest_path = '${TARGET_DIR}/manifest.json'
with open(manifest_path, 'r') as f:
    manifest = json.load(f)

xfconf = manifest.get('xfconf', {})

print('Restoring xsettings properties...')
for prop, val in xfconf.get('xsettings', {}).items():
    if val:
        print(f'  • xsettings {prop} -> {val}')
        subprocess.run(['xfconf-query', '-c', 'xsettings', '-p', prop, '-s', val], check=False)

print('Restoring xfwm4 properties...')
for prop, val in xfconf.get('xfwm4', {}).items():
    if val:
        print(f'  • xfwm4 {prop} -> {val}')
        subprocess.run(['xfconf-query', '-c', 'xfwm4', '-p', prop, '-s', val], check=False)

print('Restoring desktop background properties...')
for prop, val in xfconf.get('xfce4-desktop', {}).items():
    if val:
        print(f'  • xfce4-desktop {prop} -> {val}')
        subprocess.run(['xfconf-query', '-c', 'xfce4-desktop', '-p', prop, '-s', val], check=False)

# Restore GTK 3 configuration files
backup_gtk3 = os.path.join('${TARGET_DIR}', 'config_gtk3')
if os.path.exists(os.path.join(backup_gtk3, 'settings.ini')):
    shutil.copy(os.path.join(backup_gtk3, 'settings.ini'), os.path.expanduser('~/.config/gtk-3.0/settings.ini'))
    print('  • Restored ~/.config/gtk-3.0/settings.ini')

if os.path.exists(os.path.join(backup_gtk3, 'gtk.css')):
    shutil.copy(os.path.join(backup_gtk3, 'gtk.css'), os.path.expanduser('~/.config/gtk-3.0/gtk.css'))
    print('  • Restored ~/.config/gtk-3.0/gtk.css')

# Restore GTK 4 configuration files
backup_gtk4 = os.path.join('${TARGET_DIR}', 'config_gtk4')
if os.path.exists(os.path.join(backup_gtk4, 'settings.ini')):
    shutil.copy(os.path.join(backup_gtk4, 'settings.ini'), os.path.expanduser('~/.config/gtk-4.0/settings.ini'))
    print('  • Restored ~/.config/gtk-4.0/settings.ini')

symlink_rec = os.path.join(backup_gtk4, 'gtk.css.symlink')
if os.path.exists(symlink_rec):
    with open(symlink_rec, 'r') as sf:
        target = sf.read().strip()
    gtk4_css = os.path.expanduser('~/.config/gtk-4.0/gtk.css')
    if os.path.islink(gtk4_css) or os.path.exists(gtk4_css):
        os.remove(gtk4_css)
    os.symlink(target, gtk4_css)
    print(f'  • Restored ~/.config/gtk-4.0/gtk.css symlink -> {target}')
elif os.path.exists(os.path.join(backup_gtk4, 'gtk.css')):
    shutil.copy(os.path.join(backup_gtk4, 'gtk.css'), os.path.expanduser('~/.config/gtk-4.0/gtk.css'))
    print('  • Restored ~/.config/gtk-4.0/gtk.css file')
"

echo ""
echo "===================================================================="
echo " ROLLBACK COMPLETED SUCCESSFULLY."
echo " Desktop settings have been restored to the recorded backup state."
echo "===================================================================="
