#!/usr/bin/env python3
"""CSV-first content pipeline for quizzes, dictionary, and compiled artifacts."""
from __future__ import annotations

import csv
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


REPO = Path(__file__).resolve().parent.parent
ASSETS_DIR = REPO / "assets"
QUIZ_DIR = ASSETS_DIR / "quiz_banks"
DICT_PATH = ASSETS_DIR / "dictionary" / "japanese_lexicon.json"
COMPILED_DIR = ASSETS_DIR / "compiled"
COMPILED_QUIZ_DIR = COMPILED_DIR / "quiz_banks"
DATA_SRC_DIR = REPO / "data-src"
QUIZ_META_CSV = DATA_SRC_DIR / "quiz" / "quizzes.csv"
QUESTIONS_CSV = DATA_SRC_DIR / "quiz" / "questions.csv"
CHOICES_CSV = DATA_SRC_DIR / "quiz" / "choices.csv"
WORDBANK_CSV = DATA_SRC_DIR / "wordbank" / "wordbank.csv"


QUIZ_FILE_BY_ID = {
    "particleForensics": "particle_forensics.json",
    "clauseUntangler": "clause_untangler.json",
    "omissionDetective": "omission_detective.json",
    "registerRadar": "register_radar.json",
    "transitivityDuel": "transitivity_duel.json",
    "verbConjugation": "verb_conjugation.json",
}


def _split_pipe(value: str | None) -> list[str]:
    if not value:
        return []
    return [p.strip() for p in value.split("|") if p.strip()]


def _join_pipe(values: list[str]) -> str:
    return " | ".join(v.strip() for v in values if v.strip())


def _read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def _write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def export_csv_sources() -> None:
    quiz_rows: list[dict[str, str]] = []
    question_rows: list[dict[str, str]] = []
    choice_rows: list[dict[str, str]] = []
    word_rows: list[dict[str, str]] = []

    for quiz_id, filename in QUIZ_FILE_BY_ID.items():
        doc = json.loads((QUIZ_DIR / filename).read_text(encoding="utf-8"))
        quiz_rows.append(
            {
                "quiz_id": quiz_id,
                "title": str(doc.get("title", "")),
                "subtitle": str(doc.get("subtitle", "")),
                "description": str(doc.get("description", "")),
                "difficulty": str(doc.get("difficulty", "")),
                "diagnostic_tags": _join_pipe(list(doc.get("diagnosticTags", []))),
            }
        )
        for q_idx, q in enumerate(doc.get("questions", []), start=1):
            question_rows.append(
                {
                    "quiz_id": quiz_id,
                    "question_id": str(q.get("id", "")),
                    "sort_order": str(q_idx),
                    "type": str(q.get("type", "multipleChoice")),
                    "prompt": str(q.get("prompt", "")),
                    "prompt_en": str(q.get("promptEn", "")),
                    "context": str(q.get("context", "") or ""),
                    "context_en": str(q.get("contextEn", "") or ""),
                    "japanese": str(q.get("japanese", "")),
                    "japanese_en": str(q.get("japaneseEn", "")),
                    "correct_answer_id": str(q.get("correctAnswerId", "")),
                    "explanation": str(q.get("explanation", "")),
                    "explanation_en": str(q.get("explanationEn", "")),
                    "diagnostic_tags": _join_pipe(list(q.get("diagnosticTags", []))),
                    "jlpt_level": str(q.get("jlptLevel", "") or ""),
                    "difficulty_score": str(q.get("difficultyScore", "") or ""),
                    "grammar_points": _join_pipe(list(q.get("grammarPoints", []))),
                    "vocabulary": _join_pipe(list(q.get("vocabulary", []))),
                    "review_status": str(q.get("reviewStatus", "") or ""),
                    "review_notes": str(q.get("reviewNotes", "") or ""),
                    "source": str(q.get("source", "") or ""),
                    "author": str(q.get("author", "") or ""),
                }
            )
            for c_idx, c in enumerate(q.get("choices", []), start=1):
                choice_rows.append(
                    {
                        "quiz_id": quiz_id,
                        "question_id": str(q.get("id", "")),
                        "choice_id": str(c.get("id", "")),
                        "sort_order": str(c_idx),
                        "label": str(c.get("label", "")),
                        "label_en": str(c.get("labelEn", "") or ""),
                        "explanation": str(c.get("explanation", "") or ""),
                        "explanation_en": str(c.get("explanationEn", "") or ""),
                    }
                )

    dictionary = json.loads(DICT_PATH.read_text(encoding="utf-8"))
    for entry in dictionary:
        word_rows.append(
            {
                "surface": str(entry.get("surface", "")),
                "reading": str(entry.get("reading", "")),
                "part_of_speech": str(entry.get("partOfSpeech", "")),
                "definitions": _join_pipe(list(entry.get("definitions", []))),
                "jlpt_level": str(entry.get("jlptLevel", "") or ""),
                "tags": _join_pipe(list(entry.get("tags", []))),
            }
        )

    quiz_rows.sort(key=lambda r: r["quiz_id"])
    question_rows.sort(key=lambda r: (r["quiz_id"], int(r["sort_order"]), r["question_id"]))
    choice_rows.sort(
        key=lambda r: (r["quiz_id"], r["question_id"], int(r["sort_order"]), r["choice_id"])
    )
    word_rows.sort(key=lambda r: (r["surface"], r["reading"], r["part_of_speech"]))

    _write_csv(
        QUIZ_META_CSV,
        ["quiz_id", "title", "subtitle", "description", "difficulty", "diagnostic_tags"],
        quiz_rows,
    )
    _write_csv(
        QUESTIONS_CSV,
        [
            "quiz_id",
            "question_id",
            "sort_order",
            "type",
            "prompt",
            "prompt_en",
            "context",
            "context_en",
            "japanese",
            "japanese_en",
            "correct_answer_id",
            "explanation",
            "explanation_en",
            "diagnostic_tags",
            "jlpt_level",
            "difficulty_score",
            "grammar_points",
            "vocabulary",
            "review_status",
            "review_notes",
            "source",
            "author",
        ],
        question_rows,
    )
    _write_csv(
        CHOICES_CSV,
        [
            "quiz_id",
            "question_id",
            "choice_id",
            "sort_order",
            "label",
            "label_en",
            "explanation",
            "explanation_en",
        ],
        choice_rows,
    )
    _write_csv(
        WORDBANK_CSV,
        ["surface", "reading", "part_of_speech", "definitions", "jlpt_level", "tags"],
        word_rows,
    )
    print("Exported canonical CSV source tables under data-src/.")


