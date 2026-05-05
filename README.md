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

## Quiz content (JSON banks)

Core quizzes load from **`assets/quiz_banks/*.json`** (one file per quiz). At startup, [`QuizBankLoader`](lib/services/quiz_bank_loader.dart) reads and validates each file before the UI runs.

To normalize formatting after editing JSON:

```bash
dart run tool/export_quiz_banks.dart
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
2. Add **`assets/quiz_banks/<snake_case>.json`** with the same shape as an existing bank (root object: `id`, `title`, `subtitle`, `description`, `difficulty`, `diagnosticTags`, `questions`).
3. Register the asset path in [`lib/data/bundled_quiz_bank_paths.dart`](lib/data/bundled_quiz_bank_paths.dart) (`kBundledQuizBankAssetPaths`) and append the quiz to [`coreBunkaiPack()`](lib/data/quiz_registry.dart) (or your pack) in display order.

## Add a question

Edit the quiz’s JSON file under [`assets/quiz_banks/`](assets/quiz_banks) and append a question object. Keep `choices` ids stable; `correctAnswerId` must match one choice `id`. Use `"type": "multipleChoice"` unless you extend the engine. Run `dart run tool/export_quiz_banks.dart` to validate and pretty-print.

## Future roadmap

- Community quiz packs
- Spaced review
- Listening questions
- User-created content
- Import/export quiz packs as JSON
