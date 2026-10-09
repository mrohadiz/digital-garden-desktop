#!/usr/bin/env python3
"""
Digital Garden Retro Workstation - Asset Generator
Generates pixel-perfect XFWM4 window decoration assets and SVG preview
using colors defined in tokens/colors.json.
"""

import json
import os
import sys
from PIL import Image, ImageDraw

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def hex_to_rgba(hex_str, alpha=255):
    rgb = hex_to_rgb(hex_str)
    return (rgb[0], rgb[1], rgb[2], alpha)

def load_tokens(repo_root):
    token_path = os.path.join(repo_root, "tokens", "colors.json")
    with open(token_path, "r", encoding="utf-8") as f:
        return json.load(f)

def generate_xfwm4_assets(repo_root, tokens):
    out_dir = os.path.join(repo_root, "xfwm4", "Digital-Garden")
    os.makedirs(out_dir, exist_ok=True)

    # Color definitions
    c_accent = tokens["palette"]["garden-accent"]      # #4A6B7B (Steel-blue)
    c_surface = tokens["palette"]["garden-surface"]    # #FCF9F4 (Warm paper)
    c_bg = tokens["palette"]["garden-bg"]              # #F7F3ED
    c_border = tokens["palette"]["garden-border"]      # #C8BEAF
    c_muted = tokens["palette"]["garden-muted"]        # #5D5242
    c_success = tokens["palette"]["garden-success"]    # #5B7F6A
    c_warning = tokens["palette"]["garden-warning"]    # #B88942
    
    # Active titlebar: steel-blue gradient/solid with clean top & bottom lines
    c_act_bg = hex_to_rgba("#4A6B7B")
    c_act_top = hex_to_rgba("#567A8C")
    c_act_bottom = hex_to_rgba("#3B5663")
    c_act_btn_bg = hex_to_rgba("#42606E")
    c_act_btn_pre = hex_to_rgba("#54788A")
    c_act_btn_press = hex_to_rgba("#324954")
    c_act_glyph = hex_to_rgba("#FCF9F4")

    # Inactive titlebar: warm muted paper with subtle border
    c_inact_bg = hex_to_rgba("#E8E2D7")
    c_inact_top = hex_to_rgba("#EDE7DC")
    c_inact_bottom = hex_to_rgba("#C8BEAF")
    c_inact_btn_bg = hex_to_rgba("#E0D9CD")
    c_inact_btn_pre = hex_to_rgba("#D5CDC0")
    c_inact_btn_press = hex_to_rgba("#C4BCAD")
    c_inact_glyph = hex_to_rgba("#5D5242")

    title_h = 28
    btn_w = 24
    btn_h = 28

    # 1. Title bar slices (title-1 to title-5)
    def make_title_slice(is_active):
        img = Image.new("RGBA", (4, title_h), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        bg = c_act_bg if is_active else c_inact_bg
        top_line = c_act_top if is_active else c_inact_top
        bot_line = c_act_bottom if is_active else c_inact_bottom
        draw.rectangle([(0, 0), (3, title_h - 1)], fill=bg)
        draw.line([(0, 0), (3, 0)], fill=top_line)
        draw.line([(0, title_h - 1), (3, title_h - 1)], fill=bot_line)
        return img

    for i in range(1, 6):
        make_title_slice(True).save(os.path.join(out_dir, f"title-{i}-active.png"))
        make_title_slice(False).save(os.path.join(out_dir, f"title-{i}-inactive.png"))

    # 2. Corners (top-left, top-right)
    # top-left
    def make_top_corner(is_active, is_left):
        w = 6
        img = Image.new("RGBA", (w, title_h), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        bg = c_act_bg if is_active else c_inact_bg
        border = c_act_bottom if is_active else c_inact_bottom
        # Fill
        draw.rectangle([(0, 0), (w - 1, title_h - 1)], fill=bg)
        # Top border
        draw.line([(0, 0), (w - 1, 0)], fill=c_act_top if is_active else c_inact_top)
        # Bottom border
        draw.line([(0, title_h - 1), (w - 1, title_h - 1)], fill=border)
        # Outer border
        if is_left:
            draw.line([(0, 0), (0, title_h - 1)], fill=border)
        else:
            draw.line([(w - 1, 0), (w - 1, title_h - 1)], fill=border)
        return img

    make_top_corner(True, True).save(os.path.join(out_dir, "top-left-active.png"))
    make_top_corner(False, True).save(os.path.join(out_dir, "top-left-inactive.png"))
    make_top_corner(True, False).save(os.path.join(out_dir, "top-right-active.png"))
    make_top_corner(False, False).save(os.path.join(out_dir, "top-right-inactive.png"))

    # 3. Window borders (left, right, bottom, bottom-left, bottom-right)
    border_color_act = hex_to_rgba("#4A6B7B")
    border_color_inact = hex_to_rgba("#C8BEAF")
    
    # Left & right: (2x16)
    for state, col in [("active", border_color_act), ("inactive", border_color_inact)]:
        side = Image.new("RGBA", (2, 16), col)
        side.save(os.path.join(out_dir, f"left-{state}.png"))
        side.save(os.path.join(out_dir, f"right-{state}.png"))
        
        # Bottom: (16x2)
        bottom = Image.new("RGBA", (16, 2), col)
        bottom.save(os.path.join(out_dir, f"bottom-{state}.png"))

        # Bottom corners: (2x2)
        corner = Image.new("RGBA", (2, 2), col)
        corner.save(os.path.join(out_dir, f"bottom-left-{state}.png"))
        corner.save(os.path.join(out_dir, f"bottom-right-{state}.png"))

    # 4. Buttons: close, hide, maximize, maximize-toggled, menu, shade, stick
    # States: active, inactive, prelight, pressed
    def draw_button(btn_type, state):
        img = Image.new("RGBA", (btn_w, btn_h), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        is_act_win = (state in ["active", "prelight", "pressed"])
        is_pre = (state == "prelight")
        is_press = (state == "pressed")

        if is_act_win:
            title_bg = c_act_bg
            top_line = c_act_top
            bot_line = c_act_bottom
            if is_pre:
                btn_fill = hex_to_rgba("#B84A42") if btn_type == "close" else c_act_btn_pre
                btn_border = hex_to_rgba("#8E322C") if btn_type == "close" else hex_to_rgba("#678F9F")
            elif is_press:
                btn_fill = hex_to_rgba("#8E322C") if btn_type == "close" else c_act_btn_press
                btn_border = hex_to_rgba("#68201B") if btn_type == "close" else hex_to_rgba("#253740")
            else:
                btn_fill = c_act_btn_bg
                btn_border = hex_to_rgba("#354E5A")
            glyph_col = hex_to_rgba("#FCF9F4")
        else:
            title_bg = c_inact_bg
            top_line = c_inact_top
            bot_line = c_inact_bottom
            btn_fill = c_inact_btn_bg
            btn_border = hex_to_rgba("#BDB4A5")
            glyph_col = c_inact_glyph

        # Base title bar background for seamless fit
        draw.rectangle([(0, 0), (btn_w - 1, btn_h - 1)], fill=title_bg)
        draw.line([(0, 0), (btn_w - 1, 0)], fill=top_line)
        draw.line([(0, btn_h - 1), (btn_w - 1, btn_h - 1)], fill=bot_line)

        # Tactile retro-workstation button box: centered 16x16 with 1px border
        bx0 = (btn_w - 16) // 2
        by0 = (btn_h - 16) // 2
        bx1 = bx0 + 15
        by1 = by0 + 15

        if is_press:
            bx0 += 1
            by0 += 1
            bx1 += 1
            by1 += 1

        draw.rectangle([(bx0, by0), (bx1, by1)], fill=btn_fill, outline=btn_border)

        # Draw glyph inside button
        cx = (bx0 + bx1) // 2
        cy = (by0 + by1) // 2

        if btn_type == "close":
            # Clean diagonal cross (X)
            r = 3
            draw.line([(cx - r, cy - r), (cx + r, cy + r)], fill=glyph_col, width=2)
            draw.line([(cx - r, cy + r), (cx + r, cy - r)], fill=glyph_col, width=2)
        elif btn_type == "hide":
            # Minimize underscore line
            draw.line([(cx - 4, cy + 3), (cx + 4, cy + 3)], fill=glyph_col, width=2)
        elif btn_type == "maximize":
            # Square box with 2px top bar
            draw.rectangle([(cx - 4, cy - 4), (cx + 4, cy + 4)], outline=glyph_col, width=1)
            draw.line([(cx - 4, cy - 4), (cx + 4, cy - 4)], fill=glyph_col, width=2)
        elif btn_type == "maximize-toggled":
            # Overlapping window boxes (restore)
            # back box
            draw.rectangle([(cx - 2, cy - 4), (cx + 4, cy + 2)], outline=glyph_col, width=1)
            draw.line([(cx - 2, cy - 4), (cx + 4, cy - 4)], fill=glyph_col, width=1)
            # front box
            draw.rectangle([(cx - 4, cy - 2), (cx + 2, cy + 4)], fill=btn_fill, outline=glyph_col, width=1)
            draw.line([(cx - 4, cy - 2), (cx + 2, cy - 2)], fill=glyph_col, width=1)
        elif btn_type == "menu":
            # 3 horizontal lines or retro square
            draw.line([(cx - 3, cy - 3), (cx + 3, cy - 3)], fill=glyph_col, width=1)
            draw.line([(cx - 3, cy), (cx + 3, cy)], fill=glyph_col, width=1)
            draw.line([(cx - 3, cy + 3), (cx + 3, cy + 3)], fill=glyph_col, width=1)
        elif btn_type == "shade":
            # Arrow / chevron up
            draw.line([(cx - 3, cy + 1), (cx, cy - 2)], fill=glyph_col, width=1)
            draw.line([(cx, cy - 2), (cx + 3, cy + 1)], fill=glyph_col, width=1)
        elif btn_type == "stick":
            # Pin dot
            draw.rectangle([(cx - 2, cy - 2), (cx + 2, cy + 2)], fill=glyph_col)

        return img

    btn_types = ["close", "hide", "maximize", "maximize-toggled", "menu", "shade", "stick"]
    btn_states = ["active", "inactive", "prelight", "pressed"]

    for b in btn_types:
        for s in btn_states:
            filename = f"{b}-{s}.png"
            draw_button(b, s).save(os.path.join(out_dir, filename))

    # 5. themerc
    themerc_content = """# Digital Garden Retro Workstation - XFWM4 Theme
button_offset=2
button_spacing=2

show_app_icon=true
full_width_title=true

title_shadow_active=false
title_shadow_inactive=false

title_alignment=left
title_horizontal_offset=6
title_vertical_offset_active=0
title_vertical_offset_inactive=0

active_text_color=#FCF9F4
active_text_shadow_color=#354D59

inactive_text_color=#5D5242
inactive_text_shadow_color=#FFFFFF

shadow_delta_height=0
shadow_delta_width=0
shadow_delta_x=0
shadow_delta_y=0
shadow_opacity=0
"""
    with open(os.path.join(out_dir, "themerc"), "w", encoding="utf-8") as f:
        f.write(themerc_content)

    print(f"XFWM4 Digital-Garden assets generated successfully in {out_dir}")

def generate_svg_preview(repo_root, tokens):
    out_file = os.path.join(repo_root, "assets", "previews", "palette-preview.svg")
    pal = tokens["palette"]
    
    svg = f"""<svg width="720" height="340" viewBox="0 0 720 340" xmlns="http://www.w3.org/2000/svg" font-family="'Inter', -apple-system, sans-serif">
  <rect width="100%" height="100%" fill="#F7F3ED" rx="8" />
  <text x="24" y="38" font-size="20" font-weight="700" fill="#2A2820">Digital Garden — Retro Workstation Palette</text>
  <text x="24" y="60" font-size="12" fill="#5D5242">Authoritative Color Tokens for XFCE 4.18 &amp; GTK</text>
  
  <g transform="translate(24, 80)">
    <!-- Swatches -->
    <g transform="translate(0, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-bg']}" stroke="#C8BEAF" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">garden-bg</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-bg']}</text>
    </g>
    <g transform="translate(76, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-surface']}" stroke="#C8BEAF" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">surface</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-surface']}</text>
    </g>
    <g transform="translate(152, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-text']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">text</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-text']}</text>
    </g>
    <g transform="translate(228, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-muted']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">muted</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-muted']}</text>
    </g>
    <g transform="translate(304, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-accent']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">accent</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-accent']}</text>
    </g>
    <g transform="translate(380, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-success']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">success</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-success']}</text>
    </g>
    <g transform="translate(456, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-border']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">border</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-border']}</text>
    </g>
    <g transform="translate(532, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-warning']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">warning</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-warning']}</text>
    </g>
    <g transform="translate(608, 0)">
      <rect width="66" height="50" rx="4" fill="{pal['garden-insight']}" />
      <text x="0" y="68" font-size="10" font-weight="600" fill="#2A2820">insight</text>
      <text x="0" y="80" font-size="9" fill="#5D5242">{pal['garden-insight']}</text>
    </g>
  </g>

  <!-- Mockup Window Card -->
  <g transform="translate(24, 200)">
    <rect width="672" height="110" rx="4" fill="#FCF9F4" stroke="#C8BEAF" />
    <!-- Titlebar -->
    <rect width="672" height="28" rx="4" fill="#4A6B7B" />
    <text x="12" y="19" font-size="12" font-weight="600" fill="#FCF9F4">Digital Garden Workstation — Session Analyzer</text>
    <!-- Buttons -->
    <rect x="616" y="6" width="16" height="16" rx="2" fill="#42606E" stroke="#354E5A" />
    <text x="621" y="18" font-size="10" fill="#FCF9F4">_</text>
    <rect x="636" y="6" width="16" height="16" rx="2" fill="#42606E" stroke="#354E5A" />
    <rect x="640" y="10" width="8" height="8" fill="none" stroke="#FCF9F4" stroke-width="1" />
    <rect x="656" y="6" width="16" height="16" rx="2" fill="#B84A42" stroke="#8E322C" />
    <text x="660" y="18" font-size="10" fill="#FCF9F4">✕</text>
    
    <!-- Body Content Mock -->
    <text x="16" y="54" font-size="12" fill="#2A2820">Status: <tspan fill="#5B7F6A" font-weight="600">Active · Cultivating ideas</tspan></text>
    <text x="16" y="74" font-size="11" fill="#5D5242">Environment: elementary OS 8.1 / Noble · XFCE 4.18 · Icons: Chicago95</text>
    <rect x="16" y="86" width="120" height="16" rx="3" fill="#4A6B7B" />
    <text x="32" y="98" font-size="10" font-weight="600" fill="#FCF9F4">Focus Garden</text>
    <rect x="144" y="86" width="90" height="16" rx="3" fill="#F5F0E6" stroke="#C8BEAF" />
    <text x="160" y="98" font-size="10" fill="#2A2820">Settings</text>
  </g>
</svg>"""

    with open(out_file, "w", encoding="utf-8") as f:
        f.write(svg)
    print(f"SVG Preview generated at {out_file}")

if __name__ == "__main__":
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tokens = load_tokens(repo_root)
    generate_xfwm4_assets(repo_root, tokens)
    generate_svg_preview(repo_root, tokens)
