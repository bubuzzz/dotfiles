"""Everforest — the muted green Cozytile palette.

Structure lives in themes/_cozytile.py; this file is only the colours.
"""

from themes import _cozytile

NAME = "everforest"

palette = {
    "outer": "#232A2E",  # bar background, the gaps between islands
    "island": "#343F44",  # raised widget groups
    "fg": "#86918A",
    "accent": "#D3C6AA",  # active workspace block
    # Upstream leaves this at Cozy's purple rather than an Everforest tone.
    # It is inert under highlight_method "block", so it is kept as shipped.
    "glow": "#4B427E",
    "border": "#3b4252",
    "float": "#1F1D2E",
}

# Window borders reuse the bar's own two tones: the lighter "island" marks the
# focused window, the darker "outer" recedes for the unfocused ones.
BORDER_WIDTH = 4
BORDER_FOCUS = palette["island"]
BORDER_NORMAL = palette["outer"]

# The single gap size, applied uniformly.  qtile's layout margin is per-window,
# so two neighbours are GAP apart but a window sits only GAP/2 from the screen
# edge; the screen_gaps below make up the difference, and BAR_MARGIN adds the
# same underneath the bar.
GAP = 8
_HALF = GAP // 2

# Which edge the bar sits on: "top" or "bottom".  The gap below/above it and
# the screen-edge gap opposite it both follow from this.
bar_position = "bottom"

_far_edge = "top" if bar_position == "bottom" else "bottom"
screen_gaps = {"left": _HALF, "right": _HALF, _far_edge: _HALF}

# Flush to its own edge and the sides, unlike upstream's floating
# [15, 60, 6, 60] bar, with GAP/2 on the window side so the bar-to-window gap
# matches the rest.  Margin order is [top, right, bottom, left].
# The matching corner-radius = 0 for the bar lives in assets/everforest/picom.conf.
BAR_MARGIN = (
    [_HALF, 0, 0, 0] if bar_position == "bottom" else [0, 0, _HALF, 0]
)

# Slightly taller than upstream's 30: the shading needs a little room to read.
BAR_HEIGHT = 32

# Raised-island shading, centred on the flat island colour so the island keeps
# its place in the palette.  Re-run the generator after changing these:
#   python3 ~/.config/qtile/scripts/gen-gradient-slices.py everforest
GRADIENT = ("#444F54", "#263136")

# A crisp rim on the bar's window-facing edge.  The picom shadow alone does not
# separate the bar from a bright wallpaper reliably.  (colour, width in px)
BAR_EDGE_LINE = ("#5A6A70", 1)

# Bar translucency. Set through qtile, not picom -- see make_bar's docstring.
BAR_OPACITY = 0.9

# qtile drops bar text by a hardcoded 1px and centres the layout box rather
# than the glyphs, so text reads low.  This lifts it back.
TEXT_RISE_PX = 2

# Workspace icon size (upstream: 24, which crowds a 30px bar).
GROUPBOX_FONTSIZE = 16

# Breathing room for the workspace icons: PADDING_X insets each icon inside its
# highlight block, MARGIN_X is the gap between blocks. Upstream sets neither.
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
