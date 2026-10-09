# Digital Garden — Retro Workstation: Design System

## 1. Visual Philosophy

**Digital Garden — Retro Workstation** combines:
- **Tactile retro computing feel**: Clear window boundaries, structured workstation buttons, and the preserved **Chicago95** icon pack.
- **Warm paper aesthetic**: Soft, eye-pleasing cream/parchment surfaces replacing harsh pure-white or generic flat greys.
- **Organic nature accents**: Calm steel-blue active highlights and gentle sage-green indicators representing ideas cultivated in a digital notebook.
- **Modern typography & contrast**: High legibility powered by **Inter** at 10pt with crisp contrast across dark and light surfaces.

---

## 2. Color Palette & Tokens

The single source of truth is located at [`tokens/colors.json`](file:///home/rohadi/Projects/xfce-themes-note/tokens/colors.json).

| Token | Hex | Role | Contrast Ratio |
|---|---|---|---|
| `garden-bg` | `#F7F3ED` | Canvas background | Base tone |
| `garden-surface` | `#FCF9F4` | Cards, views, inputs | 15.2:1 against `garden-text` |
| `garden-text` | `#2A2820` | Primary typography | 15.2:1 on surface |
| `garden-muted` | `#5D5242` | Subtitles, disabled states | 5.8:1 on surface (WCAG AA) |
| `garden-accent` | `#4A6B7B` | Primary focus, active title bars | 4.6:1 on surface / 7.1:1 on active fg |
| `garden-success` | `#5B7F6A` | Validations, growth states | 3.9:1 on surface |
| `garden-border` | `#C8BEAF` | Window borders, dividers | Crisp 1px structure |
| `garden-warning` | `#B88942` | Attention, pending alerts | 3.2:1 on surface |
| `garden-insight` | `#76648B` | Ideas, knowledge tags | 4.8:1 on surface |

---

## 3. Window Manager (XFWM4) Specifications

- **Title bar height**: 28px
- **Active title bar**: Steel-blue (`#4A6B7B`) with top highlight line (`#567A8C`) and bottom edge line (`#3B5663`). Active title text is `#FCF9F4` (`Inter Bold 9`).
- **Inactive title bar**: Warm parchment (`#E8E2D7`), text `#5D5242`.
- **Window frame borders**: 2px clean border (`#4A6B7B` for active windows, `#C8BEAF` for inactive windows).
- **Controls**: Tactile 16x16 inset buttons for Close (with soft red prelight `#B84A42`), Minimize (`_`), and Maximize/Restore (`□`).

---

## 4. Typography

- **UI Font**: `Inter 10`
- **Window Titles**: `Inter Bold 9`
- **Monospace Font**: `Ubuntu Sans Mono 10` (preserved for terminals and code editors).
- **Fallbacks**: `Ubuntu Sans`, `Noto Sans`, system sans-serif.

---

## 5. Desktop Metaphor & Wallpaper

- **Visual Theme**: Warm paper texture, calm sage-green rolling hills, stylized idea tree with knowledge nodes, vintage workstation monitor, steel-blue flora.
- **Resolution**: High-definition 16:9 wallpaper asset (`assets/wallpaper/digital-garden-1920x1080.jpg`), scaled cleanly for Lenovo ThinkPad T490 (1920x1080 display).
