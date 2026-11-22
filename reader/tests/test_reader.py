from pathlib import Path

from reader import page_to_markdown

FIX = Path(__file__).parent / "fixtures"


def test_article_keeps_content_and_drops_clutter():
    md = page_to_markdown((FIX / "article.html").read_text(), "https://blog.example/post")
    assert md.startswith("# Sample Post\n")
    assert "First paragraph with a link [1] and **bold** text." in md
    assert "```python\ndef very_long_function_name" in md
    assert "- two\n  - nested" in md
    assert "| Key | Value |" in md
    assert "Hero caption" in md
    for junk in ("cookies", "Tweet", "Related", "Copyright", "Home", "track()", "build passing"):
        assert junk not in md, junk
    assert "\\[1\\] <https://blog.example/docs>" in md


def test_hacker_news_thread():
    md = page_to_markdown(
        (FIX / "hn_comment.html").read_text(),
        "https://news.ycombinator.com/item?id=46000000",
    )
    assert md.startswith("**airstrike**")
    assert "## Comments (2)" in md
    assert "**exploraz**" in md
    # the reply is nested one level
    assert "> **airstrike** ·" in md
    assert "vote?id=" not in md


def test_content_type_detection():
    import pytest
    from reader.fetch import UnsupportedContent, _kind

    assert _kind("application/pdf", b"") == "pdf"
    assert _kind("application/octet-stream", b"%PDF-1.7 ...") == "pdf"
    assert _kind("text/html; charset=utf-8", b"<html>") == "html"
    with pytest.raises(UnsupportedContent):
        _kind("image/png", b"\x89PNG")


def test_pdf_reflow():
    from reader.pdf import _reflow

    text = "First line of a para-\ngraph that wraps\n•\nnext line\n\nSecond para"
    assert _reflow(text) == "First line of a paragraph that wraps next line\n\nSecond para"
