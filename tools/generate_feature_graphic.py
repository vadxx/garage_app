# Copyright (c) 2026 vadxx
# SPDX-License-Identifier: MIT

"""Generate a 1024x500 Google Play feature graphic for garage_app."""

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WIDTH = 1024
HEIGHT = 500

# Darker purple gradient.
TOP_COLOR = (60, 45, 95)  # #3D2D5F
BOTTOM_COLOR = (120, 100, 170)  # #7864AA

# Icon
ICON_SIZE = 220
ICON_X = 100
ICON_Y = (HEIGHT - ICON_SIZE) // 2

# Text block
TEXT_X = ICON_X + ICON_SIZE + 75


def load_font(paths, size):
    for path in paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def draw_text_with_shadow(draw, xy, text, font, fill, shadow_color=(40, 30, 60)):
    x, y = xy
    draw.text((x + 2, y + 2), text, font=font, fill=shadow_color)
    draw.text((x, y), text, font=font, fill=fill)


def main():
    root = Path(__file__).parent.parent
    output_path = root / "screenshots" / "feature_graphic.png"
    icon_path = root / "app_icon.png"

    # Gradient background
    image = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(image)
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        color = tuple(
            int(TOP_COLOR[i] + (BOTTOM_COLOR[i] - TOP_COLOR[i]) * ratio)
            for i in range(3)
        )
        draw.line([(0, y), (WIDTH, y)], fill=color)

    # App icon (clean, no shadow)
    icon = Image.open(icon_path).convert("RGBA")
    icon = icon.resize((ICON_SIZE, ICON_SIZE), Image.LANCZOS)
    image.paste(icon, (ICON_X, ICON_Y), icon)

    # Title: bold and large
    title_font = load_font(
        ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf"], 88
    )
    # Subtitle: elegant regular weight with soft shadow
    body_font = load_font(
        ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"], 30
    )
    # Emphasized last subtitle line
    body_bold_font = load_font(
        ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf"], 30
    )

    draw = ImageDraw.Draw(image)

    title = "Garage"
    body_lines = [
        "Track maintenance,",
        "oil changes, repairs",
        "and daily spending",
        "for your cars",
        "— all offline, in one place.",
    ]
    line_spacing = 42
    title_to_body_gap = 26

    # Vertically center the whole text block
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_height = title_bbox[3] - title_bbox[1]
    body_height = len(body_lines) * line_spacing
    total_height = title_height + title_to_body_gap + body_height
    block_top = (HEIGHT - total_height) / 2

    title_y = block_top - title_bbox[1]
    draw.text((TEXT_X, title_y), title, font=title_font, fill=(255, 255, 255))

    body_top = block_top + title_height + title_to_body_gap
    for i, line in enumerate(body_lines):
        font = body_bold_font if i == len(body_lines) - 1 else body_font
        bbox = draw.textbbox((0, 0), line, font=font)
        y = body_top + i * line_spacing - bbox[1]
        draw_text_with_shadow(
            draw, (TEXT_X, y), line, font, fill=(255, 255, 255)
        )

    image.save(output_path)
    print(f"Saved {output_path}")


if __name__ == "__main__":
    main()
