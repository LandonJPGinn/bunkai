import assert from "node:assert/strict";
import test from "node:test";

import {
  loadQuizBank,
  loadQuizCatalog,
} from "../../functions/api/_quiz_content.js";

class FakeStatement {
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
    return { results: this.db.queryAll(this.sql, this.bindings) };
  }

  async first() {
    return this.db.queryFirst(this.sql, this.bindings);
  }
}

class FakeDb {
  prepare(sql) {
    return new FakeStatement(this, sql);
  }

  queryAll(sql, bindings) {
    const quizId = bindings[0];
    if (sql.includes("FROM quizzes") && sql.includes("WHERE published = 1")) {
      return [
        {
          id: "particleForensics",
          title: "Particles",
          subtitle: "Semantic case marking",
          description: "Practice particles.",
          difficulty: "N4-N3",
        },
      ];
    }
    if (sql.includes("FROM quiz_tags") && sql.includes("JOIN quizzes")) {
      return [
        { quiz_id: "particleForensics", tag: "particle_choice" },
        { quiz_id: "particleForensics", tag: "wa_ga" },
      ];
    }
    if (sql.includes("FROM questions")) {
      assert.equal(quizId, "particleForensics");
      return [
        {
          quiz_id: quizId,
          id: "pf_001",
          sort_order: 1,
          type: "multipleChoice",
          prompt: "Choose the particle.",
          prompt_en: "Choose the particle.",
          context: null,
          context_en: null,
          japanese: "私＿行きます。",
          japanese_en: "I go.",
          correct_answer_id: "a",
          accepted_answers_json: "[]",
          explanation: "が marks the subject.",
          explanation_en: "Ga marks the subject.",
          jlpt_level: "N4",
          difficulty_score: 1,
          review_status: "draft",
          review_notes: null,
          source: null,
          author: null,
        },
      ];
    }
    if (sql.includes("FROM choices")) {
      return [
        {
          quiz_id: quizId,
          question_id: "pf_001",
          id: "a",
          sort_order: 1,
          label: "が",
          label_en: "ga",
          explanation: null,
          explanation_en: null,
        },
      ];
    }
    if (sql.includes("FROM question_tags")) {
      return [{ question_id: "pf_001", tag: "particle_choice" }];
    }
    if (sql.includes("FROM question_grammar_points")) {
      return [{ question_id: "pf_001", grammar_point: "が" }];
    }
    if (sql.includes("FROM question_vocabulary")) {
      return [{ question_id: "pf_001", vocabulary: "行きます" }];
    }
    if (sql.includes("FROM quiz_tags")) {
      return [{ tag: "particle_choice" }, { tag: "wa_ga" }];
    }
    return [];
  }

  queryFirst(sql, bindings) {
    assert(sql.includes("FROM quizzes"));
    if (bindings[0] !== "particleForensics") return null;
    return {
      id: "particleForensics",
      title: "Particles",
      subtitle: "Semantic case marking",
      description: "Practice particles.",
      difficulty: "N4-N3",
    };
  }
}

test("loadQuizCatalog returns the Flutter catalog shape", async () => {
  const catalog = await loadQuizCatalog(new FakeDb());
  assert.deepEqual(catalog, {
    quizzes: [
      {
        id: "particleForensics",
        title: "Particles",
        subtitle: "Semantic case marking",
        description: "Practice particles.",
        difficulty: "N4-N3",
        diagnosticTags: ["particle_choice", "wa_ga"],
      },
    ],
  });
});

test("loadQuizBank returns the full Flutter quiz shape", async () => {
  const quiz = await loadQuizBank(new FakeDb(), "particleForensics");
  assert.equal(quiz.id, "particleForensics");
  assert.deepEqual(quiz.diagnosticTags, ["particle_choice", "wa_ga"]);
  assert.equal(quiz.questions.length, 1);
  assert.deepEqual(quiz.questions[0].diagnosticTags, ["particle_choice"]);
  assert.deepEqual(quiz.questions[0].grammarPoints, ["が"]);
  assert.deepEqual(quiz.questions[0].vocabulary, ["行きます"]);
  assert.deepEqual(quiz.questions[0].choices, [
    { id: "a", label: "が", labelEn: "ga" },
  ]);
});
