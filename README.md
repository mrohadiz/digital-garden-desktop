# Digital Garden Desktop

**A modernized retro Linux workstation theme built around the Digital Garden visual language.**

Digital Garden Desktop brings a warm, paper-inspired design system to the Linux desktop while preserving the familiar character of a retro workstation. The project is designed for customization: the GTK theme, window decorations, wallpaper, and desktop styling can evolve independently, while **Chicago95 remains the preferred icon theme**.

> **Status:** Early development. The repository is being initialized; theme assets and installer behavior may not yet be complete. Check the implementation and compatibility notes before applying changes to a live desktop.

## Design direction

Digital Garden combines retro-computing familiarity with a modern, readable interface:

- Warm paper-inspired surfaces and restrained borders.
- Steel-blue accents and muted sage-green status colors.
- Clear typography and recognizable window controls.
- A classic workstation feel without reproducing Windows 95 or macOS wholesale.
- A customizable desktop rather than a one-size-fits-all configuration.

### Color palette

| Token | Value | Intended use |
| --- | --- | --- |
| Garden background | `#F7F3ED` | Main background |
| Garden surface | `#FCF9F4` | Windows and surfaces |
| Primary text | `#2A2820` | Main text |
| Muted text | `#5D5242` | Secondary text |
| Steel blue | `#4A6B7B` | Primary accent and focus |
| Sage green | `#5B7F6A` | Success and validated states |
| Border | `#C8BEAF` | Window borders and separators |
| Warning | `#B88942` | Warnings and attention |
| Insight | `#76648B` | Insight and learning accents |

## Scope

The intended project components are:

- **GTK 3 theme** for application widgets and surfaces.
- **GTK 4 styling** where supported by the toolkit and target applications.
- **XFWM4 theme** for window borders, title bars, and window controls.
- **Wallpaper and desktop styling** for the Retro Workstation direction.
- **XFCE panel styling** while preserving existing panel plugins and launcher commands.
- **Installer and rollback tooling** for safe, user-level application and recovery.

### Icon theme

Chicago95 is intended to remain the selected icon theme. The project should not replace it with WhiteSur, Breeze, Yaru, or another icon pack. Theme implementation must preserve this preference.

GTK, GTK 4, XFWM4, panel styling, fonts, cursors, and icons use separate configuration mechanisms. Different settings are not automatically errors; changes should follow the intended design and be verified in the actual desktop session.

## Target environment

The initial development environment is:

- elementary OS 8.1, based on Ubuntu 24.04 LTS
- XFCE 4.18 on X11
- GTK 3.24.41
- XFWM4 4.18
- XFCE Panel 4.18

Other environments may work, but are not yet guaranteed. GTK 3 and GTK 4 theme mechanisms differ; GTK 3 stylesheets must not be assumed to work in GTK 4.

## Project status

This project is under active development. Do not assume all planned components are already implemented or visually verified.

Before live installation, confirm that the repository contains the relevant theme assets and installer, review the compatibility notes, and use the check/dry-run modes when available.

## Installation

The intended primary installer is `install.sh`, with a corresponding `rollback.sh`. These scripts must be implemented and reviewed before use.

Once available, the planned workflow is:

```bash
git clone https://github.com/mrohadiz/digital-garden-desktop.git
cd digital-garden-desktop

# Inspect the environment and prerequisites without changing the desktop
bash ./install.sh --check

# Preview intended changes without applying them
bash ./install.sh --dry-run

# Apply the theme after reviewing the checks and preview
bash ./install.sh
```

**Do not run these commands until `install.sh` and its documented options are present and verified.** An empty or incomplete installer must not be treated as ready for use.

The installer is expected to back up user-level configuration before changes and preserve existing panel plugins, launchers, workspace behavior, and Chicago95 icons. A rollback script should restore only settings changed by the installer. No system-wide changes or automatic reboot/logout should be required.

## Development principles

1. **Inspect before changing.** Detect the real session and configuration rather than assuming a standard Ubuntu or Pantheon desktop.
2. **Preserve deliberate choices.** Customize the user's environment; do not normalize every setting just because it differs.
3. **Make reversible changes.** Back up the exact configuration that will be modified.
4. **Separate toolkit layers.** GTK 3, GTK 4, and XFWM4 require distinct implementation and verification.
5. **Verify honestly.** Distinguish static checks from live visual tests and document unsupported behavior.
6. **Avoid unnecessary dependencies.** Prefer assets and tools already available when practical.

## Third-party assets and licensing

Digital Garden should contain original theme styling and decoration assets. Existing themes such as Chicago95 and WhiteSur may be used as local references during development, but their assets must not be redistributed unless their licenses and attribution requirements explicitly permit it.

Before publishing bundled third-party assets, review their upstream licenses, retain required notices, and document any external dependencies. No license is declared for this project until a project license has been deliberately selected and added.

## Roadmap

- [ ] Establish design tokens and visual specification.
- [ ] Implement and validate the GTK 3 theme.
- [ ] Implement GTK 4 styling where supported.
- [ ] Build the Digital Garden XFWM4 decoration theme.
- [ ] Create the Retro Workstation wallpaper.
- [ ] Add safe `install.sh` check and dry-run modes.
- [ ] Add timestamped backup and `rollback.sh`.
- [ ] Verify Chicago95 icon preservation and XFCE panel integrity.
- [ ] Document compatibility, licensing, and actual test results.

## Contributing

Issues and suggestions are welcome. Reports should include the OS version, desktop session, GTK/XFCE versions, the affected application, and whether the issue is visual or functional. Do not attach logs containing private information without reviewing them first.

## License

No license file has been added yet. Until a license is selected and committed, do not assume this repository grants permission to reuse, redistribute, or modify its contents beyond rights granted by applicable law.
