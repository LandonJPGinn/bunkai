CREATE TABLE IF NOT EXISTS admin_content_revisions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quiz_id TEXT NOT NULL,
  actor TEXT NOT NULL,
  change_summary TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_admin_content_revisions_quiz_created
  ON admin_content_revisions(quiz_id, created_at DESC);
