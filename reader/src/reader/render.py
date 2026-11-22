"""Show Markdown in the terminal: glow if available, else less."""

import re
import shutil
import subprocess
import sys
import textwrap


def _wrap(md: str, width: int) -> str:
    """Hard-wrap prose for less, leaving code blocks and tables untouched."""
    out, in_code = [], False
    for line in md.splitlines():
        if line.lstrip().startswith(("```", "~~~")):
            in_code = not in_code
        if in_code or line.startswith("|") or len(line) <= width:
            out.append(line)
            continue
        indent = len(line) - len(line.lstrip())
        bullet = re.match(r"\s*([-*]|\d+\.|>)\s+", line)
        sub = " " * (bullet.end() if bullet else indent)
        out.extend(
            textwrap.wrap(line, width, subsequent_indent=sub, break_on_hyphens=False)
        )
    return "\n".join(out) + "\n"


def show(md: str, pager: str = "auto") -> None:
    width = shutil.get_terminal_size((100, 40)).columns
    if not sys.stdout.isatty() or pager == "none":
        sys.stdout.write(md)
        return
    if pager in ("auto", "glow") and shutil.which("glow"):
        subprocess.run(
            ["glow", "-p", "-w", str(min(width, 120)), "-"], input=md, text=True
        )
        return
    subprocess.run(["less", "-R"], input=_wrap(md, min(width, 120)), text=True)

