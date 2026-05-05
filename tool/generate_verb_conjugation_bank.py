# -*- coding: utf-8 -*-
"""One-off generator for assets/quiz_banks/verb_conjugation.json (150 questions)."""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path
from typing import Any

_TOOL_DIR = Path(__file__).resolve().parent
if str(_TOOL_DIR) not in sys.path:
    sys.path.insert(0, str(_TOOL_DIR))
from mvp_backfill_quiz_banks import (  # noqa: E402
    extract_vocabulary,
    grammar_points_for,
    jlpt_and_score,
)

random.seed(42)

# Full conjugation surfaces per lemma (verified godan/ichidan/irregular patterns).
# Keys: ます, て, た, ない, 可能, 受身, 使役, 意志, ば, たら, 命令, 禁止, 辞書
# 禁止 value is the full prohibitive (verb+な).
FORMS: dict[str, dict[str, str]] = {
    # ichidan
    "食べる": {
        "cls": "一段動詞",
        "ます": "食べます",
        "て": "食べて",
        "た": "食べた",
        "ない": "食べない",
        "可能": "食べられる",
        "受身": "食べられる",
        "使役": "食べさせる",
        "意志": "食べよう",
        "ば": "食べれば",
        "たら": "食べたら",
        "命令": "食べろ",
        "禁止": "食べるな",
        "辞書": "食べる",
    },
    "見る": {
        "cls": "一段動詞",
        "ます": "見ます",
        "て": "見て",
        "た": "見た",
        "ない": "見ない",
        "可能": "見られる",
        "受身": "見られる",
        "使役": "見させる",
        "意志": "見よう",
        "ば": "見れば",
        "たら": "見たら",
        "命令": "見ろ",
        "禁止": "見るな",
        "辞書": "見る",
    },
    "起きる": {
        "cls": "一段動詞",
        "ます": "起きます",
        "て": "起きて",
        "た": "起きた",
        "ない": "起きない",
        "可能": "起きられる",
        "受身": "起きられる",
        "使役": "起きさせる",
        "意志": "起きよう",
        "ば": "起きれば",
        "たら": "起きたら",
        "命令": "起きろ",
        "禁止": "起きるな",
        "辞書": "起きる",
    },
    "寝る": {
        "cls": "一段動詞",
        "ます": "寝ます",
        "て": "寝て",
        "た": "寝た",
        "ない": "寝ない",
        "可能": "寝られる",
        "受身": "寝られる",
        "使役": "寝させる",
        "意志": "寝よう",
        "ば": "寝れば",
        "たら": "寝たら",
        "命令": "寝ろ",
        "禁止": "寝るな",
        "辞書": "寝る",
    },
    "借りる": {
        "cls": "一段動詞",
        "ます": "借ります",
        "て": "借りて",
        "た": "借りた",
        "ない": "借りない",
        "可能": "借りられる",
        "受身": "借りられる",
        "使役": "借りさせる",
        "意志": "借りよう",
        "ば": "借りれば",
        "たら": "借りたら",
        "命令": "借りろ",
        "禁止": "借りるな",
        "辞書": "借りる",
    },
    # godan 着る（着衣）
    "着る": {
        "cls": "五段動詞",
        "ます": "着ます",
        "て": "着て",
        "た": "着た",
        "ない": "着ない",
        "可能": "着られる",
        "受身": "着られる",
        "使役": "着させる",
        "意志": "着よう",
        "ば": "着れば",
        "たら": "着たら",
        "命令": "着ろ",
        "禁止": "着るな",
        "辞書": "着る",
    },
    # irregular
    "する": {
        "cls": "不規則",
        "ます": "します",
        "て": "して",
        "た": "した",
        "ない": "しない",
        "可能": "できる",
        "受身": "される",
        "使役": "させる",
        "意志": "しよう",
        "ば": "すれば",
        "たら": "したら",
        "命令": "しろ",
        "禁止": "するな",
        "辞書": "する",
    },
    "来る": {
        "cls": "不規則",
        "ます": "来ます",
        "て": "来て",
        "た": "来た",
        "ない": "来ない",
        "可能": "来られる",
        "受身": "来られる",
        "使役": "来させる",
        "意志": "来よう",
        "ば": "くれば",
        "たら": "来たら",
        "命令": "来い",
        "禁止": "来るな",
        "辞書": "来る",
    },
    "行く": {
        "cls": "五段動詞",
        "ます": "行きます",
        "て": "行って",
        "た": "行った",
        "ない": "行かない",
        "可能": "行ける",
        "受身": "行かれる",
        "使役": "行かせる",
        "意志": "行こう",
        "ば": "行けば",
        "たら": "行ったら",
        "命令": "行け",
        "禁止": "行くな",
        "辞書": "行く",
    },
    "書く": {
        "cls": "五段動詞",
        "ます": "書きます",
        "て": "書いて",
        "た": "書いた",
        "ない": "書かない",
        "可能": "書ける",
        "受身": "書かれる",
        "使役": "書かせる",
        "意志": "書こう",
        "ば": "書けば",
        "たら": "書いたら",
        "命令": "書け",
        "禁止": "書くな",
        "辞書": "書く",
    },
    "聞く": {
        "cls": "五段動詞",
        "ます": "聞きます",
        "て": "聞いて",
        "た": "聞いた",
        "ない": "聞かない",
        "可能": "聞ける",
        "受身": "聞かれる",
        "使役": "聞かせる",
        "意志": "聞こう",
        "ば": "聞けば",
        "たら": "聞いたら",
        "命令": "聞け",
        "禁止": "聞くな",
        "辞書": "聞く",
    },
    "話す": {
        "cls": "五段動詞",
        "ます": "話します",
        "て": "話して",
        "た": "話した",
        "ない": "話さない",
        "可能": "話せる",
        "受身": "話される",
        "使役": "話させる",
        "意志": "話そう",
        "ば": "話せば",
        "たら": "話したら",
        "命令": "話せ",
        "禁止": "話すな",
        "辞書": "話す",
    },
    "読む": {
        "cls": "五段動詞",
        "ます": "読みます",
        "て": "読んで",
        "た": "読んだ",
        "ない": "読まない",
        "可能": "読める",
        "受身": "読まれる",
        "使役": "読ませる",
        "意志": "読もう",
        "ば": "読めば",
        "たら": "読んだら",
        "命令": "読め",
        "禁止": "読むな",
        "辞書": "読む",
    },
    "飲む": {
        "cls": "五段動詞",
        "ます": "飲みます",
        "て": "飲んで",
        "た": "飲んだ",
        "ない": "飲まない",
        "可能": "飲める",
        "受身": "飲まれる",
        "使役": "飲ませる",
        "意志": "飲もう",
        "ば": "飲めば",
        "たら": "飲んだら",
        "命令": "飲め",
        "禁止": "飲むな",
        "辞書": "飲む",
    },
    "待つ": {
        "cls": "五段動詞",
        "ます": "待ちます",
        "て": "待って",
        "た": "待った",
        "ない": "待たない",
        "可能": "待てる",
        "受身": "待たれる",
        "使役": "待たせる",
        "意志": "待とう",
        "ば": "待てば",
        "たら": "待ったら",
        "命令": "待て",
        "禁止": "待つな",
        "辞書": "待つ",
    },
    "買う": {
        "cls": "五段動詞",
        "ます": "買います",
        "て": "買って",
        "た": "買った",
        "ない": "買わない",
        "可能": "買える",
        "受身": "買われる",
        "使役": "買わせる",
        "意志": "買おう",
        "ば": "買えば",
        "たら": "買ったら",
        "命令": "買え",
        "禁止": "買うな",
        "辞書": "買う",
    },
    "帰る": {
        "cls": "五段動詞",
        "ます": "帰ります",
        "て": "帰って",
        "た": "帰った",
        "ない": "帰らない",
        "可能": "帰れる",
        "受身": "帰られる",
        "使役": "帰らせる",
        "意志": "帰ろう",
        "ば": "帰れば",
        "たら": "帰ったら",
        "命令": "帰れ",
        "禁止": "帰るな",
        "辞書": "帰る",
    },
    "入る": {
        "cls": "五段動詞",
        "ます": "入ります",
        "て": "入って",
        "た": "入った",
        "ない": "入らない",
        "可能": "入れる",
        "受身": "入られる",
        "使役": "入らせる",
        "意志": "入ろう",
        "ば": "入れば",
        "たら": "入ったら",
        "命令": "入れ",
        "禁止": "入るな",
        "辞書": "入る",
    },
    "走る": {
        "cls": "五段動詞",
        "ます": "走ります",
        "て": "走って",
        "た": "走った",
        "ない": "走らない",
        "可能": "走れる",
        "受身": "走られる",
        "使役": "走らせる",
        "意志": "走ろう",
        "ば": "走れば",
        "たら": "走ったら",
        "命令": "走れ",
        "禁止": "走るな",
        "辞書": "走る",
    },
    "死ぬ": {
        "cls": "五段動詞",
        "ます": "死にます",
        "て": "死んで",
        "た": "死んだ",
        "ない": "死なない",
        "可能": "死ねる",
        "受身": "死なれる",
        "使役": "死なせる",
        "意志": "死のう",
        "ば": "死ねば",
        "たら": "死んだら",
        "命令": "死ね",
        "禁止": "死ぬな",
        "辞書": "死ぬ",
    },
    "遊ぶ": {
        "cls": "五段動詞",
        "ます": "遊びます",
        "て": "遊んで",
        "た": "遊んだ",
        "ない": "遊ばない",
        "可能": "遊べる",
        "受身": "遊ばれる",
        "使役": "遊ばせる",
        "意志": "遊ぼう",
        "ば": "遊べば",
        "たら": "遊んだら",
        "命令": "遊べ",
        "禁止": "遊ぶな",
        "辞書": "遊ぶ",
    },
    "泳ぐ": {
        "cls": "五段動詞",
        "ます": "泳ぎます",
        "て": "泳いで",
        "た": "泳いだ",
        "ない": "泳がない",
        "可能": "泳げる",
        "受身": "泳がれる",
        "使役": "泳がせる",
        "意志": "泳ごう",
        "ば": "泳げば",
        "たら": "泳いだら",
        "命令": "泳げ",
        "禁止": "泳ぐな",
        "辞書": "泳ぐ",
    },
    "持つ": {
        "cls": "五段動詞",
        "ます": "持ちます",
        "て": "持って",
        "た": "持った",
        "ない": "持たない",
        "可能": "持てる",
        "受身": "持たれる",
        "使役": "持たせる",
        "意志": "持とう",
        "ば": "持てば",
        "たら": "持ったら",
        "命令": "持て",
        "禁止": "持つな",
        "辞書": "持つ",
    },
    "作る": {
        "cls": "五段動詞",
        "ます": "作ります",
        "て": "作って",
        "た": "作った",
        "ない": "作らない",
        "可能": "作れる",
        "受身": "作られる",
        "使役": "作らせる",
        "意志": "作ろう",
        "ば": "作れば",
        "たら": "作ったら",
        "命令": "作れ",
        "禁止": "作るな",
        "辞書": "作る",
    },
    "使う": {
        "cls": "五段動詞",
        "ます": "使います",
        "て": "使って",
        "た": "使った",
        "ない": "使わない",
        "可能": "使える",
        "受身": "使われる",
        "使役": "使わせる",
        "意志": "使おう",
        "ば": "使えば",
        "たら": "使ったら",
        "命令": "使え",
        "禁止": "使うな",
        "辞書": "使う",
    },
    "会う": {
        "cls": "五段動詞",
        "ます": "会います",
        "て": "会って",
        "た": "会った",
        "ない": "会わない",
        "可能": "会える",
        "受身": "会われる",
        "使役": "会わせる",
        "意志": "会おう",
        "ば": "会えば",
        "たら": "会ったら",
        "命令": "会え",
        "禁止": "会うな",
        "辞書": "会う",
    },
    "売る": {
        "cls": "五段動詞",
        "ます": "売ります",
        "て": "売って",
        "た": "売った",
        "ない": "売らない",
        "可能": "売れる",
        "受身": "売られる",
        "使役": "売らせる",
        "意志": "売ろう",
        "ば": "売れば",
        "たら": "売ったら",
        "命令": "売れ",
        "禁止": "売るな",
        "辞書": "売る",
    },
    "知る": {
        "cls": "五段動詞",
        "ます": "知ります",
        "て": "知って",
        "た": "知った",
        "ない": "知らない",
        "可能": "知れる",
        "受身": "知られる",
        "使役": "知らせる",
        "意志": "知ろう",
        "ば": "知れば",
        "たら": "知ったら",
        "命令": "知れ",
        "禁止": "知るな",
        "辞書": "知る",
    },
    "乗る": {
        "cls": "五段動詞",
        "ます": "乗ります",
        "て": "乗って",
        "た": "乗った",
        "ない": "乗らない",
        "可能": "乗れる",
        "受身": "乗られる",
        "使役": "乗らせる",
        "意志": "乗ろう",
        "ば": "乗れば",
        "たら": "乗ったら",
        "命令": "乗れ",
        "禁止": "乗るな",
        "辞書": "乗る",
    },
    "働く": {
        "cls": "五段動詞",
        "ます": "働きます",
        "て": "働いて",
        "た": "働いた",
        "ない": "働かない",
        "可能": "働ける",
        "受身": "働かれる",
        "使役": "働かせる",
        "意志": "働こう",
        "ば": "働けば",
        "たら": "働いたら",
        "命令": "働け",
        "禁止": "働くな",
        "辞書": "働く",
    },
}

