# Quiz bank JSON schema guide

This document describes the generated bundled quiz bank JSON shape for jpquizapp. Each file under `assets/quiz_banks/` is **one** quiz: a single JSON object that the app parses as [`Quiz`](../lib/models/quiz.dart). Questions use [`QuizQuestion`](../lib/models/quiz_question.dart) and answer rows use [`AnswerChoice`](../lib/models/answer_choice.dart).

Canonical contributor inputs are CSV files under `data-src/` (see [`csv_content_schema.md`](csv_content_schema.md)). JSON files documented here are generated runtime assets.

A formal machine-readable definition lives alongside this guide: [quiz_bank.schema.json](quiz_bank.schema.json) (JSON Schema 2020-12).

## File names and quiz `id`

The loader maps each asset path to a fixed [`QuizId`](../lib/models/quiz_id.dart). The JSON field `"id"` **must** exactly match the enum name for that file, or loading fails with a mismatch error.

| Asset file | Required `"id"` value |
|------------|------------------------|
| `assets/quiz_banks/particle_forensics.json` | `particleForensics` |
| `assets/quiz_banks/clause_untangler.json` | `clauseUntangler` |
| `assets/quiz_banks/omission_detective.json` | `omissionDetective` |
| `assets/quiz_banks/register_radar.json` | `registerRadar` |
| `assets/quiz_banks/transitivity_duel.json` | `transitivityDuel` |
| `assets/quiz_banks/verb_conjugation.json` | `verbConjugation` |

## Root object (quiz metadata)

