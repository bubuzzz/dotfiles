# Theming notes

How this config is put together, and the non-obvious things that cost time to
work out. Read this before adding a theme.

## Layout

```
config.py            behaviour only -- keys, groups, layouts, rules
theme.py             DEFAULT_THEME + the list of available themes
themes/
  __init__.py        loader, shared paths (rofi scripts), asset() helper
  _cozytile.py       the shared Cozytile bar; leading _ = helper, not a theme
  gruvbox.py         standalone theme (qtile_extras pills, own picom)
  cozy.py            \
  sakura.py           |  palette + the tuned constants, all delegating
  everforest.py       |  to _cozytile.  Identical apart from colour.
  carbon.py           |  carbon inverts the scheme -- see Gotchas.
  natura.py          /
  assets/
    shared/          picom-cozytile.conf  upstream baseline, unused now
                     picom-tuned.conf     what the five Cozytile themes symlink
    <theme>/         1..6.png slices, launch_Icon.png, layout/, picom.conf
    <theme>/flat/    untouched slice originals; the gradient generator reads
                     these and writes the parent, so runs never compound
scripts/theme-switch          validate -> write current_theme -> reload picom -> restart qtile
scripts/picom-reload          picks the active theme's picom.conf
scripts/gen-gradient-slices.py  bakes a gradient into a theme's slice PNGs
```

Theme selection: `$QTILE_THEME` > `~/.config/qtile/current_theme` > `theme.DEFAULT_THEME`.
`themes.load()` falls back to the default and logs a traceback if a theme raises,
so a broken theme can never leave you without a bar.

## Theme contract

Required: `NAME`, `palette`, `widget_defaults`, `extension_defaults`,
`layout_defaults`, `layout_overrides`, `floating_defaults`, `make_bar()`.

Optional, read with `getattr` in config.py so old themes keep working:
`screen_gaps`, `bar_position`.

Palette keys: `outer, island, fg, accent, glow, border, float`, plus two
optional ones that fall back so the dark themes need neither --

- `fg_outer` — text on the bar background, when one colour will not do. Only
  carbon sets it: light islands on a dark bar means dark text on the islands
  and light text off them.
- `inactive` — empty-workspace icons, default `outer`. Fine on a dark island;
  on carbon's pale one the default collides with the active colour.

Anything that changes *behaviour* belongs in config.py, never in a theme.
Themes are verified to differ only in appearance: keys, groups, mouse, rules
and misc settings must be identical across all of them.

## Adding a Cozytile-family theme

1. Copy the slice PNGs from the upstream repo into `assets/<name>/`
   (`1..6.png`, `launch_Icon.png`, `layout/`).
2. Symlink `assets/<name>/picom.conf -> ../shared/picom-tuned.conf`. Fork a copy
   into the theme's own directory only if it needs to diverge.
3. Add a stops entry for the theme to `scripts/gen-gradient-slices.py`, then run
   it. **Size the stops to that theme's own island/outer separation** -- this is
   the step that needs thought, not copying. See Gotchas.
4. Write `themes/<name>.py`: the palette, then the tuned constants block copied
   from an existing theme, then delegate to `_cozytile.make_bar()`. Pick a rim
   colour: a lightened island for the dark themes, a dark line for carbon, whose
   pale islands take up most of the bar's width.
5. Add the name to `AVAILABLE_THEMES` in `theme.py`.
6. `scripts/theme-switch <name>`, then diff it against everforest (see
   Verifying a change) to confirm only colour differs.

Upstream ships `border_width = 0` for every theme and leans on picom's shadows
and corner radius to separate windows. If your picom has `shadow = false`,
windows will look merged -- give the theme a real border width.

## Gotchas

These are all things that fail *silently*. Nothing errors; you just get the
wrong pixels.

**Decorations need widgets imported from `qtile_extras.widget`.**
`libqtile.widget.X` and `qtile_extras.widget.X` are the *same class object*, but
the decoration-drawing hook (`new_clear`) is only injected on attribute access
through `qtile_extras`. A libqtile-built widget accepts `decorations=[...]` and
throws it away. Symptom: PNG slices show the effect, widgets stay flat.

