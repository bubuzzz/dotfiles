# reader — design

Goal: `reader <url>` shows a clean, wrapped Markdown page in the terminal.
No image gaps, no clutter. Works from newsboat, the shell, w3m and Emacs.

## Pipeline

    URL -> fetch -> extract main content -> clean -> to Markdown -> render

1. **Fetch**: `requests`, normal user agent, timeout. Also accepts a local
   file or stdin (useful for tests).
2. **Extract** (the hard part):
   - site rules first (HN item page, GitHub README, lobste.rs): one CSS
     selector each, kept in `sites.toml`
   - then `<article>`, `<main>`, `[role=main]`
   - fallback: the block with the most paragraph text and the fewest links
3. **Clean**:
   - drop script, style, noscript, iframe, svg, canvas, form, button, nav,
     header, footer, aside, and hidden elements
   - drop class/id matching share, social, cookie, newsletter, subscribe,
     related, promo, ad, banner
   - images: `[image: alt]`, or removed if no alt (kills the big gaps)
4. **To Markdown**, whitelist only:
   h1-h6, p, pre/code (language from class), ul/ol/li, blockquote, table,
   strong/em, hr, a. Everything else is unwrapped to text.
5. **Render**: `glow -p` if installed, else `fold | less`.
   `--raw` prints Markdown to stdout (pipe, save, Emacs).

## Layout

    reader/
      reader.py         single file to start
      sites.toml        per-site selectors
      tests/fixtures/   saved HTML + expected .md
      README.md

Symlinked to `~/.local/bin/reader`.

Dependencies (pacman, not pip): python-beautifulsoup4, python-lxml, glow.

## Integration

- newsboat: `browser "reader %u"`
- shell: `reader <url>`
- Emacs: command running `reader --raw` into a markdown-mode buffer

## Open decisions

1. Extraction: own heuristics (recommended) / readability-lxml / reuse rdrview
2. Links: numbered refs `text [3]` with URLs at the end (recommended) /
   inline `[text](url)` / drop links
3. Location: this dotfiles repo, `reader/` (recommended) / separate repo /
   `~/.local/bin` only
