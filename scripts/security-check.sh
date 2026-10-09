#!/usr/bin/env bash
# ====================================================================
# Digital Garden — Retro Workstation
# Security & Secret Scanning Utility
# Inspects staged and tracked files for private keys, credentials,
# and unintended screenshot artifacts without leaking secret values.
# ====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CHECK_ALL=false
if [ "${1:-}" = "--all" ]; then
    CHECK_ALL=true
fi

echo "=== Running Security & Privacy Audit in ${REPO_DIR} ==="
ISSUES=0

# Determine target files: either staged files or all git-tracked files
if [ "$CHECK_ALL" = true ]; then
    echo "Mode: Auditing ALL tracked files..."
    FILES="$(git -C "${REPO_DIR}" ls-files)"
else
    echo "Mode: Auditing STAGED files..."
    FILES="$(git -C "${REPO_DIR}" diff --cached --name-only 2>/dev/null || true)"
    if [ -z "${FILES}" ]; then
        echo "No staged files found. Auditing HEAD working tree tracked files..."
        FILES="$(git -C "${REPO_DIR}" ls-files)"
    fi
fi

# 1. Check for unauthorized screenshot / capture files
echo "[1/3] Scanning for raster screenshot & capture artifacts..."
while IFS= read -r file; do
    [ -z "$file" ] && continue
    # Skip legitimate wallpaper, window frames, and authorized preview assets
    if [[ "$file" =~ ^assets/wallpaper/ ]] || [[ "$file" =~ ^xfwm4/Digital-Garden/.*\.png$ ]] || [ "$file" = "assets/previews/palette-preview.svg" ] || [ "$file" = "assets/previews/preview.jpg" ]; then
        continue
    fi

    # Check for screenshot indicators in filename
    if [[ "$file" =~ (screenshot|screen_capture|desktop_preview|\.png$|\.jpg$|\.webp$) ]]; then
        echo "  [ALERT] Unauthorized raster image/screenshot detected: ${file}"
        ISSUES=$((ISSUES + 1))
    fi
done <<< "${FILES}"

# 2. Check for backup & sensitive archive files
echo "[2/3] Scanning for backup files and private key extensions..."
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if [[ "$file" =~ (\.bak$|\.backup$|\.key$|\.pem$|\.env$|credentials\.json$) ]]; then
        echo "  [ALERT] Potentially sensitive configuration/backup detected: ${file}"
        ISSUES=$((ISSUES + 1))
    fi
done <<< "${FILES}"

# 3. High-confidence regex secret scanner (Python-driven, zero secret value leakage)
echo "[3/3] Inspecting file contents for credential patterns..."
PYTHON_ISSUES="$(python3 -c "
import os
import re
import sys

repo_dir = '''${REPO_DIR}'''
file_list = [f.strip() for f in '''${FILES}'''.splitlines() if f.strip()]

PATTERNS = [
    ('Private Key Header', re.compile(r'-----BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY-----')),
    ('GitHub Personal Access Token', re.compile(r'gh[pousr]_[A-Za-z0-9_]{36,}')),
    ('AWS Access Key ID', re.compile(r'(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}')),
    ('Google API Key', re.compile(r'AIza[0-9A-Za-z-_]{35}')),
    ('Slack API Token', re.compile(r'xox[baprs]-[0-9a-zA-Z]{10,48}')),
    ('Generic Secret Assignment', re.compile(r'(?i)(api[_-]?key|secret[_-]?key|auth[_-]?token)\s*[:=]\s*[\'\"][A-Za-z0-9_/\+=]{20,}[\'\"]'))
]

findings = 0
for rel_path in file_list:
    full_path = os.path.join(repo_dir, rel_path)
    if not os.path.isfile(full_path):
        continue
    if rel_path.endswith(('.png', '.jpg', '.jpeg', '.webp', '.ico', '.svg')):
        continue
    if rel_path == 'scripts/security-check.sh':
        continue

    try:
        with open(full_path, 'r', encoding='utf-8', errors='ignore') as fp:
            for line_no, line in enumerate(fp, start=1):
                for label, pat in PATTERNS:
                    if pat.search(line):
                        print(f'  [ALERT] Potential {label} matched in: {rel_path}:{line_no}')
                        findings += 1
    except Exception:
        pass

print(findings)
" | tr -d ' ')"

COUNT="$(echo "${PYTHON_ISSUES}" | tail -n1)"
ALERTS="$(echo "${PYTHON_ISSUES}" | sed '$d')"
if [ -n "${ALERTS}" ]; then
    echo "${ALERTS}"
fi

ISSUES=$((ISSUES + COUNT))

echo ""
echo "=== Security Audit Result ==="
if [ $ISSUES -eq 0 ]; then
    echo "  [PASS] Zero sensitive artifacts or credentials detected."
    exit 0
else
    echo "  [FAIL] Detected ${ISSUES} security concern(s). Please review before publishing."
    echo "  Note: Secret scanners can produce false positives and cannot guarantee 100% detection."
    exit 1
fi