KEIGO_FORMS = {
    "いらっしゃる": {
        "cls": "丁寧語（特殊）",
        "ます": "いらっしゃいます",
        "て": "いらっしゃって",
        "ない": "いらっしゃらない",
        "辞書": "いらっしゃる",
        "命令": "いらっしゃい",
    },
    "くださる": {
        "cls": "丁寧語（特殊）",
        "ます": "くださいます",
        "て": "くださって",
        "ない": "くださらない",
        "辞書": "くださる",
        "可能": "くだされる",
    },
    "いただく": {
        "cls": "謙譲語（特殊）",
        "ます": "いただきます",
        "て": "いただいて",
        "た": "いただいた",
        "ない": "いただけない",
        "辞書": "いただく",
        "意志": "いただこう",
    },
    "申し上げる": {
        "cls": "謙譲語（一段）",
        "ます": "申し上げます",
        "て": "申し上げて",
        "ない": "申し上げない",
        "辞書": "申し上げる",
        "ば": "申し上げれば",
    },
    "参る": {
        "cls": "謙譲語（五段）",
        "ます": "参ります",
        "て": "参って",
        "た": "参った",
        "ない": "参らない",
        "辞書": "参る",
        "ば": "参れば",
    },
}

VERB_ORDER = [
    "食べる",
    "見る",
    "起きる",
    "寝る",
    "借りる",
    "着る",
    "する",
    "来る",
    "行く",
    "書く",
    "聞く",
    "話す",
    "読む",
    "飲む",
    "待つ",
    "買う",
    "帰る",
    "入る",
    "走る",
    "死ぬ",
    "遊ぶ",
    "泳ぐ",
    "持つ",
    "作る",
    "使う",
    "会う",
    "売る",
    "知る",
    "乗る",
    "働く",
]

