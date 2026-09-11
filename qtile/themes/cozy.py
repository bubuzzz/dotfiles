"""Cozy — the flagship Cozytile palette (purple/mauve), with the tuned bar.

Structure lives in themes/_cozytile.py; this file is the colours plus the same
departures from upstream that everforest uses.  Cozy shares Sakura's outer and
island tones exactly and differs only in its accents, so both use the same
gradient stops and rim colour.
"""

from themes import _cozytile

NAME = "cozy"

palette = {
    "outer": "#282738",  # bar background, the gaps between islands
    "island": "#353446",  # raised widget groups
    "fg": "#CAA9E0",
    "accent": "#91B1F0",  # active workspace block
    "glow": "#4B427E",
    "border": "#3b4252",
    "float": "#1F1D2E",
}

# Window borders reuse the bar's own two tones: the lighter "island" marks the
# focused window, the darker "outer" recedes for the unfocused ones.
BORDER_WIDTH = 4
BORDER_FOCUS = palette["island"]
BORDER_NORMAL = palette["outer"]

# Which edge the bar sits on: "top" or "bottom".  The gap below/above it and
# the screen-edge gap opposite it both follow from this.
bar_position = "bottom"

# The single gap size, applied uniformly.  qtile's layout margin is per-window,
# so two neighbours are GAP apart but a window sits only GAP/2 from the screen
# edge; the screen_gaps below make up the difference, and BAR_MARGIN adds the
# same on the bar's window-facing side.
GAP = 8
_HALF = GAP // 2

_far_edge = "top" if bar_position == "bottom" else "bottom"
screen_gaps = {"left": _HALF, "right": _HALF, _far_edge: _HALF}

# Flush to its own edge and the sides, unlike upstream's floating
# [15, 60, 6, 60] bar.  Margin order is [top, right, bottom, left].
BAR_MARGIN = [_HALF, 0, 0, 0] if bar_position == "bottom" else [0, 0, _HALF, 0]

# Slightly taller than upstream's 30: the shading needs room to read.
BAR_HEIGHT = 32

# A crisp rim on the bar's window-facing edge.  The picom shadow alone does not
# separate the bar from a bright wallpaper reliably.  (colour, width in px)
BAR_EDGE_LINE = ("#5A5877", 1)

# Bar translucency.  Set through qtile, not picom -- see make_bar's docstring.
BAR_OPACITY = 0.9

# qtile drops bar text by a hardcoded 1px and centres the layout box rather
# than the glyphs, so text reads low.  This lifts it back.
TEXT_RISE_PX = 2

# Raised-island shading, centred on the flat island colour.  Re-run the
# generator after changing these:
#   python3 ~/.config/qtile/scripts/gen-gradient-slices.py cozy
GRADIENT = ("#454456", "#2C2B3D")

# Workspace icon size (upstream: 24, which crowds the bar).
GROUPBOX_FONTSIZE = 16

# Breathing room for the workspace icons: PADDING_X insets each icon inside its
# highlight block, MARGIN_X is the gap between blocks.
GROUPBOX_PADDING_X = 8
GROUPBOX_MARGIN_X = 5

widget_defaults = _cozytile.widget_defaults()
extension_defaults = widget_defaults.copy()
layout_defaults = _cozytile.layout_defaults(
    palette, BORDER_WIDTH, focus=BORDER_FOCUS, normal=BORDER_NORMAL, margin=_HALF
)
layout_overrides = {}
floating_defaults = _cozytile.floating_defaults(
    palette, BORDER_WIDTH, focus=BORDER_FOCUS, normal=BORDER_NORMAL
)


def make_bar():
    return _cozytile.make_bar(
        NAME,
        palette,
        height=BAR_HEIGHT,
        margin=BAR_MARGIN,
        groupbox_fontsize=GROUPBOX_FONTSIZE,
        groupbox_padding_x=GROUPBOX_PADDING_X,
        groupbox_margin_x=GROUPBOX_MARGIN_X,
        gradient=GRADIENT,
        text_rise_px=TEXT_RISE_PX,
        opacity=BAR_OPACITY,
        edge_line=BAR_EDGE_LINE,
        position=bar_position,
    )
