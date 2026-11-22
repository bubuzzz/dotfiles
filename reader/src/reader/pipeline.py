"""HTML in, Markdown out."""

import re

from bs4 import BeautifulSoup

from reader import handlers
from reader.extract import main_content
from reader.markdown import to_markdown


def page_to_markdown(html: str, base_url: str = "") -> str:
    handler = handlers.find(base_url)
    md = handler(BeautifulSoup(html, "lxml"), base_url) if handler else None
    if md is None:
        title, root = main_content(html, base_url)
        md = to_markdown(root, title, base_url)
    return re.sub(r"\n{3,}", "\n\n", md)
