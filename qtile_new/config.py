"""Qtile config.

Behaviour lives here — keybindings (mapped to the Corne keyboard), groups,
layout choice, window rules.  Appearance lives in themes/; pick one in
theme.py or with `scripts/theme-switch <name>`.
"""

import os
import subprocess
import sys

from libqtile import bar, hook, layout, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Rule
from libqtile.config import Screen
from libqtile.lazy import lazy

# themes/ and theme.py are siblings of this file; qtile does not always put the
# config directory on sys.path, so make the imports below reliable.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import themes  # noqa: E402

theme = themes.load()

mod = "mod4"
alt = "mod1"
terminal = "alacritty"


# █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ █▀
# █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ ▄█


def _build(layout_cls):
    """Layout choice is ours; borders and margins come from the theme."""
    kwargs = dict(theme.layout_defaults)
    kwargs.update(theme.layout_overrides.get(layout_cls.__name__, {}))
    return layout_cls(**kwargs)


layouts = [
    # First entry is the default layout for every workspace.
    _build(layout.Max),
    _build(layout.Columns),
]


def minimize_all_windows(qtile):
    group = qtile.current_group
    for window in group.windows:
        window.toggle_minimize()


# █▀▀ █░█ █░░ █░░ █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█
# █▀░ █▄█ █▄▄ █▄▄ ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█

# Super+f walks three display modes.  qtile has no single command for this, so
# we drive the four pieces that make up the gaps ourselves: the per-window
# layout margin, the screen-edge gaps the theme reserves, the bar's own margin,
# and finally the bar itself.
#
#   normal   the theme as configured
#   gapless  windows fill the screen and sit flush against the bar
#   bare     gapless, and the bar is hidden too
FULLSCREEN_MODES = ("normal", "gapless", "bare")
_fullscreen_mode = 0


def _pristine(obj, attr):
    """The value obj.attr had before we first touched it, stashed on obj.

    Call this on the way *out* of normal mode as well as on the way back in:
    the stash has to be taken before the value is zeroed, or "restore" would
    later restore a zero.
    """
    key = f"_fullscreen_original_{attr}"
    if not hasattr(obj, key):
        value = getattr(obj, attr)
        setattr(obj, key, list(value) if isinstance(value, list) else value)
    return getattr(obj, key)


def _set_gaps(qtile, keep):
    """Restore (keep=True) or zero every gap on the current screen."""
    # Each group owns its own layout instances, so a mode change has to reach
    # all of them or the margin returns the moment you switch workspace.
    for group in qtile.groups:
        for lo in group.layouts:
            for attr in ("margin", "margin_on_single"):
                if hasattr(lo, attr):
                    original = _pristine(lo, attr)
                    setattr(lo, attr, original if keep else 0)

    screen = qtile.current_screen
    for gap in screen.gaps:
        if isinstance(gap, bar.Bar):
            # A hidden bar reports zero size; show it first so the reconfigure
            # below measures real geometry.  The caller hides it again after.
            gap.show(True)
            original = _pristine(gap, "margin")
            gap.margin = list(original) if keep else [0, 0, 0, 0]
        else:
            original = _pristine(gap, "size")
            gap.size = original if keep else 0

    # Plain gaps recompute their geometry on every _configure, a bar only when
    # asked to.  Order follows Screen.gaps: a bottom bar is positioned from the
    # top gap's size, so the gaps have to be done in that order.
    for gap in list(screen.gaps):
        gap._configure(qtile, screen, reconfigure=True)


def cycle_fullscreen(qtile):
    """Super+f: normal -> gapless -> gapless with the bar hidden -> normal."""
    global _fullscreen_mode
    _fullscreen_mode = (_fullscreen_mode + 1) % len(FULLSCREEN_MODES)
    mode = FULLSCREEN_MODES[_fullscreen_mode]

    _set_gaps(qtile, keep=mode == "normal")

    screen = qtile.current_screen
    for gap in screen.gaps:
        if isinstance(gap, bar.Bar):
            gap.show(mode != "bare")
            gap.draw()
    screen.group.layout_all()


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.call(home)


# █▀▀ █░░ █▀█ ▄▀█ ▀█▀ █ █▄░█ █▀▀
# █▀░ █▄▄ █▄█ █▀█ ░█░ █ █░▀█ █▄█

# Super+shift+t turns the current workspace into a plain stacking desktop: every
# window floats, so the mouse bindings further down (Super+drag to move,
# Super+right-drag to resize) behave the way GNOME or KDE would.  Press it again
# and the windows drop back into whichever tiling layout the workspace was on.
#
# This uses qtile's real floating state rather than adding layout.Floating to
# `layouts`.  That looks like the obvious answer, but dragging a window in the
# Floating *layout* goes through set_position_floating, which marks the window
# floating for good and pulls it out of every tiling layout -- you would come
# back to Columns to find a screenful of windows still floating.  Floating the
# windows on purpose, and remembering that we did, avoids that.
#
# The mode is per-workspace, so workspace 4 can be a floating scratch desk while
# 1-3 stay tiled.  Only the windows *we* floated are re-tiled on the way out, so
# dialogs and anything floated by hand with Super+t keep the state you gave them.

