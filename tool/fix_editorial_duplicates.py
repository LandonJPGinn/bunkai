# -*- coding: utf-8 -*-
"""Targeted editorial fixes: unique register japanese lines, JP prompts, misc dupes."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
_TOOL = REPO / "tool"
if str(_TOOL) not in sys.path:
    sys.path.insert(0, str(_TOOL))
from mvp_backfill_quiz_banks import extract_vocabulary  # noqa: E402


def fix_register(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for q in data["questions"]:
        ctx = (q.get("context") or "").strip()
        q["prompt"] = "場面に合う表現を選びなさい。"
        q["japanese"] = f"{ctx} 次の中で最も適切な表現はどれか。"
        q["vocabulary"] = extract_vocabulary(q["japanese"] + " " + " ".join(
            c.get("label", "") for c in q.get("choices", [])
        ))
        if not q["vocabulary"]:
            q["vocabulary"] = ["表現"]
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"fixed {path.name}")


def fix_particle_prompts(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for q in data["questions"]:
        m = re.search(r"(\d+)$", q["id"].split("_")[-1])
        n = int(m.group(1)) if m else 0
        q["prompt"] = f"第{n}問：次の文の空所（___）に入る最も自然な助詞を選びなさい。"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"fixed {path.name} prompts")


def patch_omission(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for q in data["questions"]:
        if q["id"] == "od_050":
            q["prompt"] = "汚れが目立つ「これ」は、主に何を指すか。"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"patched {path.name}")


def patch_transitivity(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for q in data["questions"]:
        if q["id"] == "td_063":
            q["prompt"] = "新聞で包む靴：他動詞の対象として「を」が付いた正しい文はどれか。"
        elif q["id"] == "td_053":
            q["prompt"] = "機械を処分する話：他動詞に「を」が適切に付いた文はどれか。"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"patched {path.name}")


def main() -> None:
    banks = REPO / "assets" / "quiz_banks"
    fix_register(banks / "register_radar.json")
    fix_particle_prompts(banks / "particle_forensics.json")
    patch_omission(banks / "omission_detective.json")
    patch_transitivity(banks / "transitivity_duel.json")


if __name__ == "__main__":
    main()
