"""Shared machinery for the themes ported from Darkkal44/Cozytile.

Every Cozytile theme is the same bar with a different palette, so the structure
lives here once and each theme module is reduced to its colours.  A theme built
on this must define a palette with these keys:

    outer   bar background, the gaps between islands
    island  raised widget groups
    fg      text and glyphs on the islands
    accent  the active workspace block
    glow    GroupBox highlight_color / foreground (inert under highlight_method
            "block", but upstream sets it, so it is kept)
    border  tiled window border
    float   floating window border

Optional keys, which fall back to sensible defaults so the dark themes need
neither:

    fg_outer   text on the bar background; defaults to `fg`.  A light theme
               like carbon inverts the two -- dark text on its light islands,
               light text on its dark bar -- so one colour is not enough.
    inactive   empty-workspace icons; defaults to `outer`, which reads well on
               a dark island but collides with the active colour on a light one.

The widget *content* (CPU / Memory / Systray / Clock) is this config's own; only
the styling comes from upstream.  Upstream runs border_width=0 and leans on the
9px gaps plus picom's shadows and corner radius (assets/shared/picom-cozytile.conf)
to separate windows.

Glyphs are JetBrainsMono Nerd Font rather than upstream's "Font Awesome 6 Free
Solid": Font Awesome ships here as WOFF2 only, which fontconfig will not render.
"""

from libqtile import bar
from libqtile.lazy import lazy

# Widgets must come from qtile_extras, not libqtile: they are the same classes,
# but the decoration-drawing hook is only injected on attribute access through
# qtile_extras, so a libqtile-built widget accepts `decorations` and silently
# discards it.
from qtile_extras import widget
from qtile_extras.widget.decorations import GradientDecoration

from themes import ROFI_LAUNCHER, ROFI_POWER, asset

GLYPH_FONT = "JetBrainsMono Nerd Font"
TEXT_FONT = "JetBrainsMono Nerd Font Bold"
GLYPH_SIZE = 13
FONT_SIZE = 13

GLYPH_SEARCH = ""
GLYPH_CPU = ""
GLYPH_MEMORY = ""
GLYPH_CLOCK = ""


def lift(cls, pixels):
    """Subclass `cls` so its text draws `pixels` higher.

    Hooks the TextLayout's draw rather than the widget's, so only the glyphs
    move; the background, decorations and widget width are all unaffected.
    """
    if not pixels:
        return cls

    class Lifted(cls):
        def _configure(self, qtile, bar):
            super()._configure(qtile, bar)
            layout = self.layout
            if getattr(layout, "_lifted", False):
                return
            original = layout.draw
            layout.draw = lambda x, y, _d=original: _d(x, y - pixels)
            layout._lifted = True

    Lifted.__name__ = cls.__name__
    return Lifted


def widget_defaults():
    return dict(font=TEXT_FONT, fontsize=FONT_SIZE, padding=3)


# Colours are set regardless of width: at BORDER_WIDTH = 0 nothing is drawn,
# and raising it then gives a sensible focus ring without further edits.
# A theme can override either colour; both default to the palette's accent
# (focused) and island (unfocused).
def layout_defaults(palette, border_width, focus=None, normal=None, margin=9):
    return {
        "border_width": border_width,
        "margin": margin,
        "border_focus": focus or palette["accent"],
        "border_normal": normal or palette["island"],
        "border_on_single": True,
    }


def floating_defaults(palette, border_width, focus=None, normal=None):
    return {
        "border_focus": focus or palette["accent"],
        "border_normal": normal or palette["island"],
        "border_width": border_width,
    }