CORE_FORMS = [
    ("ます", "masu_form", "ます形（丁寧・非過去）", "Convert to ます-form (polite non-past)."),
    ("て", "te_form", "て形", "Convert to te-form."),
    ("た", "past_form", "た形（普通体・過去）", "Convert to plain past (た-form)."),
    ("ない", "nai_form", "ない形（普通体・非過去）", "Convert to negative plain (ない-form)."),
]

TAG_FOR_ADV = {
    "可能": ("potential_form", "可能形（普通体）", "Convert to potential plain."),
    "受身": ("passive_form", "受身形（普通体）", "Convert to passive plain."),
    "使役": ("causative_form", "使役形（普通体）", "Convert to causative plain."),
    "意志": ("volitional_form", "意志形（～よう）", "Convert to volitional (よう)."),
    "ば": ("conditional_ba_form", "ば条件（仮定）", "Convert to ば-conditional."),
    "たら": ("tara_form", "たら（仮定・発見）", "Convert to たら-form."),
    "命令": ("imperative_form", "命令形", "Convert to imperative."),
    "禁止": ("prohibitive_form", "禁止（～な）", "Choose the prohibitive (dictionary form + な)."),
    "辞書": ("dictionary_form", "辞書形（丁寧から）", "Convert polite ます-form back to dictionary form."),
}

