# reader — notes for Claude

Terminal article reader: URL -> clean Markdown -> glow/less. Used mainly from
newsboat (`browser "reader %u"`) inside tmux. User reads without a mouse, so
output must wrap (no horizontal scrolling) and have no image gaps.
Design: `DESIGN.md`. Usage: `README.md`.

## Layout (src/reader/)

- `cli.py`      argparse; entry point is `run()` (handles BrokenPipe/Ctrl-C)
- `fetch.py`    URL / file / stdin -> `Document(kind=html|pdf, url, text|data)`;
                other content types raise `UnsupportedContent`
- `pdf.py`      PDF -> Markdown via poppler `pdftotext` + `pdfinfo`, with
                hard-wrapped lines reflowed into paragraphs
- `pipeline.py` `page_to_markdown(html, base_url)`: site handler first, else
                generic extract + convert
- `extract.py`  generic: `sites.toml` selector -> `<article>`/`<main>` ->
                text-density scoring (`_best_block`). `clean()` removes
                DROP_TAGS, hidden elements, and class/id words in JUNK_WORDS
- `markdown.py` `Converter`: tag whitelist -> Markdown, links as `text [n]`
                with a `## Links` list at the end
- `handlers.py` custom per-site converters (`HANDLERS` dict by exact host),
                currently Hacker News (comments as nested `>` quotes)
- `sites.toml`  per-site `content` selector + `drop` selectors (host suffix match)
- `render.py`   glow if installed, else hard-wrap prose + `less -R`

## Decisions / gotchas

- Links in feeds are not always HTML (e.g. a Lobsters story was a PDF and
  showed as garbage). Type is detected from Content-Type and `%PDF-` magic.
  pdftotext puts bullet glyphs on their own lines; those lines are dropped.
- **User agent is honest (`reader/0.1`).** HN returns 419 for a spoofed
  Firefox UA coming from python-requests (TLS fingerprint mismatch). Don't
  switch back to a browser UA.
- Link list lines are escaped `\[n\] <url>`, not `[n]: url`: Markdown treats
  the latter as reference definitions and glow hides them.
- Link text equal to its URL is printed as `<url>`, without a ref number.
- Images inside `<a>` are dropped (badges/logos). Other images become
  `[image: alt]`, or nothing without alt.
- Tables containing block elements are layout tables: rendered as blocks,
  not as a Markdown table (HN and old sites are all tables).
- Several `<article>` tags means a listing page, so the generic path falls
  through to scoring instead of picking one.
- HN markup for logged-out users has no `.hnuser` class; see `USER_SEL`.
- An LLM (local Ollama, CPU only) was tried for formatting: ~10 min per page
  and it reworded content. Rejected; keep this deterministic.

## Dev

- Managed with uv. Installed via `uv tool install -e .` (editable), so source
  edits apply to `~/.local/bin/reader` immediately.
- Tests: `uv run pytest`. Fixtures in `tests/fixtures/` (saved HTML).
  When fixing a site, save its HTML as a fixture and add an assertion.
- Quick check: `uv run reader -r URL | head`.
- To add a site: selector in `sites.toml` first; a handler only when the
  structure needs it (threads, nested comments).

## Ideas not done yet

- Emacs command: `reader -r` into a markdown-mode buffer.
- `ddg` shell function piping search results into reader.
- More handlers: lobste.rs comment threads, Reddit (old.reddit.com).
