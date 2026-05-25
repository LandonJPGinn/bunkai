#!/usr/bin/env python3
"""Audit and generate inline furigana for quiz content.

The Flutter app renders lightweight `kanji[reading]` markup. This script keeps
the expensive sentence analysis offline: it uses Sudachi when available, falls
back to the local word bank, and writes review rows for anything unresolved.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

REPO = Path(__file__).resolve().parent.parent
QUESTIONS_CSV = REPO / "data-src" / "quiz" / "questions.csv"
CHOICES_CSV = REPO / "data-src" / "quiz" / "choices.csv"
DICTIONARY_PATH = REPO / "assets" / "dictionary" / "japanese_lexicon.json"
REVIEW_PATH = REPO / "assets" / "review" / "furigana_audit.csv"

QUESTION_TEXT_FIELDS = ("prompt", "context", "japanese", "explanation")
QUESTION_PIPE_FIELDS = ("grammar_points", "vocabulary")
CHOICE_TEXT_FIELDS = ("label", "explanation")

KANJI_RE = re.compile(
    r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\u3005\u3007]"
)
KANA_RE = re.compile(r"^[\u3040-\u309F\u30A0-\u30FFー]+$")

AUDIT_FIELDS = [
    "row_key",
    "source_csv",
    "quiz_id",
    "question_id",
    "field",
    "choice_id",
    "surface",
    "reading",
    "status",
    "source",
    "original_text",
    "annotated_text",
    "notes",
]


@dataclass(frozen=True)
class TokenReading:
    surface: str
    reading: str
    source: str
    ambiguous: bool = False


@dataclass(frozen=True)
class AnnotatedText:
    text: str
    issues: tuple[dict[str, str], ...]
    changed: bool


def has_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(text))


def is_kanji(ch: str) -> bool:
    return bool(KANJI_RE.fullmatch(ch))


def is_kana_text(text: str) -> bool:
    return bool(text) and bool(KANA_RE.fullmatch(text))


def kata_to_hira(text: str) -> str:
    out: list[str] = []
    for ch in text:
        code = ord(ch)
        if 0x30A1 <= code <= 0x30F6:
            out.append(chr(code - 0x60))
        else:
            out.append(ch)
    return "".join(out)


def parse_inline_parts(text: str) -> list[tuple[str, str, str]]:
    """Return parts as ("plain", text, "") or ("ruby", base, reading)."""
    parts: list[tuple[str, str, str]] = []
    i = 0
    while i < len(text):
        open_idx = text.find("[", i)
        if open_idx == -1:
            if i < len(text):
                parts.append(("plain", text[i:], ""))
            break
        close_idx = text.find("]", open_idx + 1)
        if close_idx == -1:
            parts.append(("plain", text[i:], ""))
            break
        base_start = open_idx
        while base_start > i and is_kanji(text[base_start - 1]):
            base_start -= 1
        if base_start > i:
            parts.append(("plain", text[i:base_start], ""))
        base = text[base_start:open_idx]
        reading = text[open_idx + 1 : close_idx]
        if base:
            parts.append(("ruby", base, reading))
        else:
            parts.append(("plain", text[open_idx : close_idx + 1], ""))
        i = close_idx + 1
    return parts


def strip_inline(text: str) -> str:
    if "[" not in text:
        return text
    out: list[str] = []
    for kind, value, _reading in parse_inline_parts(text):
        out.append(value)
    return "".join(out)


def uncovered_kanji_runs(text: str) -> list[str]:
    runs: list[str] = []
    for kind, value, _reading in parse_inline_parts(text):
        if kind != "plain":
            continue
        start: int | None = None
        for i, ch in enumerate(value):
            if is_kanji(ch):
                if start is None:
                    start = i
            elif start is not None:
                runs.append(value[start:i])
                start = None
        if start is not None:
            runs.append(value[start:])
    return runs


def split_pipe(value: str) -> list[str]:
    return [part.strip() for part in value.split("|") if part.strip()]


def join_pipe(values: Iterable[str]) -> str:
    return " | ".join(v.strip() for v in values if v.strip())


def read_csv(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        return list(reader.fieldnames or []), list(reader)


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


class ReadingAnalyzer:
    def __init__(self) -> None:
        self._dict_by_surface = self._load_dictionary()
        self._max_surface_len = max((len(s) for s in self._dict_by_surface), default=1)
        self._sudachi_tokenizer = None
        self._sudachi_mode = None
        try:
            from sudachipy import dictionary, tokenizer  # type: ignore

            self._sudachi_tokenizer = dictionary.Dictionary().create()
            self._sudachi_mode = tokenizer.Tokenizer.SplitMode.C
        except Exception:
            self._sudachi_tokenizer = None
            self._sudachi_mode = None

    @property
    def has_sudachi(self) -> bool:
        return self._sudachi_tokenizer is not None and self._sudachi_mode is not None

    def analyze(self, text: str) -> list[TokenReading]:
        tokens = self._analyze_with_quote_context(text)
        return self._postprocess_context(tokens)

    def _analyze_with_quote_context(self, text: str) -> list[TokenReading]:
        if "「" not in text:
            return self._analyze_raw(text)
        tokens: list[TokenReading] = []
        i = 0
        while i < len(text):
            open_idx = text.find("「", i)
            if open_idx == -1:
                tokens.extend(self._analyze_raw(text[i:]))
                break
            if open_idx > i:
                tokens.extend(self._analyze_raw(text[i:open_idx]))
            close_idx = text.find("」", open_idx + 1)
            if close_idx == -1:
                tokens.extend(self._analyze_raw(text[open_idx:]))
                break
            tokens.append(TokenReading(surface="「", reading="", source="punctuation"))
            tokens.extend(self._analyze_raw(text[open_idx + 1 : close_idx]))
            tokens.append(TokenReading(surface="」", reading="", source="punctuation"))
            i = close_idx + 1
        return tokens

    def _analyze_raw(self, text: str) -> list[TokenReading]:
        if not text:
            return []
        if self.has_sudachi:
            return self._analyze_sudachi(text)
        return self._analyze_dictionary(text)

    def _postprocess_context(self, tokens: list[TokenReading]) -> list[TokenReading]:
        out: list[TokenReading] = []
        for i, token in enumerate(tokens):
            next_surface = tokens[i + 1].surface if i + 1 < len(tokens) else ""
            if (
                token.surface == "何"
                and token.reading == "なん"
                and next_surface in {"を", "が", "に", "も", "から", "まで"}
            ):
                out.append(
                    TokenReading(
                        surface=token.surface,
                        reading="なに",
                        source=f"{token.source}+context",
                        ambiguous=token.ambiguous,
                    )
                )
            else:
                out.append(token)
        return out

    def _load_dictionary(self) -> dict[str, list[str]]:
        if not DICTIONARY_PATH.exists():
            return {}
        entries = json.loads(DICTIONARY_PATH.read_text(encoding="utf-8"))
        out: dict[str, list[str]] = {}
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            surface = str(entry.get("surface", "")).strip()
            reading = kata_to_hira(str(entry.get("reading", "")).strip())
            if surface and reading:
                out.setdefault(surface, [])
                if reading not in out[surface]:
                    out[surface].append(reading)
        return out

    def _analyze_sudachi(self, text: str) -> list[TokenReading]:
        assert self._sudachi_tokenizer is not None
        tokens: list[TokenReading] = []
        for token in self._sudachi_tokenizer.tokenize(text, self._sudachi_mode):
            surface = token.surface()
            reading = kata_to_hira(token.reading_form() or "")
            if not reading or reading == "*":
                readings = self._dict_by_surface.get(surface, [])
                reading = readings[0] if readings else ""
                source = "dictionary" if reading else "unresolved"
                ambiguous = len(readings) > 1
            else:
                source = "sudachi"
                ambiguous = False
            tokens.append(
                TokenReading(
                    surface=surface,
                    reading=reading,
                    source=source,
                    ambiguous=ambiguous,
                )
            )
        return tokens

    def _analyze_dictionary(self, text: str) -> list[TokenReading]:
        tokens: list[TokenReading] = []
        i = 0
        while i < len(text):
            best_surface = ""
            best_readings: list[str] = []
            max_end = min(len(text), i + self._max_surface_len)
            for end in range(max_end, i, -1):
                candidate = text[i:end]
                readings = self._dict_by_surface.get(candidate)
                if readings:
                    best_surface = candidate
                    best_readings = readings
                    break
            if best_surface:
                tokens.append(
                    TokenReading(
                        surface=best_surface,
                        reading=best_readings[0],
                        source="dictionary",
                        ambiguous=len(best_readings) > 1,
                    )
                )
                i += len(best_surface)
                continue
            tokens.append(TokenReading(surface=text[i], reading="", source="unresolved"))
            i += 1
        return tokens


def _next_kana_run(surface: str, start: int) -> tuple[int, str] | None:
    if start >= len(surface) or not is_kana_text(surface[start]):
        return None
    j = start + 1
    while j < len(surface) and is_kana_text(surface[j]):
        j += 1
    return start, surface[start:j]
    return None


def annotate_token(surface: str, reading: str) -> str | None:
    if not has_kanji(surface):
        return surface
    reading = kata_to_hira(reading)
    if not reading:
        return None
    if all(is_kanji(ch) for ch in surface):
        return f"{surface}[{reading}]"

    out: list[str] = []
    rpos = 0
    i = 0
    while i < len(surface):
        ch = surface[i]
        if is_kanji(ch):
            j = i + 1
            while j < len(surface) and is_kanji(surface[j]):
                j += 1
            base = surface[i:j]
            next_kana = _next_kana_run(surface, j)
            if next_kana is None:
                base_reading = reading[rpos:]
            else:
                _, kana = next_kana
                normalized_kana = kata_to_hira(kana)
                match_at = reading.find(normalized_kana, rpos + 1)
                if match_at == -1:
                    match_at = reading.find(normalized_kana, rpos)
                if match_at < rpos:
                    return None
                base_reading = reading[rpos:match_at]
            if not base_reading:
                return None
            out.append(f"{base}[{base_reading}]")
            rpos += len(base_reading)
            i = j
            continue
        if is_kana_text(ch):
            j = i + 1
            while j < len(surface) and is_kana_text(surface[j]):
                j += 1
            kana = surface[i:j]
            normalized_kana = kata_to_hira(kana)
            if rpos >= len(reading):
                out.append(kana)
                i = j
                continue
            if reading.startswith(normalized_kana, rpos):
                rpos += len(normalized_kana)
            else:
                match_at = reading.find(normalized_kana, rpos)
                if match_at == -1:
                    return None
                rpos = match_at + len(normalized_kana)
            out.append(kana)
            i = j
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def annotate_text(
    text: str,
    analyzer: ReadingAnalyzer,
    *,
    row_key: str,
    source_csv: str,
    quiz_id: str,
    question_id: str,
    field: str,
    choice_id: str = "",
) -> AnnotatedText:
    original = text
    surface_text = strip_inline(text)
    if not has_kanji(surface_text):
        return AnnotatedText(text=surface_text, issues=(), changed=original != surface_text)

    issues: list[dict[str, str]] = []
    out: list[str] = []
    for token in analyzer.analyze(surface_text):
        if not has_kanji(token.surface):
            out.append(token.surface)
            continue
        annotated = annotate_token(token.surface, token.reading)
        if annotated is None:
            out.append(token.surface)
            issues.append(
                _audit_row(
                    row_key=row_key,
                    source_csv=source_csv,
                    quiz_id=quiz_id,
                    question_id=question_id,
                    field=field,
                    choice_id=choice_id,
                    surface=token.surface,
                    reading=token.reading,
                    status="unresolved",
                    source=token.source,
                    original_text=original,
                    annotated_text="",
                    notes="could not align token surface with reading",
                )
            )
            continue
        out.append(annotated)
        if token.ambiguous:
            issues.append(
                _audit_row(
                    row_key=row_key,
                    source_csv=source_csv,
                    quiz_id=quiz_id,
                    question_id=question_id,
                    field=field,
                    choice_id=choice_id,
                    surface=token.surface,
                    reading=token.reading,
                    status="ambiguous_dictionary",
                    source=token.source,
                    original_text=original,
                    annotated_text="",
                    notes="multiple local dictionary readings; selected first",
                )
            )

    annotated_text = "".join(out)
    uncovered = uncovered_kanji_runs(annotated_text)
    for run in uncovered:
        issues.append(
            _audit_row(
                row_key=row_key,
                source_csv=source_csv,
                quiz_id=quiz_id,
                question_id=question_id,
                field=field,
                choice_id=choice_id,
                surface=run,
                reading="",
                status="uncovered",
                source="inline",
                original_text=original,
                annotated_text=annotated_text,
                notes="kanji remains outside inline ruby markup",
            )
        )
    if annotated_text != original and not issues:
        issues.append(
            _audit_row(
                row_key=row_key,
                source_csv=source_csv,
                quiz_id=quiz_id,
                question_id=question_id,
                field=field,
                choice_id=choice_id,
                surface="",
                reading="",
                status="missing_inline",
                source="generated",
                original_text=original,
                annotated_text=annotated_text,
                notes="run with --write-csv to apply generated furigana",
            )
        )
    return AnnotatedText(
        text=annotated_text,
        issues=tuple(issues),
        changed=annotated_text != original,
    )


def _audit_row(**values: str) -> dict[str, str]:
    return {field: values.get(field, "") for field in AUDIT_FIELDS}


def process_questions(
    rows: list[dict[str, str]],
    analyzer: ReadingAnalyzer,
    *,
    write: bool,
) -> list[dict[str, str]]:
    audit_rows: list[dict[str, str]] = []
    for row in rows:
        quiz_id = row["quiz_id"].strip()
        question_id = row["question_id"].strip()
        for field in QUESTION_TEXT_FIELDS:
            audit = annotate_text(
                row.get(field, ""),
                analyzer,
                row_key=f"question|{quiz_id}|{question_id}|{field}",
                source_csv=QUESTIONS_CSV.name,
                quiz_id=quiz_id,
                question_id=question_id,
                field=field,
            )
            audit_rows.extend(audit.issues)
            if write and audit.changed and not _has_blocking_issue(audit.issues):
                row[field] = audit.text
        for field in QUESTION_PIPE_FIELDS:
            values = split_pipe(row.get(field, ""))
            next_values: list[str] = []
            for idx, value in enumerate(values):
                audit = annotate_text(
                    value,
                    analyzer,
                    row_key=f"question|{quiz_id}|{question_id}|{field}[{idx}]",
                    source_csv=QUESTIONS_CSV.name,
                    quiz_id=quiz_id,
                    question_id=question_id,
                    field=f"{field}[{idx}]",
                )
                audit_rows.extend(audit.issues)
                next_values.append(
                    audit.text if write and not _has_blocking_issue(audit.issues) else value
                )
            if write:
                row[field] = join_pipe(next_values)
    return audit_rows


def process_choices(
    rows: list[dict[str, str]],
    analyzer: ReadingAnalyzer,
    *,
    write: bool,
) -> list[dict[str, str]]:
    audit_rows: list[dict[str, str]] = []
    for row in rows:
        quiz_id = row["quiz_id"].strip()
        question_id = row["question_id"].strip()
        choice_id = row["choice_id"].strip()
        for field in CHOICE_TEXT_FIELDS:
            audit = annotate_text(
                row.get(field, ""),
                analyzer,
                row_key=f"choice|{quiz_id}|{question_id}|{choice_id}|{field}",
                source_csv=CHOICES_CSV.name,
                quiz_id=quiz_id,
                question_id=question_id,
                field=field,
                choice_id=choice_id,
            )
            audit_rows.extend(audit.issues)
            if write and audit.changed and not _has_blocking_issue(audit.issues):
                row[field] = audit.text
    return audit_rows


def _has_blocking_issue(rows: Iterable[dict[str, str]]) -> bool:
    return any(row.get("status") in {"unresolved", "uncovered"} for row in rows)


def write_audit(rows: list[dict[str, str]]) -> None:
    REVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)
    with REVIEW_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=AUDIT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write-csv",
        action="store_true",
        help="apply generated inline furigana to canonical CSV sources",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if any target field is unresolved or missing generated markup",
    )
    args = parser.parse_args()

    if args.write_csv and args.check:
        raise SystemExit("--write-csv and --check are mutually exclusive")

    analyzer = ReadingAnalyzer()
    q_fields, question_rows = read_csv(QUESTIONS_CSV)
    c_fields, choice_rows = read_csv(CHOICES_CSV)
    audit_rows = [
        *process_questions(question_rows, analyzer, write=args.write_csv),
        *process_choices(choice_rows, analyzer, write=args.write_csv),
    ]
    write_audit(audit_rows)

    if args.write_csv:
        write_csv(QUESTIONS_CSV, q_fields, question_rows)
        write_csv(CHOICES_CSV, c_fields, choice_rows)

    blocking = [
        row
        for row in audit_rows
        if row["status"] in {"unresolved", "uncovered", "missing_inline"}
    ]
    analyzer_name = "sudachi" if analyzer.has_sudachi else "dictionary-fallback"
    print(
        f"furigana_audit: analyzer={analyzer_name}, "
        f"audit_rows={len(audit_rows)}, blocking={len(blocking)}, "
        f"review_csv={REVIEW_PATH}"
    )
    if args.check and blocking:
        for row in blocking[:25]:
            print(
                "FAIL "
                f"{row['row_key']} status={row['status']} "
                f"surface={row['surface']} original={row['original_text']}"
            )
        if len(blocking) > 25:
            print(f"... {len(blocking) - 25} more failure(s)")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
