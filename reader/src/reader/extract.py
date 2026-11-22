"""Find and clean the main content block of a page."""

import re
import tomllib
from importlib import resources
from urllib.parse import urlparse

from bs4 import BeautifulSoup, Comment, Tag

# Tags that never contain readable content.
DROP_TAGS = [
    "script", "style", "noscript", "iframe", "svg", "canvas", "form",
    "button", "input", "select", "textarea", "nav", "footer", "aside",
    "template", "object", "embed", "dialog", "link", "meta",
]

# class/id fragments that mark clutter. Matched as whole words inside
# the class/id string (split on - _ and spaces).
JUNK_WORDS = {
    "share", "sharing", "social", "cookie", "cookies", "consent", "newsletter",
    "subscribe", "subscription", "related", "promo", "advert", "ad", "ads",
    "banner", "sponsor", "sponsored", "popup", "modal", "sidebar", "breadcrumb",
    "breadcrumbs", "masthead", "signup", "paywall", "outbrain", "taboola",
    "skip", "toolbar", "disqus",
}

_WORD_SPLIT = re.compile(r"[\s_\-]+")


def _site_rules(base_url: str) -> dict:
    if not base_url:
        return {}
    host = urlparse(base_url).hostname or ""
    rules = tomllib.loads(
        resources.files("reader").joinpath("sites.toml").read_text()
    )
    for key, rule in rules.items():
        if host == key or host.endswith("." + key):
            return rule
    return {}


def _is_hidden(tag: Tag) -> bool:
    if tag.has_attr("hidden") or tag.get("aria-hidden") == "true":
        return True
    style = (tag.get("style") or "").replace(" ", "").lower()
    return "display:none" in style or "visibility:hidden" in style


def _is_junk(tag: Tag) -> bool:
    if tag.name in ("html", "body", "main", "article"):
        return False
    attrs = " ".join(tag.get("class") or []) + " " + (tag.get("id") or "")
    words = {w.lower() for w in _WORD_SPLIT.split(attrs) if w}
    if words & JUNK_WORDS:
        return True
    role = tag.get("role")
    return role in ("navigation", "banner", "complementary", "contentinfo", "dialog")


def _remove(tags) -> None:
    for t in list(tags):
        if not t.decomposed:
            t.decompose()


def clean(root: Tag) -> None:
    """Remove clutter from root in place."""
    for c in root.find_all(string=lambda s: isinstance(s, Comment)):
        c.extract()
    _remove(root.find_all(DROP_TAGS))
    # <header> inside an article is usually the title block: keep its headings.
    for h in root.find_all("header"):
        if not h.find(re.compile(r"^h[1-6]$")):
            h.decompose()
    _remove(t for t in root.find_all(True) if _is_hidden(t) or _is_junk(t))


def _text_len(tag: Tag) -> int:
    return len(tag.get_text(" ", strip=True))


def _link_density(tag: Tag) -> float:
    total = _text_len(tag) or 1
    links = sum(_text_len(a) for a in tag.find_all("a"))
    return links / total


def _score(tag: Tag) -> float:
    """Text in direct-ish paragraphs, penalised by link density."""
    text = sum(
        _text_len(p) for p in tag.find_all(["p", "pre", "li", "blockquote"], recursive=True)
    )
    return text * (1 - _link_density(tag))


def _best_block(body: Tag) -> Tag:
    candidates = body.find_all(["div", "section", "td", "article", "main"])
    if not candidates:
        return body
    best = max(candidates, key=_score)
    # Prefer the parent when it holds substantially more good text, so we
    # don't cut an article in half at a wrapper div.
    parent = best.parent
    while isinstance(parent, Tag) and parent.name not in ("body", "html"):
        if _score(parent) > _score(best) * 1.3:
            best, parent = parent, parent.parent
        else:
            break
    return best


def main_content(html: str, base_url: str = "") -> tuple[str, Tag]:
    """Return (title, content_tag) with clutter already removed."""
    soup = BeautifulSoup(html, "lxml")
    title_tag = soup.find("title")
    title = title_tag.get_text(strip=True) if title_tag else ""
    og = soup.find("meta", property="og:title")
    if og and og.get("content"):
        title = og["content"].strip()

    rule = _site_rules(base_url)
    root = None
    if rule.get("content"):
        root = soup.select_one(rule["content"])
    if root is not None:
        for sel in rule.get("drop", []):
            _remove(root.select(sel))
        clean(root)
        return title, root

    body = soup.body or soup
    clean(body)
    for sel in ("article", "main", "[role=main]"):
        found = body.select(sel)
        # Several <article> tags usually means a listing page, not one article.
        if len(found) == 1 and _text_len(found[0]) > 200:
            return title, found[0]

    return title, _best_block(body)
