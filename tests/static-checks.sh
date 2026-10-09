#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Static Verification Test Suite
# ====================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "=== Running Static Checks in ${REPO_DIR} ==="
FAILURES=0

# 1. Check required directory structure
echo "[1/6] Checking directory layout..."
REQUIRED_DIRS=(
    "docs"
    "tokens"
    "gtk/gtk-3.0"
    "gtk/gtk-4.0"
    "xfwm4/Digital-Garden"
    "assets/wallpaper"
    "assets/previews"
    "scripts"
    "tests"
)

for d in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "${REPO_DIR}/${d}" ]; then
        echo "  [FAIL] Missing directory: ${d}"
        FAILURES=$((FAILURES + 1))
    else
        echo "  [OK] Directory exists: ${d}"
    fi
done

# 2. Check token definitions
echo "[2/6] Validating tokens/colors.json..."
if [ -f "${REPO_DIR}/tokens/colors.json" ]; then
    python3 -c "
import json
with open('${REPO_DIR}/tokens/colors.json') as f:
    d = json.load(f)
assert 'palette' in d, 'missing palette'
assert 'garden-accent' in d['palette'], 'missing garden-accent'
assert 'garden-bg' in d['palette'], 'missing garden-bg'
" && echo "  [OK] tokens/colors.json is valid JSON with required palette keys" || {
        echo "  [FAIL] Invalid tokens/colors.json"
        FAILURES=$((FAILURES + 1))
    }
else
    echo "  [FAIL] tokens/colors.json not found"
    FAILURES=$((FAILURES + 1))
fi

# 3. Check XFWM4 decoration assets
echo "[3/6] Validating XFWM4 assets..."
XFWM_DIR="${REPO_DIR}/xfwm4/Digital-Garden"
REQUIRED_XFWM_FILES=(
    "themerc"
    "title-1-active.png"
    "title-1-inactive.png"
    "top-left-active.png"
    "top-right-active.png"
    "bottom-active.png"
    "bottom-inactive.png"
    "left-active.png"
    "right-active.png"
    "close-active.png"
    "close-prelight.png"
    "close-pressed.png"
    "close-inactive.png"
    "hide-active.png"
    "maximize-active.png"
    "maximize-toggled-active.png"
)

for f in "${REQUIRED_XFWM_FILES[@]}"; do
    if [ ! -f "${XFWM_DIR}/${f}" ]; then
        echo "  [FAIL] Missing XFWM4 asset: ${f}"
        FAILURES=$((FAILURES + 1))
    fi
done
echo "  [OK] Required XFWM4 assets present"

# 4. Check GTK 3 CSS syntax using native Gtk.CssProvider
echo "[4/6] Validating GTK 3 CSS stylesheets via Gtk.CssProvider..."
python3 -c "
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
import sys

for p in ['${REPO_DIR}/gtk/gtk-3.0/gtk.css', '${REPO_DIR}/gtk/gtk-3.0/gtk-dark.css']:
    provider = Gtk.CssProvider()
    try:
        provider.load_from_path(p)
        print(f'  [OK] GTK 3 CSS Provider loaded cleanly: {p}')
    except Exception as e:
        print(f'  [FAIL] CSS error in {p}: {e}')
        sys.exit(1)
" || {
    echo "  [FAIL] GTK 3 CSS validation failed"
    FAILURES=$((FAILURES + 1))
}

# 5. Check wallpaper & preview assets
echo "[5/7] Validating wallpaper & preview assets..."
WP_FILE="${REPO_DIR}/assets/wallpaper/digital-garden-1920x1080.jpg"
PREV_FILE="${REPO_DIR}/assets/previews/preview.jpg"
if [ -f "${WP_FILE}" ] && [ -f "${PREV_FILE}" ]; then
    python3 -c "
from PIL import Image
im1 = Image.open('${WP_FILE}')
assert im1.size[0] >= 1280, f'width too small: {im1.size[0]}'
im2 = Image.open('${PREV_FILE}')
assert im2.size[0] >= 800, f'preview width too small: {im2.size[0]}'
print(f'  [OK] Wallpaper valid image: {im1.size}, Preview valid image: {im2.size}')
" || {
        echo "  [FAIL] Invalid image files"
        FAILURES=$((FAILURES + 1))
    }
else
    echo "  [FAIL] Missing wallpaper or preview asset"
    FAILURES=$((FAILURES + 1))
fi

# 6. Check shell scripts syntax (bash -n)
echo "[6/7] Checking shell script syntax..."
for s in "${REPO_DIR}"/*.sh "${REPO_DIR}"/scripts/*.sh "${REPO_DIR}"/tests/*.sh; do
    if [ -f "$s" ]; then
        bash -n "$s" && echo "  [OK] bash -n passed: $(basename "$s")" || {
            echo "  [FAIL] Syntax error in $s"
            FAILURES=$((FAILURES + 1))
        }
    fi
done

# 7. Check security & secret scanning
echo "[7/7] Running secret & screenshot privacy checks..."
"${REPO_DIR}/scripts/security-check.sh" --all || {
    echo "  [FAIL] Security audit failed"
    FAILURES=$((FAILURES + 1))
}

echo "=== Static Checks Complete ==="
if [ $FAILURES -eq 0 ]; then
    echo "ALL STATIC CHECKS PASSED SUCCESSFULLY."
    exit 0
else
    echo "STATIC CHECKS FAILED WITH ${FAILURES} ERRORS."
    exit 1
fi
