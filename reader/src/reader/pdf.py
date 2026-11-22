"""PDF -> Markdown via poppler's pdftotext, with paragraphs reflowed."""

import re
import shutil
import subprocess


class PdfError(Exception):
    pass


def _reflow(text: str) -> str:
    """Join hard-wrapped lines back into paragraphs.

    pdftotext ends every printed line with a newline. A paragraph ends at a
    blank line; a line that looks like a heading or list item starts a new one.
    """
    paras: list[str] = []
    for chunk in re.split(r"\n\s*\n", text.replace("\f", "\n\n")):
        # pdftotext often puts bullet glyphs on lines of their own: drop them.
        lines = [
            l.strip() for l in chunk.splitlines()
            if l.strip() and not re.fullmatch(r"[•●▪◦·\s-]+", l.strip())
        ]
        if not lines:
            continue
        out = lines[0]
        for line in lines[1:]:
            if re.match(r"^([•\-*–]|\d+[.)])\s", line):
                out += "\n" + line
            elif out.endswith("-") and not out.endswith(" -"):
                out = out[:-1] + line  # re-join hyphenated word
            else:
                out += " " + line
        paras.append(out)
    return "\n\n".join(paras)


def _bullets(text: str) -> str:
    return re.sub(r"^[•–]\s+", "- ", text, flags=re.M)


def _info(data: bytes) -> dict:
    try:
        res = subprocess.run(
            ["pdfinfo", "-"], input=data, capture_output=True, timeout=30
        )
    except (OSError, subprocess.TimeoutExpired):
        return {}
    info = {}
    for line in res.stdout.decode(errors="replace").splitlines():
        key, _, val = line.partition(":")
        info[key.strip()] = val.strip()
    return info


def pdf_to_markdown(data: bytes, url: str = "") -> str:
    if not shutil.which("pdftotext"):
        raise PdfError("pdftotext not found (sudo pacman -S poppler)")
    res = subprocess.run(
        ["pdftotext", "-enc", "UTF-8", "-", "-"],
        input=data, capture_output=True, timeout=120,
    )
    if res.returncode != 0:
        raise PdfError(res.stderr.decode(errors="replace").strip() or "pdftotext failed")
    body = _bullets(_reflow(res.stdout.decode("utf-8", errors="replace")))
    if not body.strip():
        raise PdfError("no text in this PDF (scanned images?)")

    info = _info(data)
    title = info.get("Title") or (url.rsplit("/", 1)[-1] if url else "PDF document")
    parts = [f"# {title}"]
    meta = [f"Source: {url}"] if url else []
    if info.get("Pages"):
        meta.append(f"{info['Pages']} pages (PDF)")
    if meta:
        parts.append(" · ".join(meta))
    parts.append(body)
    return "\n\n".join(parts) + "\n"