**`widget_defaults` padding applies to Image widgets too.**
`padding=3` leaves a 3px gutter of bar background down each side of every slice,
which reads as a dark vertical separator between sections. `slice_()` sets
`padding=0`. Invisible while islands are flat; obvious once they are shaded.

**Bar text sits low and there is no setting for it.**
`_TextBox.draw` uses `y = (bar.size - layout.height) / 2 + 1` -- a hardcoded
+1px -- and centres the layout box, which includes descent space. Pango's `rise`
attribute does *not* fix it (the layout's logical extents absorb the shift; 4px
of rise moved nothing). What works is `_cozytile.lift()`: subclass the widget and
wrap the *TextLayout's* draw call, which moves glyphs only and leaves the
background, decorations and widget width untouched. `self.layout` is created once
in `_configure` and only cleared in `finalize`, so the wrap is stable.

**picom 13 only honours `shadow = true/false` per rule.**
`shadow-opacity`, `shadow-radius` and `shadow-offset-*` inside a `rules:` block
parse without complaint and are silently ignored. Verified by A/B: 0.9 vs 0.25
produced zero measurable difference. Shadow *strength* can only be changed
globally, which affects window shadows too.

**The qtile bar has no `WM_CLASS` and no `_NET_WM_WINDOW_TYPE`.**
It carries only `QTILE_INTERNAL`. Every `class_g = 'qtile'` rule you find online
matches nothing. Use `match = "QTILE_INTERNAL@ = 1"`. (The `@:c` type suffix is
deprecated in picom 13.)

**Set bar transparency in qtile, not picom.** `bar.Bar(opacity=...)` sets
`_NET_WM_WINDOW_OPACITY` directly and sidesteps the matching problem entirely.

**A shadow is unreliable separation.** It only managed ~16 levels of darkening
against a bright wallpaper and depends entirely on what is behind it. A 1px rim
drawn by qtile itself (`bar.Bar(border_width=..., border_color=...)`) is the same
brightness over anything. Put it on the window-facing edge, derived from
`bar_position` so it follows the bar when it moves.

**Gradients must be baked into the slice PNGs as well.** The islands do not end
where the widgets end -- the 1..6 PNGs carry the island colour in their pixels,
so a widget-only gradient leaves a flat notch at both ends of every island. Run
`scripts/gen-gradient-slices.py <theme>` after changing the stops. The generator
recovers each pixel's blend factor from the anti-aliased edges rather than
matching colours exactly, so the curved boundaries stay smooth.

Keep gradient stops **centred on the flat island colour**. Pushing the average
brighter makes the islands stop matching the rest of the palette.

**Size the stops per theme, from its island/outer separation.** Every theme
needs its own entry in the generator and they are not interchangeable:

| theme | island vs outer | note |
| --- | --- | --- |
| everforest | ~17 levels | the reference: +16 / -14 |
| cozy, sakura | ~13 levels | lower stop pulled in, or the island's bottom edge dissolves into the bar |
| natura | ~17, but very dark | lower stop held 5 levels clear of the bar |
| carbon | inverted | same light-to-dark ramp, around a much brighter centre |

The rule that matters: the bottom stop must stay a few levels clear of `outer`,
or the island melts into the bar along its lower edge.

A vertical gradient (`points=[(0,0),(0,1)]`) renders identically in every widget,
so `group=True` is unnecessary and there are no seams between widgets.

**A collapsed palette key can render invisible.** `_cozytile` uses one `glow`
for both the GroupBox's `highlight_color` and its `foreground`. Upstream sets
those to the same value in four themes but *different* values in carbon, where
the collapse produced `#CCCCCC` text on a `#CCCCCC` island. Dump every
surface/ink pair after adding a theme rather than eyeballing the bar.

**Shading needs height.** A ramp across a 30px bar is imperceptible. It only
started reading at 38px. A hard bevel edge is visible at any height but fights
the flat slices unless baked into them too.

