#!/usr/bin/env python3
"""Export quiz-bank + dictionary rows into a primary review CSV."""
from __future__ import annotations

import csv
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parent.parent
BANKS_DIR = REPO / "assets" / "quiz_banks"
DICTIONARY_PATH = REPO / "assets" / "dictionary" / "japanese_lexicon.json"
OUT_PATH = REPO / "assets" / "review" / "word_bank_review.csv"

KANJI_RE = re.compile(r"[\u4E00-\u9FFF]")
JP_TOKEN_RE = re.compile(r"[\u3040-\u30FF\u4E00-\u9FFF]+")

CSV_FIELDS = [
    "row_key",
    "source_type",
    "quiz_id",
    "source_file",
    "question_id",
    "field_origin",
    "choice_id",
    "surface",
    "reading",
    "part_of_speech",
    "definitions",
    "has_kanji",
    "needs_override",
    "review_status",
    "review_notes",
    "override_text",
]


@dataclass(frozen=True)
class DictIndex:
    reading: str
    definitions: str
    part_of_speech: str


def has_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(text))


def load_dictionary() -> tuple[list[dict[str, Any]], dict[str, list[DictIndex]]]:
    entries = json.loads(DICTIONARY_PATH.read_text(encoding="utf-8"))
    by_surface: dict[str, list[DictIndex]] = {}
    for e in entries:
        surface = str(e.get("surface", "")).strip()
        reading = str(e.get("reading", "")).strip()
        defs = e.get("definitions", [])
        definitions = " | ".join(str(d).strip() for d in defs if str(d).strip())
        pos = str(e.get("partOfSpeech", "")).strip()
        if not surface:
            continue
        by_surface.setdefault(surface, []).append(
            DictIndex(reading=reading, definitions=definitions, part_of_speech=pos)
        )
    return entries, by_surface


def iter_quiz_files() -> list[Path]:
    files = sorted(BANKS_DIR.glob("*.json"))
    return [p for p in files if p.name != "quiz_catalog.json"]


def tokenize_japanese(text: str) -> list[str]:
    return [m.group(0) for m in JP_TOKEN_RE.finditer(text)]


def make_quiz_rows(
    dictionary_by_surface: dict[str, list[DictIndex]],
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for bank_path in iter_quiz_files():
        doc = json.loads(bank_path.read_text(encoding="utf-8"))
        quiz_id = str(doc.get("id", "")).strip()
        for q in doc.get("questions", []):
            qid = str(q.get("id", "")).strip()
            field_values = [
                ("japanese", str(q.get("japanese", "")).strip(), ""),
                ("prompt", str(q.get("prompt", "")).strip(), ""),
                ("explanation", str(q.get("explanation", "")).strip(), ""),
                ("context", str(q.get("context") or "").strip(), ""),
            ]
            for i, c in enumerate(q.get("choices", [])):
                cid = str(c.get("id", f"choice_{i}"))
                field_values.append((f"choice_label", str(c.get("label", "")).strip(), cid))
                field_values.append(
                    (f"choice_explanation", str(c.get("explanation") or "").strip(), cid)
                )
            for idx, v in enumerate(q.get("vocabulary", [])):
                field_values.append((f"vocabulary_{idx}", str(v).strip(), ""))

            for field_origin, text, choice_id in field_values:
                if not text:
                    continue
                seen_in_field = set()
                for token in tokenize_japanese(text):
                    if token in seen_in_field:
                        continue
                    seen_in_field.add(token)
                    dict_rows = dictionary_by_surface.get(token, [])
                    best = dict_rows[0] if dict_rows else DictIndex("", "", "")
                    needs_override = has_kanji(token) and not dict_rows
                    row_key = "|".join(
                        [
                            "quiz",
                            bank_path.name,
                            qid,
                            field_origin,
                            choice_id,
                            token,
                        ]
                    )
                    rows.append(
                        {
                            "row_key": row_key,
                            "source_type": "quiz",
                            "quiz_id": quiz_id,
                            "source_file": bank_path.name,
                            "question_id": qid,
                            "field_origin": field_origin,
                            "choice_id": choice_id,
                            "surface": token,
                            "reading": best.reading,
                            "part_of_speech": best.part_of_speech,
                            "definitions": best.definitions,
                            "has_kanji": "1" if has_kanji(token) else "0",
                            "needs_override": "1" if needs_override else "0",
                            "review_status": "",
                            "review_notes": "",
                            "override_text": "",
                        }
                    )
    rows.sort(key=lambda r: (r["source_file"], r["question_id"], r["field_origin"], r["surface"]))
    return rows


def make_dictionary_rows(entries: list[dict[str, Any]]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    seen: dict[str, int] = {}
    for e in entries:
        surface = str(e.get("surface", "")).strip()
        reading = str(e.get("reading", "")).strip()
        pos = str(e.get("partOfSpeech", "")).strip()
        defs = " | ".join(
            str(d).strip() for d in e.get("definitions", []) if str(d).strip()
        )
        signature = "|".join(["dict", surface, reading, pos])
        count = seen.get(signature, 0)
        seen[signature] = count + 1
        row_key = f"{signature}|{count}"
        rows.append(
            {
                "row_key": row_key,
                "source_type": "dictionary",
                "quiz_id": "",
                "source_file": DICTIONARY_PATH.name,
                "question_id": "",
                "field_origin": "",
                "choice_id": "",
                "surface": surface,
                "reading": reading,
                "part_of_speech": pos,
                "definitions": defs,
                "has_kanji": "1" if has_kanji(surface) else "0",
                "needs_override": "0",
                "review_status": "",
                "review_notes": "",
                "override_text": "",
            }
        )
    rows.sort(key=lambda r: (r["surface"], r["reading"], r["part_of_speech"], r["row_key"]))
    return rows


def write_csv(rows: list[dict[str, str]]) -> None:
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUT_PATH.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=CSV_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    dictionary_entries, dictionary_by_surface = load_dictionary()
    rows = make_quiz_rows(dictionary_by_surface) + make_dictionary_rows(dictionary_entries)
    write_csv(rows)
    print(f"wrote {OUT_PATH} ({len(rows)} rows)")


if __name__ == "__main__":
    main()
