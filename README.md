# BunKai

BunKai is a **login-free, backend-free** Flutter Web app: short Japanese grammar quizzes that target mistakes ordinary apps skip. Everything runs locally in the browser.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

Production build for the web:

```bash
flutter build web
```

Serve the output under `build/web` with any static file host.

## Japanese dictionary lookup (offline)

Tap-to-define uses a bundled lexicon at **`assets/dictionary/japanese_lexicon.json`**. At startup, [`JapaneseDictionaryService`](lib/services/japanese_dictionary_service.dart) loads this array into memory and builds a longest-match tokenizer ([`JapaneseTokenizer`](lib/services/japanese_tokenizer.dart)). Quiz strings do **not** need manual word tagging; rendering goes through [`JapaneseTextLookup`](lib/widgets/japanese_text_lookup.dart), which keeps furigana markup (`kanji[よみ]`) and splits clickable spans from plain Japanese.

### Entry shape

Each object may repeat the same `surface` for homonyms:

```json
{
  "surface": "食べる",
  "reading": "たべる",
  "partOfSpeech": "verb",
  "definitions": ["to eat"],
  "jlptLevel": "N5",
  "tags": ["ichidan", "common"]
}
```

Optional fields: `jlptLevel`, `tags`. After editing the JSON, run the app (or `flutter test`) so changes are picked up.

To regenerate or extend the starter list, run **`python tool/gen_lexicon.py`** from the repo root (writes `assets/dictionary/japanese_lexicon.json`).

### Longest-match limitations

Segmentation is greedy dictionary lookup, not linguistic analysis. Unknown compounds may split incorrectly; conjugations only match if the exact surface appears in the lexicon; homophones may map to the wrong sense in context. Kana strings are usually left as plain (non-clickable) unless listed as their own surface.

### Upgrading the tokenizer later

You can keep [`JapaneseTextLookup`](lib/widgets/japanese_text_lookup.dart) and swap only [`JapaneseTokenizer`](lib/services/japanese_tokenizer.dart) (or enrich [`JapaneseDictionaryService`](lib/services/japanese_dictionary_service.dart) with a remote API) when you add Kuromoji/Sudachi/MeCab-class output or a server dictionary—quiz widgets and JSON banks stay unchanged.

## Community content pipeline (CSV-first)

Contributors should edit canonical CSV tables:

- `data-src/quiz/quizzes.csv`
- `data-src/quiz/questions.csv`
- `data-src/quiz/choices.csv`
- `data-src/wordbank/wordbank.csv`

Then run:

```bash
make content-build
```

This pipeline:
- generates runtime JSON assets from CSV,
- validates quiz + dictionary contracts,
- compiles Arrow Feather artifacts under `assets/compiled/`.

For schema details, see [`docs/csv_content_schema.md`](docs/csv_content_schema.md).

## Quiz content (generated JSON banks)

Core quizzes load from **`assets/compiled/quiz_banks/*.json`** first (generated compact form), with fallback to **`assets/quiz_banks/*.json`**. At startup, [`QuizBankLoader`](lib/services/quiz_bank_loader.dart) reads and validates each file before the UI runs.

To regenerate JSON from canonical CSV sources:

```bash
make content-generate
```

## Validate / inspect quiz banks (dev tools)

These scripts run in pure Dart and do not require the Flutter runtime.

Validate every JSON file in `assets/quiz_banks/` against the same rules the app uses at load time. Reports all errors in a single pass and exits non-zero if any file fails:

```bash
dart run scripts/validate_quiz_banks.dart
```

Print a per-bank summary (quiz id, title, question count, diagnostic tag counts, question type counts, first / last question id):

```bash
dart run scripts/quiz_bank_summary.dart
```

## Add a quiz

1. Add an enum value to [`lib/models/quiz_id.dart`](lib/models/quiz_id.dart). The enum name (camelCase) is the route argument passed when starting a quiz.
2. Add quiz/question/choice rows in the canonical CSV files under `data-src/quiz/`.
3. Register the asset path in [`lib/data/bundled_quiz_bank_paths.dart`](lib/data/bundled_quiz_bank_paths.dart) (`kBundledQuizBankAssetPaths`) and append the quiz to [`coreBunkaiPack()`](lib/data/quiz_registry.dart) (or your pack) in display order.
4. Run `make content-build`.

## Add a question

Edit `data-src/quiz/questions.csv` and `data-src/quiz/choices.csv`. Keep `correct_answer_id` matched to a `choice_id`. Use `type=multipleChoice` unless you extend the engine. Run `make content-build` to regenerate, validate, and compile artifacts.

## Future roadmap

- Community quiz packs
- Spaced review
- Listening questions
- User-created content
- Import/export quiz packs as JSON
