"""Carbon — the greyscale Cozytile palette, with the tuned bar.

The odd one out: Carbon inverts the scheme, putting *light* islands on a dark
bar.  That means it needs both optional palette keys the shared builder
supports -- `fg_outer`, because dark text on the islands would be invisible on
the bar background, and `inactive`, because the default (`outer`) is a dark grey
that collides with the active colour on a light island.
"""

from themes import _cozytile

NAME = "carbon"

palette = {
    "outer": "#333333",  # bar background, the gaps between islands
    "island": "#CCCCCC",  # raised widget groups -- light, unlike the others
    "fg": "#474747",  # dark text, on the light islands
    "fg_outer": "#CCCCCC",  # light text, on the dark bar background
    # Three clearly separated levels on the pale island: current workspace,
    # workspaces holding windows (fg above), and empty ones.  Upstream's
    # #333333 / #555555 / #C2C2C2 leaves the first two almost identical and the
    # third all but invisible.
    "accent": "#1A1A1A",  # current workspace
    "inactive": "#9A9A9A",  # empty workspaces
    # Upstream's GroupBox `foreground`.  Inert under highlight_method "block",
    # but it must not be #CCCCCC -- that is the island colour itself.
    "glow": "#333333",
    "border": "#3b4252",
    "float": "#1F1D2E",
}

# Window borders reuse the bar's own two tones: the lighter "island" marks the
# focused window, the darker "outer" recedes for the unfocused ones.  The
# contrast is far stronger here than in the dark themes.
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

# A crisp rim on the bar's window-facing edge.  Dark here rather than light:
# most of the bar's width is taken up by the pale islands, so a dark line is
# what actually outlines it.  (colour, width in px)
BAR_EDGE_LINE = ("#1F1F1F", 1)

# Bar translucency.  Set through qtile, not picom -- see make_bar's docstring.
BAR_OPACITY = 0.9

# qtile drops bar text by a hardcoded 1px and centres the layout box rather
# than the glyphs, so text reads low.  This lifts it back.
TEXT_RISE_PX = 2

# Raised-island shading, centred on the flat island colour.  Re-run the
# generator after changing these:
#   python3 ~/.config/qtile/scripts/gen-gradient-slices.py carbon
GRADIENT = ("#DCDCDC", "#BEBEBE")

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