@dataclass(frozen=True)
class ChoiceRow:
    quiz_id: str
    question_id: str
    choice_id: str
    sort_order: int
    label: str
    label_en: str
    explanation: str
    explanation_en: str


def _load_choice_rows() -> dict[tuple[str, str], list[ChoiceRow]]:
    rows = _read_csv(CHOICES_CSV)
    out: dict[tuple[str, str], list[ChoiceRow]] = {}
    for row in rows:
        key = (row["quiz_id"].strip(), row["question_id"].strip())
        out.setdefault(key, []).append(
            ChoiceRow(
                quiz_id=key[0],
                question_id=key[1],
                choice_id=row["choice_id"].strip(),
                sort_order=int(row["sort_order"].strip()),
                label=row["label"].strip(),
                label_en=row["label_en"].strip(),
                explanation=row["explanation"].strip(),
                explanation_en=row["explanation_en"].strip(),
            )
        )
    for key, values in out.items():
        values.sort(key=lambda c: (c.sort_order, c.choice_id))
        out[key] = values
    return out


def generate_assets_from_csv() -> None:
    quiz_rows = _read_csv(QUIZ_META_CSV)
    question_rows = _read_csv(QUESTIONS_CSV)
    choices_by_question = _load_choice_rows()
    meta_by_id = {r["quiz_id"].strip(): r for r in quiz_rows}

    questions_by_quiz: dict[str, list[dict[str, Any]]] = {}
    for row in question_rows:
        quiz_id = row["quiz_id"].strip()
        question_id = row["question_id"].strip()
        q: dict[str, Any] = {
            "id": question_id,
            "type": row["type"].strip() or "multipleChoice",
            "prompt": row["prompt"],
            "promptEn": row["prompt_en"],
            "japanese": row["japanese"],
            "japaneseEn": row["japanese_en"],
            "correctAnswerId": row["correct_answer_id"].strip(),
            "explanation": row["explanation"],
            "explanationEn": row["explanation_en"],
            "diagnosticTags": _split_pipe(row["diagnostic_tags"]),
        }
        if row["context"].strip():
            q["context"] = row["context"]
        if row["context_en"].strip():
            q["contextEn"] = row["context_en"]
        if row["jlpt_level"].strip():
            q["jlptLevel"] = row["jlpt_level"].strip()
        if row["difficulty_score"].strip():
            q["difficultyScore"] = int(row["difficulty_score"].strip())
        gp = _split_pipe(row["grammar_points"])
        if gp:
            q["grammarPoints"] = gp
        vocab = _split_pipe(row["vocabulary"])
        if vocab:
            q["vocabulary"] = vocab
        if row["review_status"].strip():
            q["reviewStatus"] = row["review_status"].strip()
        if row["review_notes"].strip():
            q["reviewNotes"] = row["review_notes"].strip()
        if row["source"].strip():
            q["source"] = row["source"].strip()
        if row["author"].strip():
            q["author"] = row["author"].strip()

        choices = []
        for c in choices_by_question.get((quiz_id, question_id), []):
            choice: dict[str, str] = {"id": c.choice_id, "label": c.label}
            if c.label_en:
                choice["labelEn"] = c.label_en
            if c.explanation:
                choice["explanation"] = c.explanation
            if c.explanation_en:
                choice["explanationEn"] = c.explanation_en
            choices.append(choice)
        q["choices"] = choices
        questions_by_quiz.setdefault(quiz_id, []).append((int(row["sort_order"]), q))

    QUIZ_DIR.mkdir(parents=True, exist_ok=True)
    COMPILED_QUIZ_DIR.mkdir(parents=True, exist_ok=True)
    catalog = {"quizzes": []}
    for quiz_id in QUIZ_FILE_BY_ID:
        meta = meta_by_id[quiz_id]
        ordered_questions = [
            q for _, q in sorted(questions_by_quiz.get(quiz_id, []), key=lambda x: x[0])
        ]
        quiz_doc = {
            "id": quiz_id,
            "title": meta["title"],
            "subtitle": meta["subtitle"],
            "description": meta["description"],
            "difficulty": meta["difficulty"],
            "diagnosticTags": _split_pipe(meta["diagnostic_tags"]),
            "questions": ordered_questions,
        }
        target = QUIZ_DIR / QUIZ_FILE_BY_ID[quiz_id]
        target.write_text(json.dumps(quiz_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        compact_target = COMPILED_QUIZ_DIR / f"{quiz_id}.json"
        compact_target.write_text(
            json.dumps(quiz_doc, ensure_ascii=False, separators=(",", ":")),
            encoding="utf-8",
        )
        catalog["quizzes"].append(
            {
                "id": quiz_id,
                "title": quiz_doc["title"],
                "subtitle": quiz_doc["subtitle"],
                "description": quiz_doc["description"],
                "difficulty": quiz_doc["difficulty"],
                "diagnosticTags": quiz_doc["diagnosticTags"],
            }
        )

    (QUIZ_DIR / "quiz_catalog.json").write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    COMPILED_DIR.mkdir(parents=True, exist_ok=True)
    (COMPILED_DIR / "quiz_catalog.json").write_text(
        json.dumps(catalog, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )

    dictionary_rows = _read_csv(WORDBANK_CSV)
    dictionary = []
    for row in dictionary_rows:
        entry: dict[str, Any] = {
            "surface": row["surface"].strip(),
            "reading": row["reading"].strip(),
            "partOfSpeech": row["part_of_speech"].strip(),
            "definitions": _split_pipe(row["definitions"]),
        }
        if row["jlpt_level"].strip():
            entry["jlptLevel"] = row["jlpt_level"].strip()
        tags = _split_pipe(row["tags"])
        if tags:
            entry["tags"] = tags
        dictionary.append(entry)

    dictionary.sort(key=lambda e: (e["surface"], e["reading"], e["partOfSpeech"]))
    DICT_PATH.parent.mkdir(parents=True, exist_ok=True)
    DICT_PATH.write_text(json.dumps(dictionary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (COMPILED_DIR / "dictionary_lexicon.json").write_text(
        json.dumps(dictionary, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print("Generated assets from canonical CSV sources.")


def compile_arrow_artifacts() -> None:
    try:
        import pyarrow as pa
        import pyarrow.feather as feather
    except ImportError as exc:
        raise SystemExit(
            "pyarrow is required for Arrow compilation. Install with `pip install pyarrow`."
        ) from exc

    COMPILED_DIR.mkdir(parents=True, exist_ok=True)
    COMPILED_QUIZ_DIR.mkdir(parents=True, exist_ok=True)

    quiz_meta_rows = _read_csv(QUIZ_META_CSV)
    quiz_table = pa.Table.from_pylist(quiz_meta_rows)
    feather.write_feather(quiz_table, COMPILED_DIR / "quiz_metadata.feather")

    question_rows = _read_csv(QUESTIONS_CSV)
    question_table = pa.Table.from_pylist(question_rows)
    feather.write_feather(question_table, COMPILED_DIR / "quiz_questions.feather")

    choice_rows = _read_csv(CHOICES_CSV)
    choice_table = pa.Table.from_pylist(choice_rows)
    feather.write_feather(choice_table, COMPILED_DIR / "quiz_choices.feather")

    word_rows = _read_csv(WORDBANK_CSV)
    word_table = pa.Table.from_pylist(word_rows)
    feather.write_feather(word_table, COMPILED_DIR / "wordbank.feather")
    print("Compiled Arrow Feather artifacts under assets/compiled/.")
