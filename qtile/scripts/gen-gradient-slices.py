#!/usr/bin/env python3
"""Regenerate a theme's bar slice images with a vertical gradient.

The Cozytile bar is built from six PNGs that carry the island colour in their
pixels, so a GradientDecoration on the widgets alone would leave those slices
flat and put a notch at both ends of every island.  The same ramp has to be
baked into the images.

Reads the untouched originals from <theme>/flat/ and writes the gradient
versions alongside them in <theme>/, so repeated runs never compound.

    python3 scripts/gen-gradient-slices.py everforest
"""

import os
import sys

from PIL import Image

CONFIG_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Per theme: the flat island colour to replace, the bar colour to leave alone,
# and the top/bottom stops of the ramp.  Keep the stops centred on the island
# colour so the island holds its place in the palette.
THEMES = {
    "everforest": {
        "island": (0x34, 0x3F, 0x44),
        "outer": (0x23, 0x2A, 0x2E),
        "top": (0x44, 0x4F, 0x54),
        "bottom": (0x26, 0x31, 0x36),
    },
    # Sakura's island and outer are only ~13 levels apart, against everforest's
    # ~17, so the lower stop is pulled in to keep the island's bottom edge from
    # merging into the bar background.
    # Natura is the darkest of the set and its two tones are only ~17 levels
    # apart, so the lower stop is held 5 levels clear of the bar background.
    "natura": {
        "island": (0x20, 0x22, 0x22),
        "outer": (0x0F, 0x12, 0x12),
        "top": (0x30, 0x32, 0x32),
        "bottom": (0x14, 0x17, 0x17),
    },
    # Carbon inverts the scheme: light islands on a dark bar.  The stops still
    # run light-at-top to dark-at-bottom, just around a much brighter centre.
    "carbon": {
        "island": (0xCC, 0xCC, 0xCC),
        "outer": (0x33, 0x33, 0x33),
        "top": (0xDC, 0xDC, 0xDC),
        "bottom": (0xBE, 0xBE, 0xBE),
    },
    # Cozy shares Sakura's outer and island exactly -- they differ only in
    # their accents -- so the same stops and the same rim colour apply.
    "cozy": {
        "island": (0x35, 0x34, 0x46),
        "outer": (0x28, 0x27, 0x38),
        "top": (0x45, 0x44, 0x56),
        "bottom": (0x2C, 0x2B, 0x3D),
    },
    "sakura": {
        "island": (0x35, 0x34, 0x46),
        "outer": (0x28, 0x27, 0x38),
        "top": (0x45, 0x44, 0x56),
        "bottom": (0x2C, 0x2B, 0x3D),
    },
}


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def regenerate(theme):
    spec = THEMES[theme]
    island, outer = spec["island"], spec["outer"]
    src_dir = os.path.join(CONFIG_DIR, "themes", "assets", theme, "flat")
    dst_dir = os.path.join(CONFIG_DIR, "themes", "assets", theme)

    # The shapes are anti-aliased, so edge pixels are blends of island and outer
    # rather than either one.  Recover each pixel's blend factor from the channel
    # with the widest separation instead of matching colours exactly, otherwise
    # the curved boundaries pick up a hard fringe.
    channel = max(range(3), key=lambda i: abs(island[i] - outer[i]))
    span = island[channel] - outer[channel]

    for name in ("1", "2", "3", "4", "5", "6"):
        src = Image.open(os.path.join(src_dir, f"{name}.png")).convert("RGB")
        w, h = src.size
        px = src.load()
        out = Image.new("RGB", (w, h))
        opx = out.load()

        ramp = [lerp(spec["top"], spec["bottom"], y / (h - 1)) for y in range(h)]

        for y in range(h):
            row = ramp[y]
            for x in range(w):
                a = (px[x, y][channel] - outer[channel]) / span
                a = 0.0 if a < 0 else 1.0 if a > 1 else a
                opx[x, y] = lerp(outer, row, a)

        out.save(os.path.join(dst_dir, f"{name}.png"))
        print(f"  {name}.png")


if __name__ == "__main__":
    theme = sys.argv[1] if len(sys.argv) > 1 else "everforest"
    if theme not in THEMES:
        sys.exit(f"no gradient spec for theme {theme!r}")
    print(f"regenerating {theme} slices:")
    regenerate(theme)
