"""Convert a cleaned HTML block to Markdown using a small tag whitelist.

Links become numbered references, "text [3]", listed at the end.
Images become "[image: alt]" or disappear when they have no alt text.
Anything not on the whitelist is unwrapped to its text.
"""

import re
from urllib.parse import urljoin

from bs4 import NavigableString, Tag

BLOCK_TAGS = {
    "p", "div", "section", "article", "main", "header", "figure", "figcaption",
    "h1", "h2", "h3", "h4", "h5", "h6", "ul", "ol", "li", "pre", "blockquote",
    "table", "tr", "hr", "dl", "dt", "dd", "details", "summary", "center",
    "address", "td", "th", "tbody", "thead",
}

_WS = re.compile(r"\s+")
_LANG = re.compile(r"(?:language|lang|highlight)-([\w+#-]+)")


class Converter:
    def __init__(self, base_url: str = ""):
        self.base_url = base_url
        self.links: list[str] = []
        self._link_index: dict[str, int] = {}

    # ---- helpers -----------------------------------------------------
    def _ref(self, href: str) -> int:
        url = urljoin(self.base_url, href) if self.base_url else href
        if url not in self._link_index:
            self.links.append(url)
            self._link_index[url] = len(self.links)
        return self._link_index[url]

    def inline(self, node) -> str:
        """Render inline content (text, emphasis, links, code) to one line."""
        if isinstance(node, NavigableString):
            return _WS.sub(" ", str(node))
        if not isinstance(node, Tag):
            return ""
        name = node.name
        if name == "br":
            return "  \n"
        if name == "img":
            # Images inside links are badges, logos or icons: drop them.
            if node.find_parent("a") is not None:
                return ""
            alt = (node.get("alt") or "").strip()
            return f"[image: {alt}]" if alt else ""
        if name in ("pre", "table", "ul", "ol") or name in ("h1", "h2", "h3", "h4", "h5", "h6"):
            # Block inside inline context: render as its own block later.
            return " " + _WS.sub(" ", node.get_text(" ")) + " "
        inner = "".join(self.inline(c) for c in node.children)
        if name == "code" or name in ("kbd", "samp", "tt"):
            text = node.get_text()
            if not text.strip():
                return ""
            tick = "``" if "`" in text else "`"
            return f"{tick}{_WS.sub(' ', text)}{tick}"
        stripped = inner.strip()
        if not stripped:
            return inner
        lead = " " if inner[:1].isspace() else ""
        trail = " " if inner[-1:].isspace() else ""
        if name in ("strong", "b"):
            return f"{lead}**{stripped}**{trail}"
        if name in ("em", "i", "cite"):
            return f"{lead}*{stripped}*{trail}"
        if name in ("del", "s", "strike"):
            return f"{lead}~~{stripped}~~{trail}"
        if name == "a":
            href = (node.get("href") or "").strip()
            if not href or href.startswith(("#", "javascript:", "mailto:")):
                return inner
            if stripped == href or stripped == urljoin(self.base_url, href):
                return f"{lead}<{stripped}>{trail}"
            return f"{lead}{stripped} [{self._ref(href)}]{trail}"
        return inner

    # ---- blocks ------------------------------------------------------
    def blocks(self, node: Tag) -> list[str]:
        """Render the children of node as a list of Markdown blocks."""
        out: list[str] = []
        run: list[str] = []  # pending inline content

        def flush():
            text = _WS.sub(" ", "".join(run).replace("  \n", "\x00")).strip()
            text = text.replace("\x00", "  \n").replace("  \n ", "  \n")
            if text:
                out.append(text)
            run.clear()

        for child in node.children:
            if isinstance(child, Tag) and child.name in BLOCK_TAGS:
                flush()
                out.extend(self.block(child))
            elif isinstance(child, Tag) and child.name == "img":
                flush()
                img = self.inline(child)
                if img:
                    out.append(img)
            else:
                run.append(self.inline(child))
        flush()
        return out

    def block(self, node: Tag) -> list[str]:
        name = node.name
        if name in ("h1", "h2", "h3", "h4", "h5", "h6"):
            text = _WS.sub(" ", "".join(self.inline(c) for c in node.children)).strip()
            return [f"{'#' * int(name[1])} {text}"] if text else []
        if name == "pre":
            return [self.pre(node)]
        if name in ("ul", "ol"):
            return [self.list_(node)] if node.find("li") else []
        if name == "blockquote":
            inner = "\n\n".join(self.blocks(node))
            if not inner:
                return []
            return ["\n".join(("> " + l) if l else ">" for l in inner.splitlines())]
        if name == "hr":
            return ["---"]
        if name == "table":
            return [self.table(node)]
        if name in ("dt",):
            text = _WS.sub(" ", self.inline(node)).strip()
            return [f"**{text}**"] if text else []
        if name == "summary":
            text = _WS.sub(" ", self.inline(node)).strip()
            return [f"**{text}**"] if text else []
        return self.blocks(node)

    def pre(self, node: Tag) -> str:
        code = node.find("code")
        classes = " ".join((code or node).get("class") or []) + " " + " ".join(
            node.get("class") or []
        )
        m = _LANG.search(classes)
        lang = m.group(1) if m else ""
        text = node.get_text().strip("\n")
        fence = "````" if "```" in text else "```"
        return f"{fence}{lang}\n{text}\n{fence}"

    def list_(self, node: Tag, depth: int = 0) -> str:
        lines = []
        n = int(node.get("start") or 1) if node.name == "ol" else 0
        for li in node.find_all("li", recursive=False):
            marker = f"{n}." if node.name == "ol" else "-"
            n += 1
            nested = [c for c in li.find_all(["ul", "ol"], recursive=False)]
            for c in nested:
                c.extract()
            body = "\n\n".join(self.blocks(li)).strip()
            pad = "  " * depth
            sub_pad = pad + " " * (len(marker) + 1)
            body_lines = body.splitlines() or [""]
            lines.append(f"{pad}{marker} {body_lines[0]}")
            lines.extend((sub_pad + l) if l else "" for l in body_lines[1:])
            for c in nested:
                lines.append(self.list_(c, depth + 1))
        return "\n".join(lines)

    def table(self, node: Tag) -> str:
        # Layout tables (cells holding paragraphs, divs, other tables) are
        # rendered as normal blocks instead of a Markdown table.
        if node.find(["p", "div", "table", "pre", "ul", "ol", "blockquote"]):
            return "\n\n".join(self.blocks(node))
        rows = []
        for tr in node.find_all("tr"):
            if tr.find_parent("table") is not node:
                continue  # nested table
            cells = [
                _WS.sub(" ", self.inline(td)).strip().replace("|", "\\|")
                for td in tr.find_all(["td", "th"], recursive=False)
            ]
            if any(cells):
                rows.append(cells)
        if not rows:
            return ""
        # Layout tables (one column, or long cells) read better as text.
        width = max(len(r) for r in rows)
        if width == 1 or any(len(c) > 200 for r in rows for c in r):
            return "\n\n".join(" ".join(r) for r in rows)
        rows = [r + [""] * (width - len(r)) for r in rows]
        head, *rest = rows
        lines = ["| " + " | ".join(head) + " |", "|" + "---|" * width]
        lines += ["| " + " | ".join(r) + " |" for r in rest]
        return "\n".join(lines)


def to_markdown(root: Tag, title: str = "", base_url: str = "") -> str:
    conv = Converter(base_url)
    parts = [b for b in conv.blocks(root) if b.strip()]
    # Add the page title unless the content already starts with a heading.
    if title and not (parts and parts[0].startswith("#")):
        parts.insert(0, f"# {title}")
    if conv.links:
        refs = "\n".join(f"\\[{i}\\] <{u}>  " for i, u in enumerate(conv.links, 1))
        parts += ["---", "## Links", refs]
    if base_url:
        parts.insert(1 if parts and parts[0].startswith("# ") else 0, f"Source: {base_url}")
    return "\n\n".join(parts) + "\n"
