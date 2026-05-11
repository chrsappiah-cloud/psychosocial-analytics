"""Generate Psychosocial Analytics brand assets.

Produces four 1024x1024 PNGs in Assets.xcassets:
  AppIcon.appiconset/AppIcon-Light.png   - emerald gradient + gold diamond + sparkles
  AppIcon.appiconset/AppIcon-Dark.png    - obsidian gradient variant
  AppIcon.appiconset/AppIcon-Tinted.png  - luminosity mask for iOS tinted icons
  LaunchLogo.imageset/LaunchLogo.png     - centered diamond mark for launch screen

Run:  python3 scripts/generate_brand_assets.py
"""
from __future__ import annotations

import math
import os
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "Psychosocial  Analytics" / "Assets.xcassets"
ICON_DIR = ASSETS / "AppIcon.appiconset"
LAUNCH_DIR = ASSETS / "LaunchLogo.imageset"

EMERALD_DEEP = (18, 56, 44)
EMERALD = (31, 78, 61)
EMERALD_LIGHT = (52, 118, 92)
GOLD = (200, 169, 91)
GOLD_BRIGHT = (231, 200, 122)
GOLD_DEEP = (148, 118, 52)
PEARL = (248, 244, 237)
DIAMOND = (229, 234, 236)
DIAMOND_BRIGHT = (252, 254, 255)
OBSIDIAN = (18, 22, 32)
OBSIDIAN_MID = (32, 38, 54)


def radial_background(inner: tuple[int, int, int], outer: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (SIZE, SIZE), outer)
    overlay = Image.new("RGBA", (SIZE, SIZE), (*inner, 0))
    draw = ImageDraw.Draw(overlay)
    steps = 140
    for i in range(steps, 0, -1):
        r = (i / steps) * SIZE * 0.62
        a = int(255 * (1 - i / steps) ** 1.6)
        draw.ellipse(
            [SIZE / 2 - r, SIZE / 2 - r, SIZE / 2 + r, SIZE / 2 + r],
            fill=(*inner, a),
        )
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


def diamond_polygon(cx: float, cy: float, w: float, h: float) -> list[tuple[float, float]]:
    """Brilliant-cut diamond outline: table on top, point on bottom."""
    table_w = w * 0.55
    crown_y = cy - h * 0.20
    return [
        (cx - table_w / 2, cy - h / 2),  # top-left of table
        (cx + table_w / 2, cy - h / 2),  # top-right of table
        (cx + w / 2, crown_y),           # right shoulder
        (cx, cy + h / 2),                # bottom point (culet)
        (cx - w / 2, crown_y),           # left shoulder
    ]


