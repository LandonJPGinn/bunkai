#!/usr/bin/env python3
"""Align promptEn with the exam instruction in `prompt` (English copy already there)."""

from __future__ import annotations

import json
import re
from pathlib import Path

_REPO = Path(__file__).resolve().parent.parent
_PATH = _REPO / "assets" / "quiz_banks" / "transitivity_duel.json"

_JP_PROMPT = re.compile(r"[\u3040-\u9faf]")

# Prompt field is Japanese-only for these (no leading Choose/Which).
_JP_PROMPT_EN: dict[str, str] = {
    "td_019": (
        "Among descriptions of the exit, which sentence does not explicitly "
        "say who opened the door?"
    ),
    "td_053": (
        "Throwing away an old machine: which sentence attaches を correctly "
        "to the transitive verb?"
    ),
    "td_063": (
        "Wrapping shoes in newspaper: which sentence correctly marks the "
        "transitive object with を?"
    ),
}


def main() -> None:
    data = json.loads(_PATH.read_text(encoding="utf-8"))
    for q in data["questions"]:
        qid = q["id"]
        prompt = (q.get("prompt") or "").strip()
        if qid in _JP_PROMPT_EN:
            q["promptEn"] = _JP_PROMPT_EN[qid]
        elif _JP_PROMPT.search(prompt) and not prompt.startswith(("Choose", "Which")):
            raise ValueError(f"Add English promptEn mapping for {qid}: {prompt!r}")
        else:
            q["promptEn"] = prompt
    _PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Synced promptEn for {len(data['questions'])} questions.")


if __name__ == "__main__":
    main()
