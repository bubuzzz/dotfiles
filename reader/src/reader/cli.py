"""Command line entry point: reader URL|FILE|-"""

import argparse
import sys

import requests

from reader.fetch import UnsupportedContent, load
from reader.pdf import PdfError, pdf_to_markdown
from reader.pipeline import page_to_markdown
from reader.render import show


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="reader",
        description="Show a web page as clean Markdown in the terminal.",
    )
    ap.add_argument("source", help="URL, local HTML file, or - for stdin")
    ap.add_argument(
        "-r", "--raw", action="store_true", help="print Markdown to stdout"
    )
    ap.add_argument(
        "-p", "--pager", choices=["auto", "glow", "less"], default="auto",
        help="viewer to use (default: glow if installed, else less)",
    )
    ap.add_argument("-o", "--output", help="also save the Markdown to this file")
    args = ap.parse_args(argv)

    try:
        doc = load(args.source)
        if doc.kind == "pdf":
            md = pdf_to_markdown(doc.data, doc.url)
        else:
            md = page_to_markdown(doc.text, doc.url)
    except (requests.RequestException, OSError, UnsupportedContent, PdfError) as e:
        print(f"reader: {e}", file=sys.stderr)
        return 1

    if args.output:
        with open(args.output, "w") as f:
            f.write(md)
    show(md, "none" if args.raw else args.pager)
    return 0


def run() -> None:
    try:
        sys.exit(main())
    except BrokenPipeError:  # e.g. piped into head
        sys.stderr.close()
        sys.exit(0)
    except KeyboardInterrupt:
        sys.exit(130)


if __name__ == "__main__":
    run()