CLASS_TAG = {
    "一段動詞": "ichidan",
    "五段動詞": "godan",
    "不規則": "irregular",
    "丁寧語（特殊）": "irregular",
    "謙譲語（特殊）": "irregular",
    "謙譲語（一段）": "ichidan",
    "謙譲語（五段）": "godan",
}


def distractors(lemma: str, form_key: str, correct: str, fdict: dict[str, str]) -> list[str]:
    """Return three plausible wrong answers."""
    wrong: list[str] = []
    pool = [
        v
        for k, v in fdict.items()
        if k not in ("cls",) and v != correct and isinstance(v, str)
    ]
    # Prefer mixing stem errors from same lemma’s other surfaces
    for p in pool:
        if p not in wrong and len(wrong) < 3:
            wrong.append(p)
    # Generic fillers if lemma has few keys (keigo)
    generic = [correct + "た", correct + "て", correct[:-1] + "す"] if len(correct) > 1 else []
    for g in generic:
        if g != correct and g not in wrong and len(wrong) < 3:
            wrong.append(g)
    # Pad from unrelated wrong shapes
    pad = ["ます", "ない", "た"]
    for p in pad:
        x = correct[:-1] + p if len(correct) > 1 else p
        if x != correct and x not in wrong and len(wrong) < 3:
            wrong.append(x)
    while len(wrong) < 3:
        wrong.append(correct + "さ")
    return wrong[:3]


