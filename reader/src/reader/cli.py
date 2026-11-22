"""Command line entry point: reader URL|FILE|-"""

import argparse
import sys

import requests

from reader.fetch import load
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
        html, base_url = load(args.source)
    except (requests.RequestException, OSError) as e:
        print(f"reader: {e}", file=sys.stderr)
        return 1

    md = page_to_markdown(html, base_url or (args.source if "://" in args.source else ""))
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
