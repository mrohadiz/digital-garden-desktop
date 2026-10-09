#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Rollback Script
# Restores previous desktop settings and files from backup manifest
# ====================================================================
set -euo pipefail

BACKUP_BASE="${HOME}/.local/share/digital-garden-backups"

if [ $# -ge 1 ]; then
    TARGET_DIR="${BACKUP_BASE}/$1"
else
    if [ -L "${BACKUP_BASE}/latest" ] || [ -d "${BACKUP_BASE}/latest" ]; then
        TARGET_DIR="$(readlink -f "${BACKUP_BASE}/latest")"
    else
        echo "Error: No latest backup found in ${BACKUP_BASE}."
        exit 1
    fi
fi

if [ ! -f "${TARGET_DIR}/manifest.json" ]; then
    echo "Error: Backup manifest not found at ${TARGET_DIR}/manifest.json"
    exit 1
fi

echo "=== Rolling back to backup: ${TARGET_DIR} ==="

python3 -c "
import json
import subprocess
import os
import shutil

manifest_path = '${TARGET_DIR}/manifest.json'
with open(manifest_path, 'r') as f:
    manifest = json.load(f)

xfconf = manifest.get('xfconf', {})

# Restore xsettings
for prop, val in xfconf.get('xsettings', {}).items():
    if val:
        print(f'Restoring xsettings {prop} -> {val}')
        subprocess.run(['xfconf-query', '-c', 'xsettings', '-p', prop, '-s', val], check=False)

# Restore xfwm4
for prop, val in xfconf.get('xfwm4', {}).items():
    if val:
        print(f'Restoring xfwm4 {prop} -> {val}')
        subprocess.run(['xfconf-query', '-c', 'xfwm4', '-p', prop, '-s', val], check=False)

# Restore desktop background
for prop, val in xfconf.get('xfce4-desktop', {}).items():
    if val:
        print(f'Restoring xfce4-desktop {prop} -> {val}')
        # handle boolean vs string
        if val in ['true', 'false']:
            subprocess.run(['xfconf-query', '-c', 'xfce4-desktop', '-p', prop, '-s', val], check=False)
        else:
            subprocess.run(['xfconf-query', '-c', 'xfce4-desktop', '-p', prop, '-s', val], check=False)

# Restore GTK 3 files
backup_gtk3 = os.path.join('${TARGET_DIR}', 'config_gtk3')
if os.path.exists(os.path.join(backup_gtk3, 'settings.ini')):
    shutil.copy(os.path.join(backup_gtk3, 'settings.ini'), os.path.expanduser('~/.config/gtk-3.0/settings.ini'))
    print('Restored ~/.config/gtk-3.0/settings.ini')

if os.path.exists(os.path.join(backup_gtk3, 'gtk.css')):
    shutil.copy(os.path.join(backup_gtk3, 'gtk.css'), os.path.expanduser('~/.config/gtk-3.0/gtk.css'))
    print('Restored ~/.config/gtk-3.0/gtk.css')

# Restore GTK 4 files
backup_gtk4 = os.path.join('${TARGET_DIR}', 'config_gtk4')
if os.path.exists(os.path.join(backup_gtk4, 'settings.ini')):
    shutil.copy(os.path.join(backup_gtk4, 'settings.ini'), os.path.expanduser('~/.config/gtk-4.0/settings.ini'))
    print('Restored ~/.config/gtk-4.0/settings.ini')

symlink_rec = os.path.join(backup_gtk4, 'gtk.css.symlink')
if os.path.exists(symlink_rec):
    with open(symlink_rec, 'r') as sf:
        target = sf.read().strip()
    gtk4_css = os.path.expanduser('~/.config/gtk-4.0/gtk.css')
    if os.path.islink(gtk4_css) or os.path.exists(gtk4_css):
        os.remove(gtk4_css)
    os.symlink(target, gtk4_css)
    print(f'Restored ~/.config/gtk-4.0/gtk.css symlink -> {target}')
elif os.path.exists(os.path.join(backup_gtk4, 'gtk.css')):
    shutil.copy(os.path.join(backup_gtk4, 'gtk.css'), os.path.expanduser('~/.config/gtk-4.0/gtk.css'))
    print('Restored ~/.config/gtk-4.0/gtk.css file')
"

echo "=== Rollback Complete ==="
