import os


import libqtile.resources
from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, Rule
from libqtile.lazy import lazy
from qtile_extras import widget as ewidget
from qtile_extras.widget.decorations import RectDecoration
from libqtile import hook
import subprocess


mod = "mod4"
alt = "mod1"
terminal = "xfce4-terminal -e tmux"


def minimize_all_windows(qtile):
    group = qtile.current_group
    for window in group.windows:
        window.toggle_minimize()


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.call(home)


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([alt], "Tab", lazy.layout.next(), desc="Focus next window"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key(
        [alt],
        "d",
        lazy.spawn("/home/bubuzzz/.config/rofi/scripts/launcher_simple"),
        desc="Launch Rofi app launcher",
    ),
    Key(
        [],
        "F11",
        lazy.function(minimize_all_windows),
        desc="Minimize all windows (show desktop)",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key(
        [],
        "XF86AudioMicMute",
        lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
    ),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 4):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


# Icon labels per workspace (Nerd Font glyphs). The group *name* stays a
# number so the Super+1..4 keybindings keep working; only the label changes.
group_config = [
    ("1", ""),  # terminal
    ("2", ""),  # browser (Firefox auto-assigns here)
    ("3", ""),  # code / IDE
    ("4", ""),  # files
]
groups = [Group(name, label=label) for name, label in group_config]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_conf = {
    "border_focus": "#83a59840",  # "#98971a80",
    "border_normal": "#ebdbb280",
    "border_width": 4,
    "margin": [0, 3, 3, 3],  # [top, right, bottom, left] - no gap against the top bar
    "border_on_single": True,
}

layouts = [
    # First entry is the default layout for every workspace.
    layout.Max(
        border_focus="#83a59840",
        border_normal="#83a59880",
        border_width=4,
        margin=[0, 3, 3, 3],  # [top, right, bottom, left] - no gap against the top bar
        border_on_single=True,  # <-- Enable border in Max layout too
    ),
    layout.Columns(**layout_conf),
]

# Icon/label widgets (logo, GroupBox, power) use the larger size;
# general bar text uses the smaller widget_defaults size.
BAR_FONTSIZE = 16

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

logo = os.path.join(os.path.dirname(libqtile.resources.__file__), "logo.png")
colors = {
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


def block_decor(colour):
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


screens = [
    Screen(
        top=bar.Bar(
            [
                widget.TextBox(
                    text="   ",
                    foreground=colors["active"],
                    background=colors["bg"],
                    fontsize=BAR_FONTSIZE,
                    padding=8,
                ),
                widget.GroupBox(
                    font="JetBrainsMono Nerd Font Mono",
                    fontsize=BAR_FONTSIZE,
                    active=colors["inactive"],
                    inactive=colors["inactive"],
                    highlight_method="block",
                    block_highlight_text_color=colors["fg"],
                    this_current_screen_border=colors["blue"],
                    this_screen_border=colors["blue"],
                    other_current_screen_border=colors["green"],
                    other_screen_border=colors["gray"],
                    rounded=True,
                    disable_drag=True,
                    borderwidth=0,
                    margin_x=4,  # gap between blocks
                    margin_y=5,  # vertical inset -> block height (bar 36 - 2*5 = 26)
                    padding_x=9,  # horizontal inset -> widen block toward a square
                    padding_y=0,
                ),
                widget.Prompt(
                    foreground=colors["fg"],
                    background=colors["bg"],
                ),
                widget.Spacer(background=colors["bg"]),
                widget.WindowName(
                    foreground=colors["fg"],
                    background=colors["bg"],
                    max_chars=255,
                    padding=8,
                    width=bar.CALCULATED,
                ),
                widget.Spacer(background=colors["bg"]),
                ewidget.Net(
                    interface="wlp4s0",
                    format=" {down} ↓↑ {up} ",
                    foreground=colors["fg"],
                    background=colors["bg"],
                    padding=10,
                    decorations=block_decor(colors["highlight"]),
                ),
                widget.Spacer(length=5, background=colors["bg"]),
                ewidget.CPU(
                    format=" {load_percent}%",
                    foreground=colors["fg"],
                    background=colors["bg"],
                    padding=10,
                    decorations=block_decor(colors["green"]),
                ),
                widget.Spacer(length=5, background=colors["bg"]),
                ewidget.Memory(
                    format=" {MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}",
                    measure_mem="M",
                    foreground=colors["fg"],
                    background=colors["bg"],
                    padding=10,
                    decorations=block_decor(colors["blue"]),
                ),
                # widget.PulseVolume(
                #     step=5,
                #     limit_max_volume=True,
                #     fmt=" {}%",
                #     foreground=colors["highlight"],
                #     background=colors["bg"],
                #     padding=6,
                #     mouse_callbacks={
                #         "Button1": lazy.spawn("pavucontrol"),
                #         "Button3": lazy.spawn(
                #             "pactl set-sink-mute @DEFAULT_SINK@ toggle"
                #         ),
                #         "Button4": lazy.spawn(
                #             "pactl set-sink-volume @DEFAULT_SINK@ +5%"
                #         ),
                #         "Button5": lazy.spawn(
                #             "pactl set-sink-volume @DEFAULT_SINK@ -5%"
                #         ),
                #     },
                # ),
                widget.Systray(
                    background=colors["bg"],
                    padding=3,
                ),
                widget.Clock(
                    format="%Y-%m-%d %I:%M %p",
                    foreground=colors["fg"],
                    background=colors["bg"],
                    padding=8,
                ),
                widget.TextBox(
                    text=" ⏻ ",
                    foreground=colors["urgent"],
                    background=colors["bg"],
                    fontsize=BAR_FONTSIZE,
                    padding=8,
                    mouse_callbacks={
                        "Button1": lazy.spawn(
                            "/home/bubuzzz/.config/rofi/scripts/power"
                        ),
                    },
                ),
            ],
            36,
            background=colors["bg"],
            margin=[0, 0, 0, 0],
        )
    )
]

# screens = [
#     Screen(
#         bottom=bar.Bar(
#             [
#                 widget.CurrentLayout(),
#                 widget.GroupBox(),
#                 widget.Prompt(),
#                 widget.WindowName(),
#                 widget.Chord(
#                     chords_colors={
#                         "launch": ("#ff0000", "#ffffff"),
#                     },
#                     name_transform=lambda name: name.upper(),
#                 ),
#                 widget.TextBox("default config", name="default"),
#                 widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
#                 # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
#                 # widget.StatusNotifier(),
#                 widget.Systray(),
#                 widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
#                 widget.QuickExit(),
#             ],
#             24,
#             # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
#             # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
#         ),
#         background="#000000",
#         wallpaper=logo,
#         wallpaper_mode="center",
#         # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
#         # By default we handle these events delayed to already improve performance, however your system might still be struggling
#         # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
#         # x11_drag_polling_rate = 60,
#     ),
# ]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


dgroups_key_binder = None
dgroups_app_rules = [
    Rule(Match(wm_class="firefox"), group="2", intrusive=True),
    # Editors -> workspace 3
    Rule(Match(wm_class="Emacs"), group="3", intrusive=True),
    Rule(Match(wm_class="dev.zed.Zed"), group="3", intrusive=True),
]

follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus="#8ec07c",  # Active/focused floating border (Gruvbox yellow)
    border_normal="#ebdbb2",  # Inactive floating border (Gruvbox light)
    border_width=3,  # Match your main border border_width
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
