"""Custom converters for sites whose layout needs more than a CSS selector.

A handler takes (soup, base_url) and returns Markdown, or None to fall back
to the generic pipeline.
"""

from urllib.parse import urljoin, urlparse

from bs4 import BeautifulSoup

from reader.markdown import Converter

MAX_QUOTE_DEPTH = 6
USER_SEL = '.hnuser, .comhead a[href^="user?id="], .subline a[href^="user?id="]'


def _quote(text: str, depth: int) -> str:
    if depth == 0:
        return text
    prefix = "> " * depth
    return "\n".join(prefix.rstrip() if not l else prefix + l for l in text.splitlines())


def hacker_news(soup: BeautifulSoup, base_url: str) -> str | None:
    """Story (or comment) at the top, then the comment thread as nested quotes."""
    item = soup.select_one("table.fatitem")
    if item is None:
        return None
    conv = Converter(base_url)
    parts: list[str] = []

    title = item.select_one(".titleline > a")
    if title:
        href = urljoin(base_url, title.get("href", ""))
        parts.append(f"# {title.get_text(strip=True)}")
        parts.append(f"<{href}>")
    sub = item.select_one(".subline, .subtext")
    if sub:
        meta = " · ".join(
            t.get_text(strip=True)
            for t in sub.select(".score, " + USER_SEL + ", .age")
        )
        if meta:
            parts.append(f"*{meta}*")
    # Self-post text (Ask HN) or the top comment when viewing a comment.
    for text in item.select(".toptext, .commtext"):
        user = item.select_one(USER_SEL)
        if not title and user:
            parts.append(f"**{user.get_text(strip=True)}**")
        parts.extend(conv.blocks(text))

    comments = soup.select("tr.athing.comtr")
    if comments:
        parts.append(f"## Comments ({len(comments)})")
    for c in comments:
        ind = c.select_one("td.ind")
        depth = min(int(ind.get("indent", 0)) if ind else 0, MAX_QUOTE_DEPTH)
        user = c.select_one(USER_SEL)
        age = c.select_one(".age")
        head = f"**{user.get_text(strip=True) if user else '[deleted]'}**"
        if age:
            head += f" · {age.get_text(strip=True)}"
        body_tag = c.select_one(".commtext")
        body = "\n\n".join(conv.blocks(body_tag)) if body_tag else "*[deleted]*"
        parts.append(_quote(f"{head}\n\n{body}", depth))

    more = soup.select_one("a.morelink")
    if more:
        parts.append(f"More comments: <{urljoin(base_url, more['href'])}>")
    if conv.links:
        refs = "\n".join(f"\\[{i}\\] <{u}>  " for i, u in enumerate(conv.links, 1))
        parts += ["---", "## Links", refs]
    return "\n\n".join(parts) + "\n"


HANDLERS = {
    "news.ycombinator.com": hacker_news,
}


def find(base_url: str):
    host = urlparse(base_url).hostname or "" if base_url else ""
    return HANDLERS.get(host)