def make_bar(
    name,
    palette,
    margin=None,
    groupbox_fontsize=18,
    groupbox_padding_x=None,
    groupbox_margin_x=None,
    height=30,
    gradient=None,
    text_rise_px=0,
    opacity=1.0,
    edge_line=None,
    position="top",
):
    """The Cozytile bar, rendered in `palette`, with our own widget content.

    `margin` floats the bar off the screen edges; upstream uses
    [15, 60, 6, 60].  Pass [0, 0, 0, 0] for a bar flush to the edges.
    `height` is the bar height (upstream: 30).
    `edge_line` is an optional (colour, width) rim drawn on the edge facing the
    windows.  A shadow alone is unreliable separation against a bright
    wallpaper, and picom only honours `shadow` on/off per window -- opacity,
    radius and offset are global -- so this gives the bar a definite boundary.
    `opacity` makes the bar translucent.  This is qtile's own Bar option rather
    than a picom rule: the bar window carries no WM_CLASS and no window type,
    only a QTILE_INTERNAL property, so class-based compositor rules cannot
    reach it.
    `text_rise_px` nudges text up.  qtile hardcodes a +1px drop in
    _TextBox.draw (`y = (bar.size - layout.height) / 2 + 1`) and centres the
    layout box, which includes descent space, so bar text reads low.  There is
    no setting for it and Pango's `rise` attribute is absorbed by the layout's
    logical extents, so `lift()` below wraps the text layout's own draw call --
    which moves the glyphs only, leaving the widget background untouched.
    `gradient` is an optional (top, bottom) pair shading the raised islands.
    The ramp is purely vertical, so every widget renders the same one and no
    seams appear between them -- but the transition slices carry the island
    colour in their pixels, so scripts/gen-gradient-slices.py must bake the
    same ramp into the PNGs or each island ends in a flat notch.
    `groupbox_fontsize` sizes the workspace icons (upstream: 24).
    `groupbox_padding_x` insets each icon inside its highlight block and
    `groupbox_margin_x` is the gap between blocks; both fall back to
    qtile's defaults, which is what upstream uses.

    The 1..6 PNGs shape the islands: 4/6 open one (outer -> island colour),
    3/5 close one, 1/2 are dividers inside an island.
    """
    if margin is None:
        margin = [15, 60, 6, 60]

    outer = palette["outer"]
    island = palette["island"]
    fg = palette["fg"]
    fg_outer = palette.get("fg_outer", fg)
    inactive = palette.get("inactive", outer)

    def ink(background):
        """Text colour for whichever surface the widget sits on."""
        return fg_outer if background == outer else fg

    # Drawn after the widget clears its background, so it covers the flat island
    # colour; that colour stays as the fallback for any area it does not reach.
    raised = (
        {
            "decorations": [
                GradientDecoration(colours=list(gradient), points=[(0, 0), (0, 1)])
            ]
        }
        if gradient
        else {}
    )

    # Drawn after the widget clears its background, so it covers the flat
    # island colour; that colour stays as the fallback for any gap.
    def slice_(number, **kwargs):
        # padding=0 is required: widget_defaults sets padding=3, which would
        # leave a 3px gutter of bar background down each side of every slice
        # and read as a dark separator between the sections.
        kwargs.setdefault("padding", 0)
        return widget.Image(filename=asset(name, f"{number}.png"), **kwargs)

    def glyph(text, background, **kwargs):
        return TextBox(
            text=text,
            font=GLYPH_FONT,
            fontsize=GLYPH_SIZE,
            background=background,
            foreground=ink(background),
            **kwargs,
        )

    def text(background=None, **kwargs):
        return dict(
            font=TEXT_FONT,
            fontsize=FONT_SIZE,
            foreground=ink(background if background is not None else island),
            **kwargs,
        )

    # Text-bearing widgets, lifted off qtile's low baseline.
    TextBox = lift(widget.TextBox, text_rise_px)
    WindowName = lift(widget.WindowName, text_rise_px)
    CPU = lift(widget.CPU, text_rise_px)
    Memory = lift(widget.Memory, text_rise_px)
    Clock = lift(widget.Clock, text_rise_px)

    return bar.Bar(
        [
            widget.Spacer(length=15, background=outer),
            widget.Image(
                filename=asset(name, "launch_Icon.png"),
                margin=2,
                background=outer,
                mouse_callbacks={"Button1": lazy.spawn(ROFI_POWER)},
            ),
            # workspaces
            slice_(6),
            widget.GroupBox(
                **raised,
                font=GLYPH_FONT,
                fontsize=groupbox_fontsize,
                borderwidth=3,
                highlight_method="block",
                active=fg,
                block_highlight_text_color=palette["accent"],
                highlight_color=palette["glow"],
                inactive=inactive,
                foreground=palette["glow"],
                background=island,
                this_current_screen_border=island,
                this_screen_border=island,
                other_current_screen_border=island,
                other_screen_border=island,
                urgent_border=island,
                rounded=True,
                disable_drag=True,
                **{
                    k: v
                    for k, v in (
                        ("padding_x", groupbox_padding_x),
                        ("margin_x", groupbox_margin_x),
                    )
                    if v is not None
                },
            ),
            widget.Spacer(length=8, background=island, **raised),
            slice_(1),
            widget.CurrentLayout(
                **raised,
                mode="icon",
                custom_icon_paths=[asset(name, "layout")],
                background=island,
                scale=0.50,
            ),
            # launcher
            slice_(5),
            glyph(
                f" {GLYPH_SEARCH} ",
                background=outer,
                mouse_callbacks={"Button1": lazy.spawn(ROFI_LAUNCHER)},
            ),
            TextBox(
                fmt="Search",
                background=outer,
                mouse_callbacks={"Button1": lazy.spawn(ROFI_LAUNCHER)},
                **text(outer),
            ),
            # focused window
            slice_(4),
            # Prompt is zero-width until Mod+r opens it; it lives inside the
            # window-name island so the keybinding keeps working.
            widget.Prompt(background=island, foreground=fg, **raised),
            WindowName(
                **raised,
                background=island,
                empty_group_string="Desktop",
                max_chars=130,
                **text(island),
            ),
            # tray
            slice_(3),
            widget.Systray(background=outer, fontsize=2, padding=3),
            widget.TextBox(text=" ", background=outer),
            # system readouts
            slice_(6, background=island),
            glyph(f"{GLYPH_CPU} ", background=island, **raised),
            CPU(
                **raised,
                format="{load_percent}%",
                background=island,
                update_interval=2,
                **text(island),
            ),
            slice_(2),
            widget.Spacer(length=8, background=island, **raised),
            glyph(f"{GLYPH_MEMORY} ", background=island, **raised),
            Memory(
                **raised,
                background=island,
                format="{MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}",
                measure_mem="M",
                update_interval=5,
                **text(island),
            ),
            # clock
            slice_(5, background=island),
            glyph(f" {GLYPH_CLOCK} ", background=outer),
            Clock(
                format="%Y-%m-%d %I:%M %p",
                background=outer,
                **text(outer),
            ),
            widget.Spacer(length=18, background=outer),
        ],
        height,
        background=outer,
        opacity=opacity,
        border_color=(edge_line[0] if edge_line else outer),
        border_width=(
            # [N, E, S, W] -- the rim goes on the window-facing side.
            ([0, 0, edge_line[1], 0] if position == "top" else [edge_line[1], 0, 0, 0])
            if edge_line
            else [0, 0, 0, 0]
        ),
        margin=margin,
    )