def keigo_distractors(correct: str, bank: list[str]) -> list[str]:
    out: list[str] = []
    for b in bank:
        if b != correct and b not in out and len(out) < 3:
            out.append(b)
    while len(out) < 3:
        out.append(correct + "ます")
    return out[:3]


def _mvp_verb(
    lemma: str, ja_line: str, tags: list[str], bank_idx_zero: int
) -> dict[str, Any]:
    jlpt, score = jlpt_and_score("N4-N3", bank_idx_zero, 150)
    voc = extract_vocabulary(f"{lemma} {ja_line}")
    if not voc:
        voc = [lemma]
    gp = grammar_points_for(
        "verbConjugation", {"diagnosticTags": tags, "japanese": ja_line}
    )
    return {
        "jlptLevel": jlpt,
        "difficultyScore": score,
        "grammarPoints": gp,
        "vocabulary": voc,
        "reviewStatus": "draft",
    }


def make_question(
    qid: str,
    lemma: str,
    form_key: str,
    fdict: dict[str, str],
    prompt_suffix: str,
    ja_suffix: str,
    primary_tag: str,
    extra_tags: list[str],
    bank_idx_zero: int,
) -> dict[str, Any]:
    cls = fdict.get("cls", "")
    correct = fdict[form_key]
    dlist = distractors(lemma, form_key, correct, fdict)
    labels = [correct, dlist[0], dlist[1], dlist[2]]
    order = [0, 1, 2, 3]
    random.shuffle(order)
    shuffled = [labels[i] for i in order]
    correct_index = shuffled.index(correct)
    choice_ids = ["a", "b", "c", "d"]
    correct_id = choice_ids[correct_index]

    expl_form = {
        "ます": "丁寧語は連用形＋「ます」。",
        "て": "て形の作り方に従う。",
        "た": "た形は連用形＋「た」系。",
        "ない": "未然形＋「ない」。",
        "可能": "可能形の作り方に従う。",
        "受身": "受身形の作り方に従う。",
        "使役": "使役の語尾「せる／させる」を付ける。",
        "意志": "意志形は語尾のウ音便＋「う」系。",
        "ば": "仮定形＋「ば」。",
        "たら": "過去形＋「ら」。",
        "命令": "命令形の語尾を使う。",
        "禁止": "辞書形＋「な」で禁止。",
        "辞書": "丁寧の連用形から辞書形に戻す。",
    }.get(form_key, "")

    explanation = f"{cls}「{lemma}」：{expl_form} 正解は「{correct}」。"
    tags = ["verb_conjugation", primary_tag, CLASS_TAG.get(cls, "irregular")] + extra_tags
    ja_line = f"{lemma} → {ja_suffix}"

    return {
        "id": qid,
        "type": "multipleChoice",
        "prompt": f"{lemma} → {prompt_suffix}",
        "japanese": ja_line,
        "choices": [{"id": choice_ids[i], "label": shuffled[i]} for i in range(4)],
        "correctAnswerId": correct_id,
        "explanation": explanation,
        "diagnosticTags": tags,
        **_mvp_verb(lemma, ja_line, tags, bank_idx_zero),
    }


