PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS quizzes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  description TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  display_order INTEGER NOT NULL,
  published INTEGER NOT NULL DEFAULT 1 CHECK (published IN (0, 1))
);

CREATE TABLE IF NOT EXISTS quiz_tags (
  quiz_id TEXT NOT NULL,
  tag TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  PRIMARY KEY (quiz_id, tag),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS questions (
  quiz_id TEXT NOT NULL,
  id TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  type TEXT NOT NULL DEFAULT 'multipleChoice',
  prompt TEXT NOT NULL,
  prompt_en TEXT NOT NULL,
  context TEXT,
  context_en TEXT,
  japanese TEXT NOT NULL,
  japanese_en TEXT NOT NULL,
  correct_answer_id TEXT NOT NULL DEFAULT '',
  accepted_answers_json TEXT NOT NULL DEFAULT '[]',
  explanation TEXT NOT NULL,
  explanation_en TEXT NOT NULL,
  jlpt_level TEXT,
  difficulty_score INTEGER,
  review_status TEXT,
  review_notes TEXT,
  source TEXT,
  author TEXT,
  PRIMARY KEY (quiz_id, id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS choices (
  quiz_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  id TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  label TEXT NOT NULL,
  label_en TEXT,
  explanation TEXT,
  explanation_en TEXT,
  PRIMARY KEY (quiz_id, question_id, id),
  FOREIGN KEY (quiz_id, question_id) REFERENCES questions(quiz_id, id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS question_tags (
  quiz_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  tag TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  PRIMARY KEY (quiz_id, question_id, tag),
  FOREIGN KEY (quiz_id, question_id) REFERENCES questions(quiz_id, id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS question_grammar_points (
  quiz_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  grammar_point TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  PRIMARY KEY (quiz_id, question_id, grammar_point),
  FOREIGN KEY (quiz_id, question_id) REFERENCES questions(quiz_id, id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS question_vocabulary (
  quiz_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  vocabulary TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  PRIMARY KEY (quiz_id, question_id, vocabulary),
  FOREIGN KEY (quiz_id, question_id) REFERENCES questions(quiz_id, id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_quizzes_published_order
  ON quizzes(published, display_order, id);

CREATE INDEX IF NOT EXISTS idx_questions_quiz_order
  ON questions(quiz_id, sort_order, id);

CREATE INDEX IF NOT EXISTS idx_choices_question_order
  ON choices(quiz_id, question_id, sort_order, id);
