#!/usr/bin/env python3
"""
Adds English parallel fields (promptEn, japaneseEn, contextEn, explanationEn,
choice labelEn/explanationEn) to bundled quiz_bank JSON files.

Uses offline Argos Translate (install: pip install argostranslate, then
install the ja→en package once — see README or run with argos packaged).

    python tool/backfill_quiz_english.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import argostranslate.translate  # type: ignore[import-untyped]

_REPO = Path(__file__).resolve().parent.parent
_BANKS_DIR = _REPO / "assets" / "quiz_banks"
_FILES = [
    _BANKS_DIR / "particle_forensics.json",
    _BANKS_DIR / "clause_untangler.json",
    _BANKS_DIR / "omission_detective.json",
    _BANKS_DIR / "register_radar.json",
    _BANKS_DIR / "transitivity_duel.json",
    _BANKS_DIR / "verb_conjugation.json",
]

_JP_RE = re.compile(r"[\u3040-\u30ff\u4e00-\u9faf]")

PARTICLE_LABEL_EN: dict[str, str] = {
    "を": "を (direct object marker)",
    "に": "に (direction / endpoint / indirect object)",
    "が": "が (subject / exhaustive focus)",
    "は": "は (topic / contrast)",
    "で": "で (means / venue / scope of action)",
    "へ": "へ (direction)",
    "も": "も (also)",
    "と": "と (and / with / quotation)",
    "から": "から (from / since)",
    "まで": "まで (until)",
    "や": "や (and … among others)",
    "の": "の (possessor / noun modifier)",
    "か": "か (question)",
    "ね": "ね (seeking agreement)",
}


def contains_japanese(s: str) -> bool:
    return bool(_JP_RE.search(s))


class LocalTranslator:
    def __init__(self) -> None:
        self._cache: dict[str, str] = {}

    def translate(self, text: str) -> str:
        text = text.strip()
        if not text:
            return ""
        if text in self._cache:
            return self._cache[text]
        if not contains_japanese(text):
            self._cache[text] = text
            return text
        out = argostranslate.translate.translate(text, "ja", "en").strip()
        self._cache[text] = out
        return out


def label_en(translator: LocalTranslator, raw_label: str) -> str:
    s = raw_label.strip()
    if not s:
        return s
    if s in PARTICLE_LABEL_EN:
        return PARTICLE_LABEL_EN[s]
    if not contains_japanese(s):
        return s
    gloss = translator.translate(s)
    if s not in gloss and len(s) <= 48:
        return f"{s} ({gloss})".strip()
    return gloss


def augment_question(translator: LocalTranslator, q: dict) -> None:
    prompt = q["prompt"]
    japanese = q["japanese"]
    explanation = q["explanation"]
    ctx = q.get("context")

    q["promptEn"] = translator.translate(prompt) if contains_japanese(prompt) else prompt
    q["japaneseEn"] = (
        translator.translate(japanese) if contains_japanese(japanese) else japanese
    )
    q["explanationEn"] = (
        translator.translate(explanation)
        if contains_japanese(explanation)
        else explanation
    )

    if ctx is None or (isinstance(ctx, str) and not ctx.strip()):
        q["context"] = None
        q.pop("contextEn", None)
    else:
        assert isinstance(ctx, str)
        c = ctx.strip()
        q["context"] = c
        q["contextEn"] = translator.translate(c) if contains_japanese(c) else c

    for ch in q["choices"]:
        ch["labelEn"] = label_en(translator, ch["label"])
        ex = ch.get("explanation")
        if ex is None or (isinstance(ex, str) and not str(ex).strip()):
            ch["explanation"] = None
            ch.pop("explanationEn", None)
        else:
            ex_s = str(ex).strip()
            ch["explanation"] = ex_s
            ch["explanationEn"] = (
                translator.translate(ex_s) if contains_japanese(ex_s) else ex_s
            )


def main() -> None:
    try:
        _ = argostranslate.translate.translate("テスト", "ja", "en")
    except Exception as exc:  # noqa: BLE001
        print(
            "Argos ja→en not available. Install: pip install argostranslate "
            "then install the ja_en package (see Argos docs).",
            file=sys.stderr,
        )
        print(exc, file=sys.stderr)
        raise SystemExit(1) from exc

    translator = LocalTranslator()
    total_q = 0
    for path in _FILES:
        print(path.name, flush=True)
        doc = json.loads(path.read_text(encoding="utf-8"))
        for q in doc["questions"]:
            augment_question(translator, q)
            total_q += 1
        path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"done questions={total_q} cache_size={len(translator._cache)}", flush=True)


if __name__ == "__main__":
    main()