def build() -> dict[str, Any]:
    questions: list[dict[str, Any]] = []
    n = 1

    # 120 core: 30 verbs × 4 forms
    for lemma in VERB_ORDER:
        fdict = FORMS[lemma]
        for form_key, primary_tag, ja_sfx, prompt_sfx in CORE_FORMS:
            qid = f"vc_{n:03d}"
            questions.append(
                make_question(
                    qid,
                    lemma,
                    form_key,
                    fdict,
                    prompt_sfx,
                    ja_sfx,
                    primary_tag,
                    [],
                    n - 1,
                )
            )
            n += 1

    # 30 advanced slots — use real conjugations; special-case 来る for くる reading where useful
    advanced_plan: list[tuple[str, str]] = [
        ("食べる", "可能"),
        ("見る", "可能"),
        ("行く", "可能"),
        ("する", "可能"),
        ("書く", "受身"),
        ("話す", "受身"),
        ("売る", "受身"),
        ("読む", "使役"),
        ("待つ", "使役"),
        ("働く", "使役"),
        ("遊ぶ", "意志"),
        ("会う", "意志"),
        ("来る", "意志"),
        ("飲む", "ば"),
        ("買う", "ば"),
        ("寝る", "ば"),
        ("帰る", "たら"),
        ("死ぬ", "たら"),
        ("する", "たら"),
        ("走る", "命令"),
        ("起きる", "命令"),
        ("泳ぐ", "禁止"),
        ("借りる", "禁止"),
        ("聞く", "禁止"),
        ("見る", "辞書"),
        ("書く", "辞書"),
        ("行く", "辞書"),
        # keigo
        ("いらっしゃる", "ます"),
        ("いただく", "て"),
        ("申し上げる", "ない"),
    ]

    for lemma, fk in advanced_plan:
        if lemma in KEIGO_FORMS:
            fd = KEIGO_FORMS[lemma]
            tag_info = {
                "ます": ("masu_form", "ます形（丁寧）", "Convert to polite ます-form."),
                "て": ("te_form", "て形", "Convert to te-form."),
                "ない": ("nai_form", "ない形", "Convert to negative plain."),
            }.get(fk)
            if tag_info is None:
                raise ValueError(f"unsupported keigo form {fk} for {lemma}")
            primary, ja_sfx, prompt_sfx = tag_info
            correct = fd[fk]
            bank = [v for k, v in fd.items() if k != "cls" and isinstance(v, str)]
            dbs = keigo_distractors(correct, bank)
            labels = [correct, dbs[0], dbs[1], dbs[2]]
            order = [0, 1, 2, 3]
            random.shuffle(order)
            shuffled = [labels[i] for i in order]
            ci = shuffled.index(correct)
            cids = ["a", "b", "c", "d"]
            cls = fd["cls"]
            expl = f"{cls}「{lemma}」：敬語の語形に従う。正解は「{correct}」。"
            tags = ["verb_conjugation", primary, "keigo", CLASS_TAG.get(cls, "irregular")]
            ja_keigo = f"{lemma} → {ja_sfx}（丁寧・謙譲）"
            questions.append(
                {
                    "id": f"vc_{n:03d}",
                    "type": "multipleChoice",
                    "prompt": f"{lemma} → {prompt_sfx}",
                    "japanese": ja_keigo,
                    "choices": [{"id": cids[i], "label": shuffled[i]} for i in range(4)],
                    "correctAnswerId": cids[ci],
                    "explanation": expl,
                    "diagnosticTags": tags,
                    **_mvp_verb(lemma, ja_keigo, tags, n - 1),
                }
            )
            n += 1
            continue

        fdict = FORMS[lemma]
        tag_tuple = TAG_FOR_ADV[fk]
        primary = tag_tuple[0]
        ja_sfx = tag_tuple[1]
        prompt_sfx = tag_tuple[2]
        if fk == "辞書":
            masu_lemma = fdict["ます"]
            ja_line = f"{masu_lemma} → 辞書形（{lemma}）"
            correct = fdict["辞書"]
            dlist = distractors(lemma, fk, correct, fdict)
            labels = [correct, dlist[0], dlist[1], dlist[2]]
            order = [0, 1, 2, 3]
            random.shuffle(order)
            shuffled = [labels[i] for i in order]
            ci = shuffled.index(correct)
            cids = ["a", "b", "c", "d"]
            cls = fdict.get("cls", "")
            expl = f"{cls}「{lemma}」：丁寧の連用形から辞書形に戻す。正解は「{correct}」。"
            tags = [
                "verb_conjugation",
                primary,
                CLASS_TAG.get(cls, "irregular"),
            ]
            questions.append(
                {
                    "id": f"vc_{n:03d}",
                    "type": "multipleChoice",
                    "prompt": f"{masu_lemma} → dictionary form",
                    "japanese": ja_line,
                    "choices": [{"id": cids[i], "label": shuffled[i]} for i in range(4)],
                    "correctAnswerId": cids[ci],
                    "explanation": expl,
                    "diagnosticTags": tags,
                    **_mvp_verb(lemma, ja_line, tags, n - 1),
                }
            )
            n += 1
            continue

        if fk == "禁止":
            ja_sfx = "禁止形（～な）"
            prompt_sfx = "prohibitive (attach な)"

        questions.append(
            make_question(
                f"vc_{n:03d}",
                lemma,
                fk,
                fdict,
                prompt_sfx,
                ja_sfx,
                primary,
                [],
                n - 1,
            )
        )
        n += 1

    assert n == 151, n
    assert len(questions) == 150

    jp_set = [q["japanese"] for q in questions]
    assert len(jp_set) == len(set(jp_set)), "duplicate japanese lines"

    return {
        "id": "verbConjugation",
        "title": "Verb Conjugation",
        "subtitle": "Forms and patterns",
        "description": "変換ドリル：ます・て・た・ない、辞書への復元、可能・受身・使役、意志、ば・たら、命令・禁止、よく使う敬語表現（N4〜N3中心、N2先取り）。",
        "difficulty": "N4-N3",
        "diagnosticTags": [
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
            "keigo",
            "ichidan",
            "godan",
            "irregular",
        ],
        "questions": questions,
    }


if __name__ == "__main__":
    out = (
        Path(__file__).resolve().parent.parent
        / "assets"
        / "quiz_banks"
        / "verb_conjugation.json"
    )
    bank = build()
    out.write_text(
        json.dumps(bank, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {out} ({len(bank['questions'])} questions)")
