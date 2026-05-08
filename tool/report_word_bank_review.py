#!/usr/bin/env python3
"""Summarize current review CSV progress and correction counts."""
from __future__ import annotations

import csv
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
REVIEW_CSV_PATH = REPO / "assets" / "review" / "word_bank_review.csv"


def main() -> None:
    with REVIEW_CSV_PATH.open("r", newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    total = len(rows)
    dict_rows = sum(1 for r in rows if r.get("source_type") == "dictionary")
    quiz_rows = total - dict_rows
    reviewed = sum(1 for r in rows if (r.get("review_status") or "").strip())
    corrected_reading = sum(1 for r in rows if (r.get("reading") or "").strip())
    corrected_definitions = sum(1 for r in rows if (r.get("definitions") or "").strip())
    unresolved = sum(
        1
        for r in rows
        if r.get("has_kanji") == "1"
        and not (r.get("reading") or "").strip()
    )
    pending_override = sum(1 for r in rows if r.get("needs_override") == "1")

    print(f"review_csv: {REVIEW_CSV_PATH}")
    print(f"total_rows: {total}")
    print(f"quiz_rows: {quiz_rows}")
    print(f"dictionary_rows: {dict_rows}")
    print(f"rows_with_review_status: {reviewed}")
    print(f"rows_with_reading: {corrected_reading}")
    print(f"rows_with_definitions: {corrected_definitions}")
    print(f"kanji_rows_without_reading: {unresolved}")
    print(f"rows_flagged_needs_override: {pending_override}")


if __name__ == "__main__":
    main()
