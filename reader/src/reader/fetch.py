"""Load HTML from a URL, a local file, or stdin."""

import sys
from pathlib import Path

import requests

USER_AGENT = "reader/0.1 (terminal article reader)"
TIMEOUT = 20


def load(source: str) -> tuple[str, str]:
    """Return (html, base_url) for a URL, a file path, or '-' for stdin."""
    if source == "-":
        return sys.stdin.read(), ""
    if source.startswith(("http://", "https://")):
        resp = requests.get(
            source, headers={"User-Agent": USER_AGENT}, timeout=TIMEOUT
        )
        resp.raise_for_status()
        # requests falls back to ISO-8859-1 for text/html without a charset
        if resp.encoding is None or resp.encoding.lower() == "iso-8859-1":
            resp.encoding = resp.apparent_encoding
        return resp.text, resp.url
    return Path(source).read_text(errors="replace"), ""
