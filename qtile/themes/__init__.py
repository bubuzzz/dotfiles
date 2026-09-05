"""Theme loader and the values every theme is allowed to share.

A theme module must define:

    NAME                str
    palette             dict[str, str]
    widget_defaults     dict          -> qtile's ``widget_defaults``
    extension_defaults  dict          -> qtile's ``extension_defaults``
    layout_defaults     dict          -> kwargs common to every tiling layout
    layout_overrides    dict          -> {"Max": {...}}, per-layout kwarg overrides
    floating_defaults   dict          -> kwargs for ``layout.Floating``
    make_bar()          -> bar.Bar    -> the top bar

Nothing else. Anything that changes *behaviour* belongs in config.py.
"""

import importlib
import os

CONFIG_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
CURRENT_THEME_FILE = os.path.join(CONFIG_DIR, "current_theme")

# Commands the bar shares with the keybindings, so both themes drive the same
# scripts and there is exactly one place to fix if a path moves.
ROFI_LAUNCHER = os.path.join(CONFIG_DIR, "..", "rofi", "scripts", "launcher_simple")
ROFI_LAUNCHER = os.path.normpath(ROFI_LAUNCHER)
ROFI_POWER = os.path.normpath(
    os.path.join(CONFIG_DIR, "..", "rofi", "scripts", "power")
)
FIND_CURSOR = "xfce4-find-cursor --color #3b82f6 --circle-size 10"


def asset(theme_name, *parts):
    """Absolute path to a file under themes/assets/<theme_name>/."""
    return os.path.join(ASSETS_DIR, theme_name, *parts)


def selected_name():
    """Name of the theme to load, without importing it."""
    import theme as theme_settings

    from_env = os.environ.get("QTILE_THEME")
    if from_env:
        return from_env.strip()

    try:
        with open(CURRENT_THEME_FILE) as fh:
            name = fh.read().strip()
        if name:
            return name
    except OSError:
        pass

    return theme_settings.DEFAULT_THEME


def load():
    """Import the selected theme, falling back to the default if it is broken.

    A typo in ``current_theme`` or a syntax error in a theme must never leave
    you staring at a bare screen, so the fallback is deliberate and loud.
    """
    import theme as theme_settings

    name = selected_name()
    try:
        return importlib.import_module(f"themes.{name}")
    except Exception:
        import logging

        logging.exception("qtile: theme %r failed to load, falling back", name)
        return importlib.import_module(f"themes.{theme_settings.DEFAULT_THEME}")