def draw_diamond(img: Image.Image, palette: dict) -> None:
    draw = ImageDraw.Draw(img, "RGBA")
    cx, cy = SIZE / 2, SIZE / 2 + 20
    w, h = SIZE * 0.50, SIZE * 0.58

    outline = diamond_polygon(cx, cy, w, h)

    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.polygon([(x, y + 24) for x, y in outline], fill=(0, 0, 0, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    img.paste(shadow, (0, 0), shadow)

    draw.polygon(outline, fill=(*palette["fill"], 255))

    table_w = w * 0.55
    crown_y = cy - h * 0.20
    table_l = (cx - table_w / 2, cy - h / 2)
    table_r = (cx + table_w / 2, cy - h / 2)
    shoulder_l = (cx - w / 2, crown_y)
    shoulder_r = (cx + w / 2, crown_y)
    culet = (cx, cy + h / 2)

    draw.polygon([table_l, table_r, shoulder_r, shoulder_l],
                 fill=(*palette["table"], 255))

    draw.polygon([shoulder_l, shoulder_r, culet],
                 fill=(*palette["pavilion"], 255))

    pavilion_mid_x = (shoulder_l[0] + shoulder_r[0]) / 2
    pavilion_mid_y = crown_y + (culet[1] - crown_y) * 0.05
    pavilion_mid = (pavilion_mid_x, pavilion_mid_y)
    quarter_l = ((shoulder_l[0] + pavilion_mid_x) / 2, (shoulder_l[1] + pavilion_mid_y) / 2 - 4)
    quarter_r = ((shoulder_r[0] + pavilion_mid_x) / 2, (shoulder_r[1] + pavilion_mid_y) / 2 - 4)
    draw.polygon([shoulder_l, pavilion_mid, culet], fill=(*palette["pavilion_dark"], 255))
    draw.polygon([shoulder_l, quarter_l, pavilion_mid], fill=(*palette["pavilion"], 255))
    draw.polygon([shoulder_r, quarter_r, pavilion_mid], fill=(*palette["pavilion_light"], 255))
    draw.polygon([shoulder_r, pavilion_mid, culet], fill=(*palette["pavilion"], 255))

    table_mid_top = ((table_l[0] + table_r[0]) / 2, table_l[1])
    table_mid_bot = ((shoulder_l[0] + shoulder_r[0]) / 2, crown_y)
    draw.polygon([table_l, table_mid_top, table_mid_bot, shoulder_l],
                 fill=(*palette["crown_left"], 255))
    draw.polygon([table_mid_top, table_r, shoulder_r, table_mid_bot],
                 fill=(*palette["crown_right"], 255))

    line_w = max(3, SIZE // 320)
    draw.line([table_l, shoulder_l], fill=palette["edge"], width=line_w)
    draw.line([table_r, shoulder_r], fill=palette["edge"], width=line_w)
    draw.line([shoulder_l, culet], fill=palette["edge"], width=line_w)
    draw.line([shoulder_r, culet], fill=palette["edge"], width=line_w)
    draw.line([table_l, table_r], fill=palette["edge"], width=line_w)
    draw.line([shoulder_l, shoulder_r], fill=palette["edge_inner"], width=max(2, line_w - 1))
    draw.line([table_mid_top, table_mid_bot], fill=palette["edge_inner"], width=max(2, line_w - 1))
    draw.line([shoulder_l, pavilion_mid], fill=palette["edge_inner"], width=max(2, line_w - 1))
    draw.line([shoulder_r, pavilion_mid], fill=palette["edge_inner"], width=max(2, line_w - 1))
    draw.line([pavilion_mid, culet], fill=palette["edge_inner"], width=max(2, line_w - 1))

    highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(highlight)
    hl_pts = [
        (table_l[0] + 16, table_l[1] + 14),
        (table_l[0] + 78, table_l[1] + 14),
        (table_l[0] + 60, table_l[1] + 38),
        (table_l[0] + 24, table_l[1] + 32),
    ]
    hdraw.polygon(hl_pts, fill=(255, 255, 255, 150))
    highlight = highlight.filter(ImageFilter.GaussianBlur(2.4))
    img.paste(highlight, (0, 0), highlight)

    spark = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sdraw2 = ImageDraw.Draw(spark)
    sx, sy = pavilion_mid_x - 40, pavilion_mid_y + 20
    sdraw2.ellipse([sx - 6, sy - 6, sx + 6, sy + 6], fill=(255, 255, 255, 220))
    spark = spark.filter(ImageFilter.GaussianBlur(1.2))
    img.paste(spark, (0, 0), spark)


def draw_sparkles(img: Image.Image, color: tuple[int, int, int], count: int = 14, seed: int = 7) -> None:
    rnd = random.Random(seed)
    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for _ in range(count):
        x = rnd.randint(60, SIZE - 60)
        y = rnd.randint(60, SIZE - 60)
        if 350 < x < 674 and 320 < y < 760:
            continue
        size = rnd.choice([14, 18, 22, 28, 36])
        alpha = rnd.randint(150, 230)
        c = (*color, alpha)
        draw.polygon(
            [(x, y - size), (x + size * 0.18, y - size * 0.18),
             (x + size, y), (x + size * 0.18, y + size * 0.18),
             (x, y + size), (x - size * 0.18, y + size * 0.18),
             (x - size, y), (x - size * 0.18, y - size * 0.18)],
            fill=c,
        )
        draw.ellipse([x - 3, y - 3, x + 3, y + 3], fill=(255, 255, 255, 255))
    overlay = overlay.filter(ImageFilter.GaussianBlur(0.6))
    img.paste(overlay, (0, 0), overlay)


def gold_palette() -> dict:
    return {
        "fill": GOLD,
        "table": GOLD_BRIGHT,
        "crown_left": GOLD,
        "crown_right": GOLD_DEEP,
        "pavilion": GOLD,
        "pavilion_dark": GOLD_DEEP,
        "pavilion_light": GOLD_BRIGHT,
        "edge": (110, 84, 30),
        "edge_inner": (160, 130, 60),
    }


def diamond_palette() -> dict:
    return {
        "fill": DIAMOND,
        "table": DIAMOND_BRIGHT,
        "crown_left": DIAMOND,
        "crown_right": (180, 198, 210),
        "pavilion": (160, 178, 192),
        "pavilion_dark": (110, 130, 148),
        "pavilion_light": DIAMOND_BRIGHT,
        "edge": (60, 80, 96),
        "edge_inner": (130, 150, 168),
    }


def render_icon(bg_inner, bg_outer, gem_palette, sparkle_color, seed=7) -> Image.Image:
    img = radial_background(bg_inner, bg_outer)
    draw_sparkles(img, sparkle_color, count=10, seed=seed + 1)
    draw_diamond(img, gem_palette)
    draw_sparkles(img, sparkle_color, count=8, seed=seed + 2)
    return img


def render_tinted() -> Image.Image:
    """Grayscale luminosity image for iOS Tinted appearance.

    iOS multiplies a user-chosen tint over this; black stays black, white takes the tint.
    Use a dark gray background and bright gem so the tint reads as a glowing emblem.
    """
    base = render_icon(
        bg_inner=(60, 60, 60),
        bg_outer=(15, 15, 15),
        gem_palette={
            "fill": (210, 210, 210),
            "table": (245, 245, 245),
            "crown_left": (200, 200, 200),
            "crown_right": (160, 160, 160),
            "pavilion": (180, 180, 180),
            "pavilion_dark": (110, 110, 110),
            "pavilion_light": (240, 240, 240),
            "edge": (50, 50, 50),
            "edge_inner": (130, 130, 130),
        },
        sparkle_color=(220, 220, 220),
        seed=21,
    )
    return base.convert("L").convert("RGB")


def render_launch_logo() -> Image.Image:
    """Centered gold diamond on transparent background, rendered small enough
    that iOS UILaunchScreen's image-fit behavior leaves generous margins."""
    full = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_diamond(full, gold_palette())
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    scale = 0.42
    new_w = int(SIZE * scale)
    shrunk = full.resize((new_w, new_w), Image.LANCZOS)
    canvas.paste(shrunk, ((SIZE - new_w) // 2, (SIZE - new_w) // 2), shrunk)
    return canvas


def write_contents_json(path: Path, payload: str) -> None:
    path.write_text(payload)


def main() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    LAUNCH_DIR.mkdir(parents=True, exist_ok=True)

    light = render_icon(EMERALD_LIGHT, EMERALD_DEEP, gold_palette(),
                        sparkle_color=PEARL, seed=7)
    dark = render_icon(OBSIDIAN_MID, OBSIDIAN, gold_palette(),
                       sparkle_color=GOLD_BRIGHT, seed=11)
    tinted = render_tinted()
    launch = render_launch_logo()

    light.save(ICON_DIR / "AppIcon-Light.png", "PNG", optimize=True)
    dark.save(ICON_DIR / "AppIcon-Dark.png", "PNG", optimize=True)
    tinted.save(ICON_DIR / "AppIcon-Tinted.png", "PNG", optimize=True)
    launch.save(LAUNCH_DIR / "LaunchLogo.png", "PNG", optimize=True)

    icon_contents = """{
  "images" : [
    {
      "filename" : "AppIcon-Light.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "filename" : "AppIcon-Dark.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "tinted" } ],
      "filename" : "AppIcon-Tinted.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
"""
    write_contents_json(ICON_DIR / "Contents.json", icon_contents)

    launch_contents = """{
  "images" : [
    { "filename" : "LaunchLogo.png", "idiom" : "universal", "scale" : "1x" },
    { "idiom" : "universal", "scale" : "2x" },
    { "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
"""
    write_contents_json(LAUNCH_DIR / "Contents.json", launch_contents)

    print(f"Wrote 4 images + 2 Contents.json under {ASSETS}")


if __name__ == "__main__":
    main()