# Names of the groups currently in floating mode.
_float_groups = set()

# Set on a window that this mode floated, as opposed to a float_rule or Super+t.
_FLOATED_BY_MODE = "_float_mode_owned"

# A window that fills its screen has no meaningful floating size to go back to,
# so give it one: this fraction of the screen, cascaded from the centre so a
# stack of them stays clickable instead of hiding behind each other.
FLOAT_FILL_RATIO = 0.66
FLOAT_CASCADE_PX = 32
FLOAT_CASCADE_STEPS = 8

_cascade_step = -1


def _next_cascade():
    global _cascade_step
    _cascade_step = (_cascade_step + 1) % FLOAT_CASCADE_STEPS
    return _cascade_step * FLOAT_CASCADE_PX


def _float_window(win):
    """Float one window, sizing it sensibly if it was filling the screen."""
    if win.floating or win.group is None or win.group.screen is None:
        return

    screen = win.group.screen
    # dx/dwidth rather than x/width: the usable area, with the bar and the
    # theme's screen gaps already taken off.
    sx, sy, sw, sh = screen.dx, screen.dy, screen.dwidth, screen.dheight
    x, y, w, h = win.x, win.y, win.width, win.height

    if w >= sw * 0.9 and h >= sh * 0.9:
        w, h = int(sw * FLOAT_FILL_RATIO), int(sh * FLOAT_FILL_RATIO)
        offset = _next_cascade()
        x = min(sx + (sw - w) // 2 + offset, sx + sw - w)
        y = min(sy + (sh - h) // 2 + offset, sy + sh - h)

    win.floating = True
    win.set_size_floating(w, h)
    win.set_position_floating(x, y)
    setattr(win, _FLOATED_BY_MODE, True)


def _unfloat_window(win):
    if getattr(win, _FLOATED_BY_MODE, False):
        win.floating = False
        setattr(win, _FLOATED_BY_MODE, False)


def toggle_float_mode(qtile):
    """Super+shift+t: float everything on this workspace, or re-tile it."""
    group = qtile.current_group
    turning_on = group.name not in _float_groups

    if turning_on:
        _float_groups.add(group.name)
    else:
        _float_groups.discard(group.name)

    # list(): un-floating a window mutates the group's floating layout.
    for win in list(group.windows):
        (_float_window if turning_on else _unfloat_window)(win)

    group.layout_all()


@hook.subscribe.group_window_add
def float_arriving_window(group, win):
    """Windows opened on -- or moved to -- a floating workspace float as well.

    The hook fires at the top of Group.add, before the window has been given a
    group or a position, so the float has to wait until qtile has placed it.
    """
    if group.name in _float_groups:
        qtile.call_soon(_float_window, win)


@hook.subscribe.setgroup
def float_offscreen_arrivals():
    """Catch up a floating workspace that gained windows while it was off screen.

    _float_window needs a screen to size against, so a window sent to a hidden
    floating workspace with Super+shift+N cannot be floated when it arrives.
    Do it the moment the workspace is shown instead.
    """
    group = qtile.current_group
    if group.name in _float_groups:
        for win in list(group.windows):
            _float_window(win)


# Seconds to wait before raising a window the pointer has wandered onto.  0
# raises straight away.  Nudge it up to ~0.3 if sweeping the mouse across the
# screen pops every window it crosses to the front.
FLOAT_RAISE_DELAY = 0

# Pixels added or removed per press by the Super+ctrl+hjkl resize keys when the
# focused window is floating.
FLOAT_RESIZE_STEP = 40


@hook.subscribe.client_focus
def raise_focused_float(win):
    """follow_mouse_focus only moves focus; give floating windows a raise too.

    This is the hover equivalent of the bring_to_front hung off Alt+Tab.  It is
    deliberately limited to floating windows: raising a tiled one would lift it
    over any floating dialog on the workspace, which is the very thing
    floats_kept_above exists to prevent, and on a tiled window the raise would
    not be visible anyway.
    """
    if not getattr(win, "floating", False):
        return

    if not FLOAT_RAISE_DELAY:
        win.bring_to_front()
        return

    def raise_if_still_focused():
        # The pointer may have moved on while we waited.
        if win.qtile.current_window is win:
            win.bring_to_front()

    win.qtile.call_later(FLOAT_RAISE_DELAY, raise_if_still_focused)


# █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀
# █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key(
        [mod],
        "space",
        lazy.group.next_window(),
        lazy.window.bring_to_front(),
        desc="Move window focus to other window and raise it",
    ),
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
    # Resize.  lazy.layout.grow_* only ever reaches the tiling layout's clients,
    # so on a floating window -- the whole workspace in floating mode -- it does
    # nothing at all.  Each key therefore carries both commands and lets
    # .when(when_floating=...) pick: grow_* while tiled, resize_floating while
    # floating.  h/l change width, j/k change height, which is the usual reading
    # of those keys; resize_floating keeps the top-left corner pinned and moves
    # the bottom-right one, the same corner Super+right-drag moves.
    Key(
        [mod, "control"],
        "h",
        lazy.layout.grow_left().when(when_floating=False),
        lazy.window.resize_floating(-FLOAT_RESIZE_STEP, 0).when(when_floating=True),
        desc="Grow window left / narrow a floating window",
    ),
    Key(
        [mod, "control"],
        "l",
        lazy.layout.grow_right().when(when_floating=False),
        lazy.window.resize_floating(FLOAT_RESIZE_STEP, 0).when(when_floating=True),
        desc="Grow window right / widen a floating window",
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.grow_down().when(when_floating=False),
        lazy.window.resize_floating(0, FLOAT_RESIZE_STEP).when(when_floating=True),
        desc="Grow window down / heighten a floating window",
    ),
    Key(
        [mod, "control"],
        "k",
        lazy.layout.grow_up().when(when_floating=False),
        lazy.window.resize_floating(0, -FLOAT_RESIZE_STEP).when(when_floating=True),
        desc="Grow window up / shorten a floating window",
    ),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # group.next_window rather than layout.next: layout.next only walks the
    # *tiling* layout's clients, so it does nothing at all on a workspace in
    # floating mode (Super+shift+t), where every window has been handed to the
    # floating layout instead.  next_window/prev_window cycle both.
    #
    # Focus and stacking order are separate things in qtile, so focusing a
    # buried floating window leaves it buried.  A Key runs its commands in
    # sequence, so bring_to_front raises whichever window next_window just
    # landed on.  On a tiled window it is a no-op you cannot see.
    Key(
        [alt],
        "Tab",
        lazy.group.next_window(),
        lazy.window.bring_to_front(),
        desc="Focus next window and raise it",
    ),
    Key(
        [alt, "shift"],
        "Tab",
        lazy.group.prev_window(),
        lazy.window.bring_to_front(),
        desc="Focus previous window and raise it",
    ),
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
        lazy.function(cycle_fullscreen),
        desc="Cycle gapless -> gapless with the bar hidden -> normal",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key(
        [mod, "shift"],
        "t",
        lazy.function(toggle_float_mode),
        desc="Toggle floating mode for the whole workspace",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key(
        [mod],
        "d",
        lazy.spawn(themes.ROFI_LAUNCHER),
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
    Key([mod], "Escape", lazy.spawn(themes.FIND_CURSOR)),
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


# █▀▀ █▀█ █▀█ █░█ █▀█ █▀
# █▄█ █▀▄ █▄█ █▄█ █▀▀ ▄█


# Icon labels per workspace (Nerd Font glyphs). The group *name* stays a
# number so the Super+1..4 keybindings keep working; only the label changes.
group_config = [
    ("1", "\uf120"),  # terminal
    ("2", "\uf269"),  # browser (Firefox auto-assigns here)
    ("3", "\uf121"),  # code / IDE
    ("4", "\uf07b"),  # files
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
        ]
    )


# █▄▄ ▄▀█ █▀█
# █▄█ █▀█ █▀▄


widget_defaults = theme.widget_defaults
extension_defaults = theme.extension_defaults

# A theme may reserve space at the screen edges so that the window-to-edge gap
# can be made to match the window-to-window gap; qtile's layout margin alone
# only ever gives you half as much at the edges.
_gaps = {
    side: bar.Gap(size)
    for side, size in (getattr(theme, "screen_gaps", None) or {}).items()
    if size
}

_bar_position = getattr(theme, "bar_position", "top")

screens = [Screen(**{_bar_position: theme.make_bar()}, **_gaps)]


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

# Click to focus, not hover.  "click_or_drag_only" rather than a plain False:
# the mouse bindings above act on lazy.window, which resolves to the *focused*
# window, so with focus-on-click alone a Super+drag started over an unfocused
# window would move whichever other window happened to hold focus.  This value
# makes qtile focus the hovered window first whenever a Click or Drag binding
# fires, so a drag always grabs the window you actually pointed at.
#
# Plain clicks still focus: that path is qtile's own _grab_click, which grabs
# buttons 1-3 on unfocused windows in Sync mode and replays the event to the
# client afterwards, and it does not depend on this setting at all.
follow_mouse_focus = "click_or_drag_only"
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    **theme.floating_defaults,
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
