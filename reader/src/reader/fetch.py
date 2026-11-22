"""Load a document from a URL, a local file, or stdin."""

import sys
from dataclasses import dataclass
from pathlib import Path

import requests

USER_AGENT = "reader/0.1 (terminal article reader)"
TIMEOUT = 20


class UnsupportedContent(Exception):
    pass


@dataclass
class Document:
    kind: str  # "html" or "pdf"
    url: str  # final URL after redirects, "" for files/stdin
    text: str = ""  # HTML source when kind == "html"
    data: bytes = b""  # raw bytes when kind == "pdf"


def _kind(content_type: str, data: bytes) -> str:
    ct = content_type.split(";")[0].strip().lower()
    if data.lstrip()[:5] == b"%PDF-" or ct == "application/pdf":
        return "pdf"
    if not ct or ct.startswith("text/") or "html" in ct or "xml" in ct:
        return "html"
    raise UnsupportedContent(f"cannot read this type of content: {ct}")


def load(source: str) -> Document:
    """Return a Document for a URL, a file path, or '-' for stdin."""
    if source.startswith(("http://", "https://")):
        resp = requests.get(
            source, headers={"User-Agent": USER_AGENT}, timeout=TIMEOUT
        )
        resp.raise_for_status()
        kind = _kind(resp.headers.get("Content-Type", ""), resp.content[:1024])
        if kind == "pdf":
            return Document("pdf", resp.url, data=resp.content)
        # requests falls back to ISO-8859-1 for text/html without a charset
        if resp.encoding is None or resp.encoding.lower() == "iso-8859-1":
            resp.encoding = resp.apparent_encoding
        return Document("html", resp.url, text=resp.text)

    data = sys.stdin.buffer.read() if source == "-" else Path(source).read_bytes()
    if _kind("", data) == "pdf" or source.lower().endswith(".pdf"):
        return Document("pdf", "", data=data)
    return Document("html", "", text=data.decode("utf-8", errors="replace"))
