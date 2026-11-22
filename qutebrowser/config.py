config.load_autoconfig()

c.content.blocking.enabled = True
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
]

# ---- Theme: matches qtile's "everforest" (qtile/themes/everforest.py) ----
outer = "#232A2E"   # bar background
island = "#343F44"  # raised blocks
fg = "#86918A"
accent = "#D3C6AA"  # active workspace block in qtile
bright = "#D3C6AA"
warn = "#DBBC7F"
error = "#E67E80"
ok = "#A7C080"

c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "11pt"
c.fonts.tabs.selected = "bold default_size default_family"
c.fonts.tabs.unselected = "default_size default_family"

# Tabs: extra top/bottom gap around the title
c.tabs.padding = {"top": 7, "bottom": 7, "left": 10, "right": 10}
c.tabs.indicator.width = 0
c.tabs.favicons.show = "never"
c.tabs.title.format = "{audio}{index}  {current_title}"
c.colors.tabs.bar.bg = outer
c.colors.tabs.odd.bg = outer
c.colors.tabs.even.bg = outer
c.colors.tabs.odd.fg = fg
c.colors.tabs.even.fg = fg
c.colors.tabs.selected.odd.bg = accent
c.colors.tabs.selected.even.bg = accent
c.colors.tabs.selected.odd.fg = outer
c.colors.tabs.selected.even.fg = outer
c.colors.tabs.pinned.odd.bg = island
c.colors.tabs.pinned.even.bg = island

# Status bar
c.statusbar.padding = {"top": 5, "bottom": 5, "left": 8, "right": 8}
c.colors.statusbar.normal.bg = outer
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.insert.bg = ok
c.colors.statusbar.insert.fg = outer
c.colors.statusbar.command.bg = island
c.colors.statusbar.command.fg = bright
c.colors.statusbar.passthrough.bg = warn
c.colors.statusbar.passthrough.fg = outer
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.https.fg = ok
c.colors.statusbar.url.hover.fg = bright
c.colors.statusbar.progress.bg = accent

# Completion (the :open list)
c.colors.completion.fg = fg
c.colors.completion.odd.bg = outer
c.colors.completion.even.bg = outer
c.colors.completion.category.bg = island
c.colors.completion.category.fg = bright
c.colors.completion.category.border.top = island
c.colors.completion.category.border.bottom = island
c.colors.completion.item.selected.bg = accent
c.colors.completion.item.selected.fg = outer
c.colors.completion.item.selected.border.top = accent
c.colors.completion.item.selected.border.bottom = accent
c.colors.completion.match.fg = ok
c.colors.completion.item.selected.match.fg = outer
c.colors.completion.scrollbar.bg = outer
c.colors.completion.scrollbar.fg = fg

# Link hints (f)
c.colors.hints.bg = accent
c.colors.hints.fg = outer
c.colors.hints.match.fg = fg
c.hints.border = f"1px solid {outer}"

# Messages and prompts
c.colors.messages.info.bg = outer
c.colors.messages.info.fg = fg
c.colors.messages.info.border = outer
c.colors.messages.warning.bg = warn
c.colors.messages.warning.fg = outer
c.colors.messages.warning.border = warn
c.colors.messages.error.bg = error
c.colors.messages.error.fg = outer
c.colors.messages.error.border = error
c.colors.prompts.bg = island
c.colors.prompts.fg = bright
c.colors.downloads.bar.bg = outer

# Blank/new tabs follow the dark theme
c.colors.webpage.bg = outer
