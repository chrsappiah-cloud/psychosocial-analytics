#!/usr/bin/env python3
"""Generate App Store Review reply PDF on the Desktop."""
from __future__ import annotations

from pathlib import Path

from fpdf import FPDF

DESKTOP = Path.home() / "Desktop"
SOURCE = DESKTOP / "PsychosocialAnalytics-AppStoreReviewReply-May31-2026.txt"
OUTPUT = DESKTOP / "PsychosocialAnalytics-AppStoreReviewReply-May31-2026.pdf"
SUBMISSION_ID = "72a127f7-1a12-443c-964c-b11a5ba400e7"
BUILD = "5"


def ascii_safe(text: str) -> str:
    replacements = {
        "\u2014": "-",
        "\u2013": "-",
        "\u2019": "'",
        "\u2018": "'",
        "\u2022": "*",
        "\u2192": "->",
        "\u201c": '"',
        "\u201d": '"',
    }
    for key, value in replacements.items():
        text = text.replace(key, value)
    return text.encode("ascii", "replace").decode("ascii")


class ReviewReplyPDF(FPDF):
    def footer(self) -> None:
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 10, f"Psychosocial Analytics - App Review Reply  |  Page {self.page_no()}", align="C")


def build_pdf(text: str, output: Path) -> None:
    text = ascii_safe(text)
    pdf = ReviewReplyPDF()
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 16)
    pdf.set_text_color(20, 60, 50)
    pdf.cell(0, 10, "Psychosocial Analytics", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    pdf.set_text_color(40, 40, 40)
    pdf.cell(0, 7, "App Store Review - Resolution Center Reply", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 7, f"Submission ID: {SUBMISSION_ID}", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 7, f"Version 1.0.0 (Build {BUILD}) | 31 May 2026", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(6)
    pdf.set_font("Helvetica", "", 10)

    for line in text.splitlines()[7:]:
        if line.startswith("GUIDELINE") or line.startswith("HOW TO TEST"):
            pdf.ln(4)
            pdf.set_font("Helvetica", "B", 11)
            pdf.set_text_color(20, 80, 60)
            pdf.multi_cell(0, 6, ascii_safe(line.strip("- ").strip()))
            pdf.set_font("Helvetica", "", 10)
            pdf.set_text_color(40, 40, 40)
        elif set(line.strip()) == {"-"}:
            pdf.ln(2)
        elif not line.strip():
            pdf.ln(3)
        else:
            pdf.multi_cell(0, 5, ascii_safe(line))
            pdf.ln(1)

    pdf.output(str(output))


def main() -> int:
    if not SOURCE.exists():
        raise SystemExit(f"Missing source file: {SOURCE}")
    build_pdf(SOURCE.read_text(), OUTPUT)
    print(f"Saved: {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
