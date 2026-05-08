# CSV content schema (canonical source)

Community contributions should edit CSV files under `data-src/`:

- `data-src/quiz/quizzes.csv` (one row per quiz metadata record)
- `data-src/quiz/questions.csv` (one row per question)
- `data-src/quiz/choices.csv` (one row per choice)
- `data-src/wordbank/wordbank.csv` (one row per dictionary entry)

Use ` | ` separators for list-like fields (for example tags, definitions).

## quizzes.csv

Columns:
- `quiz_id` (enum id like `particleForensics`)
- `title`
- `subtitle`
- `description`
- `difficulty`
- `diagnostic_tags` (`tagA | tagB`)

## questions.csv

Columns:
- `quiz_id`
- `question_id`
- `sort_order` (integer order inside quiz)
- `type` (currently `multipleChoice`)
- `prompt`
- `prompt_en`
- `context` (optional)
- `context_en` (optional; should be set when context is set)
- `japanese`
- `japanese_en`
- `correct_answer_id`
- `explanation`
- `explanation_en`
- `diagnostic_tags` (`tagA | tagB`)
- `jlpt_level` (optional)
- `difficulty_score` (optional integer 1-5)
- `grammar_points` (`itemA | itemB`, optional)
- `vocabulary` (`itemA | itemB`, optional)
- `review_status` (optional)
- `review_notes` (optional)
- `source` (optional)
- `author` (optional)

## choices.csv

Columns:
- `quiz_id`
- `question_id`
- `choice_id`
- `sort_order` (integer order inside question)
- `label`
- `label_en`
- `explanation` (optional)
- `explanation_en` (optional)

## wordbank.csv

Columns:
- `surface`
- `reading`
- `part_of_speech`
- `definitions` (`def1 | def2`)
- `jlpt_level` (optional)
- `tags` (`tagA | tagB`, optional)

## Commands

- `make content-export-csv`: regenerate CSV from existing JSON assets.
- `make content-generate`: generate JSON assets from canonical CSV.
- `make content-compile`: compile Arrow artifacts under `assets/compiled/`.
- `make content-build`: run generate, validate, and compile together.
