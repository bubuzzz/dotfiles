# reader

Show a web page as clean Markdown in the terminal: no images, ads, menus or
sideways scrolling. See `DESIGN.md` for how it works.

## Install

    cd reader
    uv tool install -e .      # puts `reader` in ~/.local/bin
    sudo pacman -S glow       # optional, nicer rendering (falls back to less)

`-e` means edits to the source take effect immediately.

## Use

    reader https://example.com/post        # view (glow, or less)
    reader -r URL > post.md                # raw Markdown to stdout
    reader -o post.md URL                  # view and save
    reader -p less URL                     # force less
    reader page.html / reader -            # local file / stdin

Links show as `text [3]`; the URLs are listed at the end.

## newsboat

In `~/.config/newsboat/config`:

    browser "reader %u"
    macro w set browser "w3m %u" ; open-in-browser ; set browser "reader %u"

`o` opens in reader, `,w` opens the original page in w3m.

## Adding sites

- Simple: add a CSS selector to `src/reader/sites.toml`.
- Complex layouts: write a handler in `src/reader/handlers.py`
  (see `hacker_news`) and register it in `HANDLERS`.

## Tests

    uv run pytest