| Field | Required | Type | Notes |
|-------|----------|------|--------|
| `id` | yes | string | One of the six allowed quiz ids (see below). |
| `title` | yes | string | Display title. |
| `subtitle` | yes | string | Short tagline. |
| `description` | yes | string | Longer description for the quiz card or intro. |
| `difficulty` | yes | string | One of the [JLPT difficulty labels](#jlpt-difficulty-labels). |
| `diagnosticTags` | no | array of strings | Tags for the quiz as a whole; omit or use `[]` if unused. |
| `questions` | yes | array | At least one question; each entry follows the [question](#question-object) shape. |

### Cross-field rules (not fully expressed in JSON Schema)

After parsing, `validateQuizBankContent` in [`lib/services/quiz_bank_validation.dart`](../lib/services/quiz_bank_validation.dart) also enforces:

- Every `questions[].id` is **unique** within the file.
- `questions[].prompt`, `japanese`, `explanation`, `promptEn`, `japaneseEn`, and `explanationEn` are non-empty after trimming.
- When `questions[].context` is non-empty, `questions[].contextEn` is required (and must be non-empty); when context is absent or empty, `contextEn` must be absent or empty.
- Every `questions[].choices[]` row has non-empty `labelEn`. If `explanation` is set on a choice, `explanationEn` must be non-empty too; otherwise `explanationEn` must be absent.
- `questions[].diagnosticTags` is non-empty.
- `questions[].choices` has **at least two** entries.
- `questions[].correctAnswerId` equals one of `questions[].choices[].id`.
- When present, `questions[].jlptLevel` is one of the [JLPT difficulty labels](#jlpt-difficulty-labels) (same strings as quiz `difficulty`).
- When present, `questions[].difficultyScore` is an integer from 1 to 5.
- When present, each entry in `questions[].grammarPoints` and `questions[].vocabulary` is non-empty after trimming.

The schema file additionally requires at least one question and at least two choices per question so editors catch empty banks early.

## Allowed quiz `id` values

Only these strings are valid (they match `QuizId.name` in code):

- `particleForensics`
- `clauseUntangler`
- `omissionDetective`
- `registerRadar`
- `transitivityDuel`
- `verbConjugation`

## Question object

| Field | Required | Type | Notes |
|-------|----------|------|--------|
| `id` | yes | string | Stable unique id within the bank (see [prefixes](#recommended-question-id-prefixes)). |
| `type` | yes | string | One of the [question types](#allowed-question-types). |
| `prompt` | yes | string | Instructions shown above the item (e.g. choose the particle). |
| `promptEn` | yes | string | English exam-style instructions (paired with `prompt`). |
| `context` | no | string or `null` | Extra scenario, gloss, or English hint. Use `null` or omit when unused. |
| `contextEn` | no | string | English counterpart to `context`; **required** (non-empty) when `context` is non-empty. |
| `japanese` | yes | string | Main Japanese line; blanks may use `___` as in the app today. |
| `japaneseEn` | yes | string | English gloss or glossed line paired with `japanese`. |
| `choices` | yes | array | At least two [choice](#choice-object) objects. |
| `correctAnswerId` | yes | string | Must match exactly one `choices[].id`. |
| `explanation` | yes | string | Shown after answering; should teach *why*, not only *that* (see [quality rules](#content-quality-rules)). |
| `explanationEn` | yes | string | Brief English rationale paired with `explanation`. |
| `diagnosticTags` | yes | array of strings | At least one tag for analytics and recommendations. |
| `jlptLevel` | no | string | Per-question JLPT band; same allowed values as [JLPT difficulty labels](#jlpt-difficulty-labels). |
| `difficultyScore` | no | integer | Difficulty from 1 (easier) to 5 (harder). |
| `grammarPoints` | no | array of strings | Optional grammar focus lines (non-empty strings). |
| `vocabulary` | no | array of strings | Optional vocabulary items for this question (non-empty strings). |

## Choice object

| Field | Required | Type | Notes |
|-------|----------|------|--------|
| `id` | yes | string | Stable within the question (often `a`, `b`, `c`, `d`). |
| `label` | yes | string | Surface text of the option (e.g. particle or verb form). |
| `labelEn` | yes | string | English gloss for the label (e.g. `を (direct object marker)`). |
| `explanation` | no | string | Short rationale for this distractor or option when helpful. |
| `explanationEn` | no | string | English rationale; **required** when `explanation` is set. |

## Allowed question types

Values must match [`QuizType`](../lib/models/quiz_type.dart) enum names:

| `type` | Purpose |
|--------|--------|
| `multipleChoice` | Pick one option from `choices`. **All bundled banks use this today.** |
| `reorder` | Reserved for future ordered-list items. |
| `textInput` | Reserved for typed answers. |
| `classification` | Reserved for category-style items. |

New content should use `multipleChoice` unless the app UI and engine explicitly support another type.

## Recommended question id prefixes

These prefixes help grep, reviews, and debugging. They are **not** enforced by the loader.

| Prefix | Quiz | Example |
|--------|------|--------|
| `pf_` | Particle Forensics | `pf_001` |
| `cu_` | Clause Untangler | `cu_001` |
| `od_` | Omission Detective | `od_001` |
| `rr_` | Register Radar | `rr_001` |
| `td_` | Transitivity Duel | `td_001` |
| `vc_` | Verb Conjugation | `vc_001` |

Older banks may still use patterns like `particleForensics_q1`; prefer the prefixes for new questions.

## JLPT difficulty labels

Use exactly one of these strings for `difficulty`:

- `N4`
- `N4-N3`
- `N3`
- `N3-N2`
- `N2`

**Legacy note:** Some existing JSON files may still use non-canonical strings (for example `N4+`). Those load because `difficulty` is a free-form string in code. New or heavily revised banks should use the list above so content stays comparable and the [schema](quiz_bank.schema.json) validates. Migrating old files is optional but recommended.

## Content quality rules

- **No romaji** in Japanese prompts, choices, or primary explanations.
- **Vocabulary:** Prefer common words at the stated JLPT band; avoid rare or highly specialized terms unless the quiz explicitly targets them.
- **Explanations:** Write for learning—grammar, usage, or register reasons—not only “this is correct” or a restatement of the answer.
- **Register Radar:** When politeness, relationship, or setting matters, phrase the prompt so the learner is choosing the **best fit** (and use wording like “best fit” where it helps).
- **Ambiguity:** Do not ship items where two or more answers are equally defensible unless `prompt` or `context` clearly narrows the intended reading.

## Validation workflow

From the repository root:

```bash
make content-build
```

This generates JSON from CSV, validates with `validateQuizBankContent`, and compiles artifacts. Fix any `QuizBankFormatException` or parse error before committing.

You can also validate a single file against [quiz_bank.schema.json](quiz_bank.schema.json) using any JSON Schema tool (for example VS Code extensions or `ajv`), keeping in mind that **legacy `difficulty` strings** may fail schema until assets are normalized.

## Example

```json
{
  "id": "particleForensics",
  "title": "Particle Forensics",
  "subtitle": "Debug subtle particle choices.",
  "description": "Train semantic particle choice through short targeted prompts.",
  "difficulty": "N4-N3",
  "diagnosticTags": ["particle_choice", "wa_ga", "ni_de"],
  "questions": [
    {
      "id": "pf_001",
      "type": "multipleChoice",
      "jlptLevel": "N4",
      "difficultyScore": 2,
      "grammarPoints": [
        "で as action location",
        "に as target/location contrast"
      ],
      "vocabulary": ["駅", "友だち", "会う"],
      "prompt": "Choose the particle that best fits the sentence.",
      "context": null,
      "japanese": "駅___友だちに会いました。",
      "choices": [
        {
          "id": "a",
          "label": "で",
          "explanation": "Marks the place where the action happened."
        },
        {
          "id": "b",
          "label": "に",
          "explanation": "Usually marks destination, existence location, or indirect target."
        }
      ],
      "correctAnswerId": "a",
      "explanation": "で marks the location where 会いました happened.",
      "diagnosticTags": ["particle_choice", "ni_de"]
    }
  ]
}
```
