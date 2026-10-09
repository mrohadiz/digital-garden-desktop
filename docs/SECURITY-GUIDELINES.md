# Digital Garden — Security & Screenshot Privacy Guidelines

## 1. Background & Scope

During desktop theme development, capturing screenshots of live desktop environments can inadvertently expose sensitive information, including:
- Browser tabs, active sessions, and private URLs.
- Account identifiers, email addresses, and personal user data.
- API tokens, terminal sessions, and local configuration details.

This guide provides mandatory security rules, pre-commit checks, and pre-publication procedures for the **Digital Garden** project.

---

## 2. Core Privacy Principles

1. **Synthetic & Vector Previews First**:
   - Always prefer clean, programmatically generated vector previews (such as [`assets/previews/palette-preview.svg`](../assets/previews/palette-preview.svg)).
   - Vector previews do not capture private OS surfaces, window headers, or running browser sessions.
2. **Never Capture Full Desktop Screens**:
   - Full desktop captures (`xrandr` / full-screen grabs) inherently capture all visible workspaces, browser titlebars, and system trays.
   - Full-screen screenshots must **never** be copied into the repository.
3. **Automated Exclusion via `.gitignore`**:
   - All raster screenshot filenames (`*screenshot*`, `assets/previews/*.png`, `*.jpg`, `*.webp`, etc.) are excluded by default in [`.gitignore`](../.gitignore).
   - The vector preview `palette-preview.svg` and theme wallpaper `assets/wallpaper/digital-garden-1920x1080.jpg` are the only allowed visual assets.
4. **No External Secret Transmission**:
   - Do not upload local logs, screenshots, or backups to external public services or pastebins.

---

## 3. Pre-Publication Checklist

Before publishing, pushing, or creating any Git remote for this repository:

- [ ] **Step 1: Run the Local Security Scanner**
  ```bash
  ./scripts/security-check.sh --all
  ```
  Ensure the scanner exits with `0` errors.

- [ ] **Step 2: Verify Tracked File Inventory**
  ```bash
  git ls-files | grep -iE 'png|jpg|jpeg|webp|key|env|backup'
  ```
  Verify that only legitimate window decoration assets (`xfwm4/Digital-Garden/*.png`) and the wallpaper (`assets/wallpaper/*.jpg`) are listed.

- [ ] **Step 3: Verify Remote Status**
  ```bash
  git remote -v
  ```
  Confirm whether a remote exists and verify that no secrets or screenshots have ever been transmitted.

- [ ] **Step 4: Clean Dangling Git Objects (Optional Local Hygiene)**
  To clear unreferenced loose blobs from past index staging:
  ```bash
  git reflog expire --expire=now --all
  git gc --prune=now
  ```

---

## 4. Local Git Pre-Commit Hook (Optional)

To automatically run the security audit before every local commit:

```bash
# Enable the pre-commit hook in this repository
cat << 'EOF' > .git/hooks/pre-commit
#!/usr/bin/env bash
exec ./scripts/security-check.sh
EOF
chmod +x .git/hooks/pre-commit
```

---

## 5. Credential Revocation Protocol

If credentials or session tokens are suspected to have been captured on screen:
1. **Invalidate Sessions**: Log out of active sessions or trigger a password reset on affected services.
2. **Rotate Secrets**: Generate new API tokens or SSH keys if exposed.
3. **Remember**: Deleting a local screenshot file or committing a deletion does **not** revoke the underlying credential. Revocation at the service provider is always required.
