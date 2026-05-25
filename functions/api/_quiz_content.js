const jsonHeaders = {
  "Content-Type": "application/json; charset=utf-8",
  "Cache-Control": "public, max-age=60, s-maxage=300",
};

export function jsonResponse(body, init = {}) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      ...jsonHeaders,
      ...(init.headers ?? {}),
    },
  });
}

export function errorResponse(status, message) {
  return jsonResponse({ error: message }, { status });
}

export function databaseFromContext(context) {
  const db = context.env.DB;
  if (!db) {
    throw new Error("D1 binding DB is not configured.");
  }
  return db;
}

async function all(db, sql, ...bindings) {
  const statement = db.prepare(sql);
  const result = bindings.length > 0
    ? await statement.bind(...bindings).all()
    : await statement.all();
  return result.results ?? [];
}

async function first(db, sql, ...bindings) {
  const statement = db.prepare(sql);
  return bindings.length > 0
    ? statement.bind(...bindings).first()
    : statement.first();
}

function pushGrouped(map, key, value) {
  if (!map.has(key)) map.set(key, []);
  map.get(key).push(value);
}

function parseStringArray(value) {
  if (!value) return [];
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed)
      ? parsed.filter((item) => typeof item === "string")
      : [];
  } catch {
    return [];
  }
}

function optionalString(target, key, value) {
  if (typeof value === "string" && value.length > 0) {
    target[key] = value;
  }
}

export async function loadQuizCatalog(db) {
  const quizzes = await all(
    db,
    `
      SELECT id, title, subtitle, description, difficulty
      FROM quizzes
      WHERE published = 1
      ORDER BY display_order ASC, id ASC
    `,
  );
  const tagRows = await all(
    db,
    `
      SELECT qt.quiz_id, qt.tag
      FROM quiz_tags qt
      JOIN quizzes q ON q.id = qt.quiz_id
      WHERE q.published = 1
      ORDER BY q.display_order ASC, qt.sort_order ASC, qt.tag ASC
    `,
  );
  const tagsByQuiz = new Map();
  for (const row of tagRows) {
    pushGrouped(tagsByQuiz, row.quiz_id, row.tag);
  }
  return {
    quizzes: quizzes.map((quiz) => ({
      id: quiz.id,
      title: quiz.title,
      subtitle: quiz.subtitle,
      description: quiz.description,
      difficulty: quiz.difficulty,
      diagnosticTags: tagsByQuiz.get(quiz.id) ?? [],
    })),
  };
}

export async function loadQuizBank(db, quizId) {
  const quiz = await first(
    db,
    `
      SELECT id, title, subtitle, description, difficulty
      FROM quizzes
      WHERE id = ?1 AND published = 1
    `,
    quizId,
  );
  if (!quiz) return null;

  const [questions, choices, tagRows, grammarRows, vocabularyRows, quizTagRows] =
    await Promise.all([
      all(
        db,
        `
          SELECT *
          FROM questions
          WHERE quiz_id = ?1
          ORDER BY sort_order ASC, id ASC
        `,
        quizId,
      ),
      all(
        db,
        `
          SELECT *
          FROM choices
          WHERE quiz_id = ?1
          ORDER BY question_id ASC, sort_order ASC, id ASC
        `,
        quizId,
      ),
      all(
        db,
        `
          SELECT question_id, tag
          FROM question_tags
          WHERE quiz_id = ?1
          ORDER BY question_id ASC, sort_order ASC, tag ASC
        `,
        quizId,
      ),
      all(
        db,
        `
          SELECT question_id, grammar_point
          FROM question_grammar_points
          WHERE quiz_id = ?1
          ORDER BY question_id ASC, sort_order ASC, grammar_point ASC
        `,
        quizId,
      ),
      all(
        db,
        `
          SELECT question_id, vocabulary
          FROM question_vocabulary
          WHERE quiz_id = ?1
          ORDER BY question_id ASC, sort_order ASC, vocabulary ASC
        `,
        quizId,
      ),
      all(
        db,
        `
          SELECT tag
          FROM quiz_tags
          WHERE quiz_id = ?1
          ORDER BY sort_order ASC, tag ASC
        `,
        quizId,
      ),
    ]);

  const choicesByQuestion = new Map();
  for (const row of choices) {
    const choice = {
      id: row.id,
      label: row.label,
    };
    optionalString(choice, "labelEn", row.label_en);
    optionalString(choice, "explanation", row.explanation);
    optionalString(choice, "explanationEn", row.explanation_en);
    pushGrouped(choicesByQuestion, row.question_id, choice);
  }

  const tagsByQuestion = new Map();
  for (const row of tagRows) {
    pushGrouped(tagsByQuestion, row.question_id, row.tag);
  }

  const grammarByQuestion = new Map();
  for (const row of grammarRows) {
    pushGrouped(grammarByQuestion, row.question_id, row.grammar_point);
  }

  const vocabularyByQuestion = new Map();
  for (const row of vocabularyRows) {
    pushGrouped(vocabularyByQuestion, row.question_id, row.vocabulary);
  }

  return {
    id: quiz.id,
    title: quiz.title,
    subtitle: quiz.subtitle,
    description: quiz.description,
    difficulty: quiz.difficulty,
    diagnosticTags: quizTagRows.map((row) => row.tag),
    questions: questions.map((row) => {
      const question = {
        id: row.id,
        type: row.type,
        prompt: row.prompt,
        promptEn: row.prompt_en,
        japanese: row.japanese,
        japaneseEn: row.japanese_en,
        correctAnswerId: row.correct_answer_id,
        explanation: row.explanation,
        explanationEn: row.explanation_en,
        diagnosticTags: tagsByQuestion.get(row.id) ?? [],
        choices: choicesByQuestion.get(row.id) ?? [],
      };
      optionalString(question, "context", row.context);
      optionalString(question, "contextEn", row.context_en);
      const acceptedAnswers = parseStringArray(row.accepted_answers_json);
      if (acceptedAnswers.length > 0) question.acceptedAnswers = acceptedAnswers;
      optionalString(question, "jlptLevel", row.jlpt_level);
      if (row.difficulty_score != null) {
        question.difficultyScore = row.difficulty_score;
      }
      const grammarPoints = grammarByQuestion.get(row.id) ?? [];
      if (grammarPoints.length > 0) question.grammarPoints = grammarPoints;
      const vocabulary = vocabularyByQuestion.get(row.id) ?? [];
      if (vocabulary.length > 0) question.vocabulary = vocabulary;
      optionalString(question, "reviewStatus", row.review_status);
      optionalString(question, "reviewNotes", row.review_notes);
      optionalString(question, "source", row.source);
      optionalString(question, "author", row.author);
      return question;
    }),
  };
}
