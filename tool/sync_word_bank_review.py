#!/usr/bin/env python3
"""Apply reviewed CSV updates back into dictionary and quiz-bank JSON."""
from __future__ import annotations

import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parent.parent
BANKS_DIR = REPO / "assets" / "quiz_banks"
DICTIONARY_PATH = REPO / "assets" / "dictionary" / "japanese_lexicon.json"
REVIEW_CSV_PATH = REPO / "assets" / "review" / "word_bank_review.csv"


def _load_review_rows() -> list[dict[str, str]]:
    with REVIEW_CSV_PATH.open("r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def _split_definitions(s: str) -> list[str]:
    vals = [x.strip() for x in s.split("|")]
    return [x for x in vals if x]


def _sync_dictionary(rows: list[dict[str, str]]) -> int:
    dictionary = json.loads(DICTIONARY_PATH.read_text(encoding="utf-8"))
    index_by_key: dict[str, int] = {}
    seen_signature: dict[str, int] = defaultdict(int)
    for i, entry in enumerate(dictionary):
        surface = str(entry.get("surface", "")).strip()
        reading = str(entry.get("reading", "")).strip()
        pos = str(entry.get("partOfSpeech", "")).strip()
        signature = f"dict|{surface}|{reading}|{pos}"
        occurrence = seen_signature[signature]
        seen_signature[signature] += 1
        index_by_key[f"{signature}|{occurrence}"] = i

    updates = 0
    for row in rows:
        if row.get("source_type") != "dictionary":
            continue
        row_key = row.get("row_key", "")
        idx = index_by_key.get(row_key)
        if idx is None:
            continue
        entry = dictionary[idx]
        next_surface = row.get("surface", "").strip()
        next_reading = row.get("reading", "").strip()
        next_pos = row.get("part_of_speech", "").strip()
        next_definitions = _split_definitions(row.get("definitions", ""))
        if not next_definitions:
            continue
        changed = False
        if next_surface and next_surface != entry.get("surface"):
            entry["surface"] = next_surface
            changed = True
        if next_reading != entry.get("reading"):
            entry["reading"] = next_reading
            changed = True
        if next_pos and next_pos != entry.get("partOfSpeech"):
            entry["partOfSpeech"] = next_pos
            changed = True
        if next_definitions != entry.get("definitions"):
            entry["definitions"] = next_definitions
            changed = True
        if changed:
            updates += 1

    if updates:
        DICTIONARY_PATH.write_text(
            json.dumps(dictionary, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    return updates


def _field_value(question: dict[str, Any], field_origin: str, choice_id: str) -> tuple[str, str]:
    if field_origin == "japanese":
        return "question", "japanese"
    if field_origin == "prompt":
        return "question", "prompt"
    if field_origin == "explanation":
        return "question", "explanation"
    if field_origin == "context":
        return "question", "context"
    if field_origin == "choice_label":
        return "choice", "label"
    if field_origin == "choice_explanation":
        return "choice", "explanation"
    if field_origin.startswith("vocabulary_"):
        return "vocabulary", field_origin
    raise ValueError(f"unsupported field_origin={field_origin}, choice_id={choice_id}")


def _sync_quiz(rows: list[dict[str, str]]) -> int:
    by_file: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        if row.get("source_type") == "quiz":
            by_file[row.get("source_file", "")].append(row)

    updates = 0
    for file_name, file_rows in by_file.items():
        path = BANKS_DIR / file_name
        if not path.exists():
            continue
        doc = json.loads(path.read_text(encoding="utf-8"))
        by_qid = {str(q.get("id", "")): q for q in doc.get("questions", [])}
        changed = False
        for row in file_rows:
            qid = row.get("question_id", "")
            question = by_qid.get(qid)
            if question is None:
                continue
            field_origin = row.get("field_origin", "")
            choice_id = row.get("choice_id", "")
            surface = row.get("surface", "")
            if not surface:
                continue

            override_text = row.get("override_text", "").strip()
            reading = row.get("reading", "").strip()
            needs_override = row.get("needs_override", "0").strip() == "1"
            replacement = ""
            if override_text:
                replacement = override_text
            elif needs_override and reading:
                replacement = f"{surface}[{reading}]"
            if not replacement:
                continue

            target_type, target_field = _field_value(question, field_origin, choice_id)
            if target_type == "question":
                existing = str(question.get(target_field) or "")
                if surface in existing:
                    question[target_field] = existing.replace(surface, replacement)
                    changed = True
                    updates += 1
            elif target_type == "choice":
                for c in question.get("choices", []):
                    if str(c.get("id", "")) != choice_id:
                        continue
                    existing = str(c.get(target_field) or "")
                    if surface in existing:
                        c[target_field] = existing.replace(surface, replacement)
                        changed = True
                        updates += 1
                    break
            elif target_type == "vocabulary":
                vocab = question.get("vocabulary", [])
                if not isinstance(vocab, list):
                    continue
                for i, val in enumerate(vocab):
                    sval = str(val)
                    if sval == surface:
                        vocab[i] = replacement
                        changed = True
                        updates += 1
            else:
                raise AssertionError(f"unknown target_type {target_type}")
        if changed:
            path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return updates


def main() -> None:
    rows = _load_review_rows()
    dict_updates = _sync_dictionary(rows)
    quiz_updates = _sync_quiz(rows)
    print(
        "sync complete: "
        f"dictionary_updates={dict_updates}, quiz_updates={quiz_updates}, "
        f"review_csv={REVIEW_CSV_PATH}"
    )


if __name__ == "__main__":
    main()
