#!/usr/bin/env python3
"""Patch particle_forensics.json: unified promptEn + reviewed japaneseEn glosses."""

from __future__ import annotations

import json
from pathlib import Path

_REPO = Path(__file__).resolve().parent.parent
_PATH = _REPO / "assets" / "quiz_banks" / "particle_forensics.json"

_STANDARD_PROMPT = (
    "Choose the most natural particle for each blank "
    "(shown as ___ in the Japanese sentence)."
)

# Natural English gloss for the sentence (particle slot absorbed into fluent English).
_GLOSSES: dict[str, str] = {
    "pf_001": "I'll read a book.",
    "pf_002": "We arrived at the station.",
    "pf_003": "I study in the classroom.",
    "pf_004": "It's raining.",
    "pf_005": "I'll meet a friend.",
    "pf_006": "There's a meeting today.",
    "pf_007": "As for the manager—they're out right now.",
    "pf_008": "I go to the office by bus.",
    "pf_009": "I replied to the email.",
    "pf_010": "I put sugar in my coffee.",
    "pf_011": "Excuse me—where is the restroom?",
    "pf_012": "Please open the window.",
    "pf_013": "In winter it's very cold.",
    "pf_014": "I gave my younger sister a book.",
    "pf_015": "This dish is spicy.",
    "pf_016": "I'm a student.",
    "pf_017": "There's a bird outside the window.",
    "pf_018": "There are ten desks in the classroom.",
    "pf_019": "There's a bus stop in front of the station.",
    "pf_020": "I went shopping at the department store.",
    "pf_021": "I took time off because I was sick.",
    "pf_022": "I get up at nine.",
    "pf_023": "In spring the flowers are beautiful.",
    "pf_024": "I finished my homework.",
    "pf_025": "My mother is good at cooking.",
    "pf_026": "My younger brother is good at soccer.",
    "pf_027": "This shop's ramen is delicious.",
    "pf_028": "Who can speak Japanese?",
    "pf_029": "What do you want to do?",
    "pf_030": "I want to drink water.",
    "pf_031": "The room is quiet.",
    "pf_032": "The teacher came.",
    "pf_033": "My son became a doctor.",
    "pf_034": "I'll climb the tree.",
    "pf_035": "I'll cross the bridge.",
    "pf_036": "I'll turn the corner.",
    "pf_037": "I'll stop at the red light.",
    "pf_038": "I'll pass in front of the airport.",
    "pf_039": "I'll take a walk in the park.",
    "pf_040": "I'll go on a trip with my family.",
    "pf_041": "I'll go see a movie with a friend.",
    'pf_042': 'The teacher said, "Quiet."',
    'pf_043': 'He answered, "I\'m busy."',
    "pf_044": "I want to go to Japan.",
    "pf_045": "I commute to work by bicycle.",
    "pf_046": "I'll head north.",
    "pf_047": "I'm going on a business trip to Osaka.",
    "pf_048": "I'll go home.",
    "pf_049": "School starts at eight o'clock.",
    "pf_050": "The meeting continues until five in the afternoon.",
    "pf_051": "The station is close from here.",
    "pf_052": "There's a bus from the airport into town.",
    "pf_053": "I work from eight in the morning until ten at night.",
    "pf_054": "This book is expensive.",
    "pf_055": "Last year was colder than this year.",
    "pf_056": "My younger brother is taller than me.",
    "pf_057": "Tokyo is bigger than Osaka.",
    "pf_058": "Yesterday wasn't as hot as today.",
    "pf_059": "In the morning—and at night too—I work.",
    "pf_060": "I won't drink water.",
    "pf_061": "Today I'm only off from work.",
    "pf_062": "You can buy it for a hundred yen.",
    "pf_063": "I can't eat meat.",
    "pf_064": "Osaka Station is underground.",
    "pf_065": "I commute to university in Tokyo.",
    "pf_066": "My friend Tanaka came.",
    "pf_067": "My mother's cakes are sweet.",
    "pf_068": "I go to work by train.",
    "pf_069": "I eat rice with chopsticks.",
    "pf_070": "I'll mail the letter (with a stamp).",
    "pf_071": "I'll write on the blackboard.",
    "pf_072": "In a hurry, I caught the bus.",
    "pf_073": "There's an exam tomorrow.",
    "pf_074": "I don't understand this problem.",
    "pf_075": "I don't have enough money.",
    "pf_076": "It's close to the station.",
    "pf_077": "I don't drink coffee.",
    "pf_078": "Summer is hotter than winter.",
    "pf_079": "May I take pictures here?",
    "pf_080": "That building is a hospital.",
    "pf_081": "On days off I often take walks.",
    "pf_082": "She's good at singing.",
    "pf_083": "The train was late.",
    "pf_084": "I'm learning to swim at the beach.",
    "pf_085": "I'll wait for my friend at the café.",
    "pf_086": "I'll go out on the weekend.",
    "pf_087": "At the new shop, sushi is cheap.",
    "pf_088": "I'll sit on a bench in the park.",
    "pf_089": "I'll write the address on the envelope.",
    "pf_090": "The light is green.",
    'pf_091': 'My friend waved and said, "See you."',
    "pf_092": "I'll leave home.",
    "pf_093": "This is Tanaka speaking.",
    "pf_094": "I'll fly from the airport to Shanghai.",
    "pf_095": "I'll be back in the evening.",
    "pf_096": "After the exam I'll hang out.",
    "pf_097": "I saw a movie at the cinema.",
    "pf_098": "My older brother is studying abroad.",
    "pf_099": "This town used to be lively.",
    "pf_100": "The bus stop is here.",
}


def main() -> None:
    data = json.loads(_PATH.read_text(encoding="utf-8"))
    questions = data["questions"]
    assert len(questions) == 100
    for q in questions:
        qid = q["id"]
        q["promptEn"] = _STANDARD_PROMPT
        q["japaneseEn"] = _GLOSSES[qid]
    missing = set(_GLOSSES) - {q["id"] for q in questions}
    extra = {q["id"] for q in questions} - set(_GLOSSES)
    assert not missing and not extra, (missing, extra)
    _PATH.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(questions)} questions to {_PATH}")


if __name__ == "__main__":
    main()
