import assert from "node:assert/strict";
import test from "node:test";

import {
  previewAdminImport,
  quizzesFromCsvTables,
  quizzesToCsvTables,
  saveAdminQuizBank,
  validateAdminQuiz,
} from "../../functions/api/_admin_content.js";
import worker from "../../worker/index.js";

const sampleQuiz = {
  id: "sample",
  title: "Sample",
  subtitle: "Sub",
  description: "Desc",
  difficulty: "N5",
  diagnosticTags: ["draft"],
  questions: [
    {
      id: "q1",
      type: "multipleChoice",
      prompt: "Choose.",
      promptEn: "Choose.",
      japanese: "答[こた]え",
      japaneseEn: "answer",
      correctAnswerId: "a",
      explanation: "理由[りゆう]",
      explanationEn: "Reason.",
      diagnosticTags: ["draft"],
      jlptLevel: "N5",
      difficultyScore: 1,
      grammarPoints: ["grammar"],
      vocabulary: ["vocab"],
      reviewStatus: "draft",
      choices: [
        { id: "a", label: "答[こた]え", labelEn: "answer" },
        { id: "b", label: "違[ちが]う", labelEn: "wrong" },
      ],
    },
    {
      id: "q2",
      type: "textInput",
      prompt: "Type.",
      promptEn: "Type.",
      japanese: "書[か]く",
      japaneseEn: "write",
      correctAnswerId: "",
      acceptedAnswers: ["書[か]く"],
      explanation: "理由[りゆう]",
      explanationEn: "Reason.",
      diagnosticTags: ["draft"],
      jlptLevel: "N5",
      difficultyScore: 1,
      grammarPoints: ["grammar"],
      vocabulary: ["vocab"],
      reviewStatus: "draft",
      choices: [],
    },
  ],
};

class RecordingStatement {
  constructor(db, sql) {
    this.db = db;
    this.sql = sql;
    this.bindings = [];
  }

  bind(...bindings) {
    this.bindings = bindings;
    return this;
  }

  async all() {
    return { results: [] };
  }

  async first() {
    if (this.sql.includes("MAX(display_order)")) {
      return { next_order: 1 };
    }
    return null;
  }

  async run() {
    this.db.runs.push({ sql: this.sql, bindings: this.bindings });
    return { success: true };
  }
}

class RecordingDb {
  constructor() {
    this.runs = [];
  }

  prepare(sql) {
    return new RecordingStatement(this, sql);
  }
}

test("validateAdminQuiz accepts multiple choice and typed answer questions", () => {
  const result = validateAdminQuiz(sampleQuiz);
  assert.equal(result.ok, true);
  assert.equal(result.quiz.questions.length, 2);
});

test("CSV export can be parsed back to quiz payloads", () => {
  const csv = quizzesToCsvTables([sampleQuiz]);
  const parsed = quizzesFromCsvTables(csv);
  assert.equal(parsed.length, 1);
  assert.equal(parsed[0].id, "sample");
  assert.equal(parsed[0].questions.length, 2);
  assert.equal(parsed[0].questions[0].choices[0].id, "a");
});

test("previewAdminImport returns row-level validation errors", async () => {
  const preview = await previewAdminImport({
    quizzes: [{ ...sampleQuiz, title: "", questions: [] }],
  });
  assert.equal(preview.ok, false);
  assert(preview.errors.some((error) => error.includes("title")));
});

test("saveAdminQuizBank writes normalized D1 table rows", async () => {
  const db = new RecordingDb();
  const result = await saveAdminQuizBank(db, sampleQuiz);
  assert.equal(result.ok, true);
  assert(db.runs.some((run) => run.sql.includes("INSERT INTO quizzes")));
  assert(db.runs.some((run) => run.sql.includes("INSERT INTO questions")));
  assert(db.runs.some((run) => run.sql.includes("INSERT INTO choices")));
});

test("Worker admin login sets a protected session cookie", async () => {
  const env = {
    ADMIN_PASSWORD: "secret",
    ADMIN_SESSION_SECRET: "session-secret",
  };

  const denied = await worker.fetch(
    new Request("https://example.test/api/admin/session"),
    env,
  );
  assert.equal(denied.status, 401);

  const login = await worker.fetch(
    new Request("https://example.test/api/admin/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password: "secret" }),
    }),
    env,
  );
  assert.equal(login.status, 200);
  const cookie = login.headers.get("Set-Cookie");
  assert(cookie?.includes("jpquizapp_admin="));

  const allowed = await worker.fetch(
    new Request("https://example.test/api/admin/session", {
      headers: { Cookie: cookie },
    }),
    env,
  );
  assert.equal(allowed.status, 200);
});
