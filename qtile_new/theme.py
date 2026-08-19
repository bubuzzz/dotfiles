"""Theme selection — this is the only file you need to touch to change the look.

Resolution order (first hit wins):

  1. the ``QTILE_THEME`` environment variable
  2. the ``~/.config/qtile/current_theme`` file, written by ``scripts/theme-switch``
  3. ``DEFAULT_THEME`` below

Themes only carry *appearance* — colours, fonts, the bar, window borders.
Keybindings, groups and layout choices live in ``config.py`` and never change
when you switch theme.
"""

DEFAULT_THEME = "gruvbox"

# Every module in ~/.config/qtile/themes/ that implements the theme contract.
AVAILABLE_THEMES = (
    "gruvbox",
    "cozy",
    "everforest",
    "sakura",
    "carbon",
    "natura",
)
