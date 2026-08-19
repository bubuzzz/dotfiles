"""Gruvbox — the original hand-rolled look.

Transparent bar, qtile-extras rounded pills for the system readouts, thick
soft borders on the windows themselves.
"""

from libqtile import bar, widget
from libqtile.lazy import lazy
from qtile_extras import widget as ewidget
from qtile_extras.widget.decorations import RectDecoration

from themes import ROFI_POWER

NAME = "gruvbox"

palette = {
    "bg": "#28282800",
    "fg": "#ebdbb2",
    "active": "#d79921",
    "inactive": "#928374",
    "highlight": "#d65d0e",
    "urgent": "#cc241d",
    "gray": "#3c3836",
    "blue": "#458588",
    "green": "#98971a",
}

# Icon/label widgets (logo, GroupBox, power) use the larger size;
# general bar text uses the smaller widget_defaults size.
BAR_FONTSIZE = 16

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

layout_defaults = {
    "border_focus": "#83a59840",
    "border_normal": "#ebdbb280",
    "border_width": 4,
    "margin": [0, 3, 3, 3],  # [top, right, bottom, left] - no gap against the top bar
    "border_on_single": True,
}

# Max gets a warmer inactive border than the tiling layouts.
layout_overrides = {
    "Max": {"border_normal": "#83a59880"},
}

floating_defaults = {
    "border_focus": "#8ec07c",  # Active/focused floating border
    "border_normal": "#ebdbb2",  # Inactive floating border
    "border_width": 3,
}


def _block_decor(colour):
    """Rounded pill, inset from the top/bottom of the bar."""
    return [
        RectDecoration(
            colour=colour,
            radius=2,
            filled=True,
            padding_x=0,
            padding_y=4,
            group=True,
        )
    ]


def make_bar():
    return bar.Bar(
        [
            widget.TextBox(
                text=" \uf303 ",
                foreground=palette["active"],
                background=palette["bg"],
                fontsize=BAR_FONTSIZE,
                padding=8,
            ),
            widget.GroupBox(
                font="JetBrainsMono Nerd Font Mono",
                fontsize=21,
                active=palette["fg"],
                inactive=palette["fg"],
                highlight_method="block",
                block_highlight_text_color=palette["fg"],
                this_current_screen_border=palette["blue"],
                this_screen_border=palette["blue"],
                other_current_screen_border=palette["green"],
                other_screen_border=palette["gray"],
                rounded=True,
                disable_drag=True,
                borderwidth=0,
                margin_x=4,  # gap between blocks
                margin_y=5,  # vertical inset -> block height (bar 36 - 2*5 = 26)
                padding_x=9,  # horizontal inset -> widen block toward a square
                padding_y=0,
            ),
            widget.Prompt(
                foreground=palette["fg"],
                background=palette["bg"],
            ),
            widget.Spacer(background=palette["bg"]),
            widget.WindowName(
                foreground=palette["fg"],
                background=palette["bg"],
                max_chars=255,
                padding=8,
                width=bar.CALCULATED,
            ),
            widget.Spacer(background=palette["bg"]),
            widget.Spacer(length=5, background=palette["bg"]),
            ewidget.CPU(
                format="\ue266 {load_percent}%",
                foreground=palette["fg"],
                background=palette["bg"],
                padding=10,
                decorations=_block_decor(palette["green"]),
            ),
            widget.Spacer(length=5, background=palette["bg"]),
            ewidget.Memory(
                format="\uf85a {MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}",
                measure_mem="M",
                foreground=palette["fg"],
                background=palette["bg"],
                padding=10,
                decorations=_block_decor(palette["blue"]),
            ),
            widget.Spacer(length=5, background=palette["bg"]),
            widget.Systray(
                background=palette["bg"],
                padding=3,
            ),
            ewidget.Clock(
                format=" %Y-%m-%d %I:%M %p",
                foreground=palette["fg"],
                padding=10,
            ),
            widget.TextBox(
                text=" ⏻ ",
                foreground=palette["urgent"],
                background=palette["bg"],
                fontsize=BAR_FONTSIZE,
                padding=8,
                mouse_callbacks={"Button1": lazy.spawn(ROFI_POWER)},
            ),
        ],
        36,
        background=palette["bg"],
        margin=[0, 0, 0, 0],
    )