**A uniform gap takes three pieces.** qtile's layout `margin` is per-window, so
two neighbours end up `GAP` apart but a window sits only `GAP/2` from the screen
edge. Add `screen_gaps` (`bar.Gap`) to make up the other half, and the same again
on the bar's window-facing margin. Columns is then exact; Max lands 1px off,
because the two layouts account for borders differently.

Thickening `BORDER_WIDTH` does not change the gaps -- the layout margin is
measured outside the border.

**Bash heredocs eat private-use glyphs.** Nerd Font icons written into a heredoc
can arrive as empty strings. Write them as `\uXXXX` escapes in the Python source
and verify with `[hex(ord(c)) for c in s]`.

**`picom-reload` must detach.** Without `setsid` and redirected output picom
inherits the caller's stdout, which hangs anything waiting on output and kills
picom when that caller is killed.

## Verifying a change

`qtile check` only confirms the config is valid Python -- it says nothing about
appearance. What actually catches problems:

- Load two configs in subprocesses and diff their fully-resolved keys, groups,
  layouts, rules and widget chain. This is how the gruvbox extraction was proven
  behaviour-preserving.
- `qtile cmd-obj -o bar top -f info` gives real widget offsets and lengths.
- Dump every `(background, foreground)` pair a theme's widgets use and assert
  none are equal. This is what caught carbon's invisible GroupBox.
- `import -window root -crop WxH+X+Y` plus PIL measures actual pixels. This is
  the only way to catch silent rendering failures, and it found every one of the
  gotchas above.
- When comparing screenshots, capture both sides close together and check that
  rows *outside* the area of interest are unchanged -- otherwise the desktop
  moved under you and the comparison is worthless.

## The themes

`gruvbox` is the original standalone look and shares none of this: qtile_extras
pills, transparent 36px top bar, its own picom with shadows off.

The five Cozytile themes are identical apart from colour -- same 27-widget bar,
same geometry, same constants -- and all symlink `picom-tuned.conf`:

| | outer | island | character |
| --- | --- | --- | --- |
| natura | `#0F1212` | `#202222` | darkest, muted green text |
| everforest | `#232A2E` | `#343F44` | forest grey-green |
| cozy | `#282738` | `#353446` | purple, blue accent |
| sakura | `#282738` | `#353446` | same tones as cozy, pink/lilac accents |
| carbon | `#333333` | `#CCCCCC` | inverted -- light islands on a dark bar |

The constants block each one carries, and what it departs from upstream on:

```python
bar_position       = "bottom"      # upstream: top
BAR_HEIGHT         = 32            # upstream: 30
BAR_OPACITY        = 0.9           # upstream: opaque
BAR_EDGE_LINE      = (colour, 1)   # upstream: none
GRADIENT           = (top, bottom) # upstream: flat; regen slices after changing
TEXT_RISE_PX       = 2             # upstream: qtile's low baseline
GAP                = 8             # upstream: margin 9, no screen gaps
BORDER_WIDTH       = 4             # upstream: 0
BORDER_FOCUS       = palette["island"]   # lighter = focused
BORDER_NORMAL      = palette["outer"]
GROUPBOX_FONTSIZE  = 16            # upstream: 24
GROUPBOX_PADDING_X = 8             # upstream: unset
GROUPBOX_MARGIN_X  = 5             # upstream: unset
```

`picom-tuned.conf` is a fork of the upstream Cozytile config: `corner-radius = 6`,
square bar via the `QTILE_INTERNAL` rule, no animations, no fading, and a
stronger shadow (`0.7` / radius `20`) raised for the bar's sake -- which also
darkens the gaps between tiled windows. `picom-cozytile.conf` is kept beside it
as the untouched upstream baseline; nothing symlinks it now.

Carbon also departs on its workspace indicators: upstream's `#333333` current /
`#555555` active / `#C2C2C2` inactive gives two near-identical darks and an
invisible third, so it uses `#1A1A1A` / `#474747` / `#9A9A9A` instead.

Natura and everforest both keep upstream's `glow = #4B427E`, a leftover of Cozy's
purple. It is inert under `highlight_method "block"` and never renders, so it is
left as shipped rather than invented.
