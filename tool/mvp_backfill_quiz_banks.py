# -*- coding: utf-8 -*-
"""
One-shot backfill: normalize particle diagnostic tags to kApprovedDiagnosticTags
and add jlptLevel, difficultyScore, grammarPoints, vocabulary, reviewStatus
to every question in assets/quiz_banks/*.json.

Run from repo root:  python tool/mvp_backfill_quiz_banks.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parent.parent
BANK_DIR = REPO / "assets" / "quiz_banks"

# Must match lib/data/approved_diagnostic_tags.dart
APPROVED: set[str] = {
    "particle_choice",
    "wa_ga",
    "ni_de",
    "wo_ga",
    "topic_contrast",
    "modifier_scope",
    "relative_clause",
    "sentence_parsing",
    "noun_modification",
    "omitted_subject",
    "omitted_object",
    "omitted_recipient",
    "dialogue_context",
    "implication",
    "register",
    "politeness",
    "directness",
    "keigo",
    "casual_speech",
    "transitivity",
    "jidoushi",
    "tadoushi",
    "intention",
    "verb_conjugation",
    "te_form",
    "nai_form",
    "masu_form",
    "past_form",
    "potential_form",
    "passive_form",
    "causative_form",
    "volitional_form",
    "conditional_ba_form",
    "tara_form",
    "imperative_form",
    "prohibitive_form",
    "dictionary_form",
    "ichidan",
    "godan",
    "irregular",
}

# legacy particle-only tags -> approved replacements
PARTICLE_TAG_MAP: dict[str, tuple[str, ...]] = {
    "wa_topic_contrast": ("topic_contrast", "wa_ga"),
    "ni_time": ("ni_de",),
    "ni_target": ("ni_de",),
    "ni_existence": ("ni_de",),
    "de_means_cause": ("ni_de",),
    "wo_path": ("wo_ga",),
    "to_accompaniment": ("dialogue_context",),
    "to_quotation": ("dialogue_context",),
    "he_ni": ("ni_de",),
    "kara_made": ("topic_contrast",),
    "yori_hodo": ("topic_contrast", "wa_ga"),
    "mo_dake_shika": ("topic_contrast",),
    "no_possession": ("noun_modification",),
    "ga_potential_object": ("wa_ga", "potential_form"),
}

# Kana/particle strings to skip as standalone "vocabulary" (keep longer compounds)
_PARTICLE_LIKE = frozenset(
    "はがをにもでとへのやかならけどってぞ"
)

_RE_JA = re.compile(r"[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9fff\u3005\u30fc]+")


def _strip_speakers(s: str) -> str:
    return s.replace("A: ", "").replace("B: ", "")


def extract_vocabulary(japanese: str) -> list[str]:
    s = _strip_speakers(japanese)
    s = re.sub(r"_+", " ", s)
    s = s.replace("→", " ")
    found = _RE_JA.findall(s)
    out: list[str] = []
    seen: set[str] = set()
    for w in found:
        w = w.strip()
        if not w or w in seen:
            continue
        if len(w) == 1 and w in _PARTICLE_LIKE:
            continue
        seen.add(w)
        out.append(w)
    if not out:
        m = _RE_JA.search(s)
        if m:
            out = [m.group(0)]
    return out[:12]


def jlpt_and_score(
    diff: str, index: int, total: int
) -> tuple[str, int]:
    """Assign band and 1–5 from position in bank and root difficulty hint."""
    p = (index + 1) / max(total, 1)
    # Base curve
    if p <= 0.2:
        jlpt, base = "N4", 1
    elif p <= 0.45:
        jlpt, base = "N4-N3", 2
    elif p <= 0.7:
        jlpt, base = "N3", 3
    elif p <= 0.9:
        jlpt, base = "N3-N2", 4
    else:
        jlpt, base = "N3-N2", 5

    if diff == "N4":
        jlpt = "N4" if p < 0.75 else "N4-N3"
    elif diff == "N2":
        jlpt = "N3-N2" if p < 0.5 else "N2"
    elif diff == "N3-N2":
        if p > 0.35:
            jlpt = "N3-N2" if p < 0.92 else "N2"
        else:
            jlpt = "N3"

    score = min(5, max(1, base + (1 if p > 0.85 else 0)))
    return jlpt, score


def normalize_question_tags(quiz_id: str, tags: list[str]) -> list[str]:
    out: list[str] = []
    for t in tags:
        if t in APPROVED:
            out.append(t)
        elif t in PARTICLE_TAG_MAP:
            out.extend(PARTICLE_TAG_MAP[t])
    # Dedupe preserve order
    seen: set[str] = set()
    deduped: list[str] = []
    for t in out:
        if t not in seen:
            seen.add(t)
            deduped.append(t)
    if quiz_id == "particleForensics" and "particle_choice" not in deduped:
        deduped.insert(0, "particle_choice")
    return deduped


def grammar_points_for(quiz_id: str, q: dict[str, Any]) -> list[str]:
    if quiz_id == "particleForensics":
        cid = q.get("correctAnswerId")
        label = ""
        for c in q.get("choices") or []:
            if c.get("id") == cid:
                label = str(c.get("label", "")).strip()
                break
        if label:
            return [f"助詞「{label}」の選択", "意味と述語に合う格のマーク"]
        return ["助詞の選択", "格関係の判断"]

    if quiz_id == "clauseUntangler":
        return ["連体修飾のかかり先", "名詞を説明する節の範囲"]

    if quiz_id == "omissionDetective":
        return ["省略された成分の推定", "会話文脈からの照応"]

    if quiz_id == "registerRadar":
        return ["場面に合う文体・敬さ", "社会的距離と表現の選択"]

    if quiz_id == "transitivityDuel":
        return ["自動詞・他動詞の対照", "叙述の焦点と項の取り方"]

    if quiz_id == "verbConjugation":
        tags = q.get("diagnosticTags") or []
        g = "動詞の活用形の識別"
        if "te_form" in tags:
            return [g, "て形の生成"]
        if "nai_form" in tags:
            return [g, "ない形の生成"]
        if "masu_form" in tags:
            return [g, "丁寧形（ます）の生成"]
        if "past_form" in tags:
            return [g, "た形の生成"]
        if "potential_form" in tags:
            return [g, "可能形の生成"]
        if "passive_form" in tags:
            return [g, "受身形の生成"]
        if "causative_form" in tags:
            return [g, "使役形の生成"]
        if "volitional_form" in tags:
            return [g, "意志形の生成"]
        if "conditional_ba_form" in tags:
            return [g, "ば条件の形"]
        if "tara_form" in tags:
            return [g, "たらの形"]
        if "imperative_form" in tags:
            return [g, "命令形の形"]
        if "prohibitive_form" in tags:
            return [g, "禁止形（～な）"]
        if "dictionary_form" in tags:
            return [g, "辞書形への復元"]
        if "keigo" in tags:
            return [g, "敬語動詞の語形"]
        return [g, "活用パターンの識別"]

    return ["文法の理解", "形式の判断"]


def process_quiz(data: dict[str, Any]) -> dict[str, Any]:
    quiz_id = data["id"]
    diff = str(data.get("difficulty", "N4-N3"))
    questions = data["questions"]
    total = len(questions)

    # Quiz-level tag union (particle normalization)
    all_quiz_tags: set[str] = set()

    for i, q in enumerate(questions):
        tags = list(q.get("diagnosticTags") or [])
        if quiz_id == "particleForensics":
            tags = normalize_question_tags(quiz_id, tags)
        else:
            tags = [t for t in tags if t in APPROVED]
        q["diagnosticTags"] = tags
        for t in tags:
            all_quiz_tags.add(t)

        jlpt, score = jlpt_and_score(diff, i, total)
        q["jlptLevel"] = jlpt
        q["difficultyScore"] = score
        q["grammarPoints"] = grammar_points_for(quiz_id, q)
        voc = extract_vocabulary(q.get("japanese", ""))
        if not voc:
            voc = ["表現"]
        q["vocabulary"] = voc
        q["reviewStatus"] = "draft"

    data["diagnosticTags"] = sorted(all_quiz_tags)
    return data


def main() -> None:
    files = sorted(BANK_DIR.glob("*.json"))
    for path in files:
        raw = path.read_text(encoding="utf-8")
        data = json.loads(raw)
        if not isinstance(data, dict):
            raise SystemExit(f"expected object in {path}")
        updated = process_quiz(data)
        path.write_text(
            json.dumps(updated, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"OK {path.name} ({len(updated['questions'])} questions)")


if __name__ == "__main__":
    main()
