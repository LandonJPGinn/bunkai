const adminCookieName = "jpquizapp_admin";
const sessionMaxAgeSeconds = 60 * 60 * 8;

const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

function jsonCachelessHeaders(extra = {}) {
  return {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    ...extra,
  };
}

export function adminJsonResponse(body, init = {}) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: jsonCachelessHeaders(init.headers ?? {}),
  });
}

export function adminErrorResponse(status, message, details = undefined) {
  return adminJsonResponse(
    details === undefined ? { error: message } : { error: message, details },
    { status },
  );
}

function assertAdminSecrets(env) {
  if (!env.ADMIN_PASSWORD || !env.ADMIN_SESSION_SECRET) {
    throw new Error("Admin secrets are not configured.");
  }
}

function timingSafeStringEqual(left, right) {
  const leftBytes = textEncoder.encode(left);
  const rightBytes = textEncoder.encode(right);
  const length = Math.max(leftBytes.length, rightBytes.length);
  const paddedLeft = new Uint8Array(length);
  const paddedRight = new Uint8Array(length);
  paddedLeft.set(leftBytes);
  paddedRight.set(rightBytes);

  let diff = leftBytes.length ^ rightBytes.length;
  for (let i = 0; i < length; i += 1) {
    diff |= paddedLeft[i] ^ paddedRight[i];
  }
  return diff === 0;
}

function bytesToBase64Url(bytes) {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function base64UrlToBytes(value) {
  const padded = value.replaceAll("-", "+").replaceAll("_", "/").padEnd(
    Math.ceil(value.length / 4) * 4,
    "=",
  );
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function base64UrlEncodeString(value) {
  return bytesToBase64Url(textEncoder.encode(value));
}

function base64UrlDecodeString(value) {
  return textDecoder.decode(base64UrlToBytes(value));
}

async function hmacSignature(secret, value) {
  const key = await crypto.subtle.importKey(
    "raw",
    textEncoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", key, textEncoder.encode(value));
  return bytesToBase64Url(new Uint8Array(signature));
}

async function signSession(env) {
  assertAdminSecrets(env);
  const now = Math.floor(Date.now() / 1000);
  const payload = base64UrlEncodeString(JSON.stringify({
    iat: now,
    exp: now + sessionMaxAgeSeconds,
  }));
  const signature = await hmacSignature(env.ADMIN_SESSION_SECRET, payload);
  return `${payload}.${signature}`;
}

async function verifySession(env, token) {
  assertAdminSecrets(env);
  if (typeof token !== "string" || token.length === 0) return false;
  const parts = token.split(".");
  if (parts.length !== 2) return false;

  const [payload, signature] = parts;
  const expected = await hmacSignature(env.ADMIN_SESSION_SECRET, payload);
  if (!timingSafeStringEqual(signature, expected)) return false;

  try {
    const decoded = JSON.parse(base64UrlDecodeString(payload));
    const exp = Number(decoded.exp);
    return Number.isFinite(exp) && exp > Math.floor(Date.now() / 1000);
  } catch {
    return false;
  }
}

function parseCookies(request) {
  const cookieHeader = request.headers.get("Cookie") ?? "";
  const cookies = new Map();
  for (const part of cookieHeader.split(";")) {
    const [rawName, ...rawValue] = part.trim().split("=");
    if (!rawName) continue;
    cookies.set(rawName, rawValue.join("="));
  }
  return cookies;
}

function sessionCookie(value, maxAge = sessionMaxAgeSeconds) {
  return [
    `${adminCookieName}=${value}`,
    "Path=/",
    "HttpOnly",
    "Secure",
    "SameSite=Strict",
    `Max-Age=${maxAge}`,
  ].join("; ");
}

export async function loginAdmin(request, env) {
  assertAdminSecrets(env);
  let body;
  try {
    body = await request.json();
  } catch {
    return adminErrorResponse(400, "Expected a JSON request body.");
  }

  const password = typeof body.password === "string" ? body.password : "";
  if (!timingSafeStringEqual(password, env.ADMIN_PASSWORD)) {
    return adminErrorResponse(401, "Invalid admin password.");
  }

  return adminJsonResponse(
    { authenticated: true },
    { headers: { "Set-Cookie": sessionCookie(await signSession(env)) } },
  );
}

export function logoutAdmin() {
  return adminJsonResponse(
    { authenticated: false },
    { headers: { "Set-Cookie": sessionCookie("", 0) } },
  );
}

export async function requireAdmin(request, env) {
  const token = parseCookies(request).get(adminCookieName);
  if (await verifySession(env, token)) return null;
  return adminErrorResponse(401, "Admin authentication required.");
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

async function run(db, sql, ...bindings) {
  const statement = db.prepare(sql);
  return bindings.length > 0
    ? statement.bind(...bindings).run()
    : statement.run();
}

function pushGrouped(map, key, value) {
  if (!map.has(key)) map.set(key, []);
  map.get(key).push(value);
}

function optionalString(target, key, value) {
  if (typeof value === "string" && value.length > 0) {
    target[key] = value;
  }
}

function splitPipe(value) {
  if (typeof value !== "string" || value.trim().length === 0) return [];
  return value.split("|").map((part) => part.trim()).filter(Boolean);
}

function joinPipe(values) {
  return Array.isArray(values)
    ? values.map((value) => String(value).trim()).filter(Boolean).join(" | ")
    : "";
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

function normalizeStringArray(value, field, errors) {
  if (value == null) return [];
  if (!Array.isArray(value)) {
    errors.push(`${field} must be an array.`);
    return [];
  }
  const out = [];
  for (const item of value) {
    if (typeof item !== "string") {
      errors.push(`${field} entries must be strings.`);
      continue;
    }
    const trimmed = item.trim();
    if (trimmed.length > 0) out.push(trimmed);
  }
  return out;
}

function normalizeChoice(raw, index, errors) {
  const choice = raw && typeof raw === "object" ? raw : {};
  const id = typeof choice.id === "string" ? choice.id.trim() : "";
  const label = typeof choice.label === "string" ? choice.label.trim() : "";
  if (id.length === 0) errors.push(`choices[${index}].id is required.`);
  if (label.length === 0) errors.push(`choices[${index}].label is required.`);
  const normalized = { id, label };
  optionalString(normalized, "labelEn", choice.labelEn);
  optionalString(normalized, "explanation", choice.explanation);
  optionalString(normalized, "explanationEn", choice.explanationEn);
  return normalized;
}

function canonicalAnswers(question) {
  const explicit = normalizeStringArray(question.acceptedAnswers, "acceptedAnswers", []);
  if (explicit.length > 0) return explicit;
  if (question.correctAnswerId && Array.isArray(question.choices)) {
    const choice = question.choices.find((item) => item.id === question.correctAnswerId);
    if (choice?.label) return [choice.label];
  }
  return [];
}

export function validateAdminQuiz(rawQuiz) {
  const errors = [];
  const quiz = rawQuiz && typeof rawQuiz === "object" ? rawQuiz : {};
  const id = typeof quiz.id === "string" ? quiz.id.trim() : "";
  const title = typeof quiz.title === "string" ? quiz.title.trim() : "";
  const subtitle = typeof quiz.subtitle === "string" ? quiz.subtitle.trim() : "";
  const description = typeof quiz.description === "string" ? quiz.description.trim() : "";
  const difficulty = typeof quiz.difficulty === "string" ? quiz.difficulty.trim() : "";

  if (id.length === 0) errors.push("id is required.");
  if (title.length === 0) errors.push(`Quiz "${id || "?"}": title is required.`);
  if (subtitle.length === 0) errors.push(`Quiz "${id || "?"}": subtitle is required.`);
  if (description.length === 0) errors.push(`Quiz "${id || "?"}": description is required.`);
  if (difficulty.length === 0) errors.push(`Quiz "${id || "?"}": difficulty is required.`);

  const questionsRaw = Array.isArray(quiz.questions) ? quiz.questions : [];
  if (!Array.isArray(quiz.questions)) {
    errors.push(`Quiz "${id || "?"}": questions must be an array.`);
  }

  const seenQuestions = new Set();
  const questions = questionsRaw.map((rawQuestion, questionIndex) => {
    const question = rawQuestion && typeof rawQuestion === "object" ? rawQuestion : {};
    const qid = typeof question.id === "string" ? question.id.trim() : "";
    const type = typeof question.type === "string" && question.type.trim().length > 0
      ? question.type.trim()
      : "multipleChoice";
    const fieldPrefix = `Quiz "${id || "?"}" question "${qid || questionIndex + 1}"`;

    if (qid.length === 0) errors.push(`${fieldPrefix}: id is required.`);
    if (seenQuestions.has(qid)) errors.push(`${fieldPrefix}: duplicate question id.`);
    seenQuestions.add(qid);

    const choicesRaw = Array.isArray(question.choices) ? question.choices : [];
    const choices = choicesRaw.map((choice, index) => normalizeChoice(choice, index, errors));
    const choiceIds = new Set(choices.map((choice) => choice.id));
    const correctAnswerId = typeof question.correctAnswerId === "string"
      ? question.correctAnswerId.trim()
      : "";
    const acceptedAnswers = normalizeStringArray(
      question.acceptedAnswers,
      `${fieldPrefix}: acceptedAnswers`,
      errors,
    );

    if (type === "multipleChoice") {
      if (choices.length === 0) errors.push(`${fieldPrefix}: multipleChoice requires choices.`);
      if (correctAnswerId.length === 0) {
        errors.push(`${fieldPrefix}: multipleChoice requires correctAnswerId.`);
      } else if (!choiceIds.has(correctAnswerId)) {
        errors.push(`${fieldPrefix}: correctAnswerId must match a choice id.`);
      }
    } else if (type === "textInput") {
      if (acceptedAnswers.length === 0 && canonicalAnswers({ ...question, choices, correctAnswerId }).length === 0) {
        errors.push(`${fieldPrefix}: textInput requires acceptedAnswers or a correct choice fallback.`);
      }
    } else {
      errors.push(`${fieldPrefix}: unsupported type "${type}" for admin editing.`);
    }

    for (const requiredField of ["prompt", "promptEn", "japanese", "japaneseEn", "explanation", "explanationEn"]) {
      if (typeof question[requiredField] !== "string" || question[requiredField].trim().length === 0) {
        errors.push(`${fieldPrefix}: ${requiredField} is required.`);
      }
    }

    const normalized = {
      id: qid,
      type,
      prompt: question.prompt ?? "",
      promptEn: question.promptEn ?? "",
      japanese: question.japanese ?? "",
      japaneseEn: question.japaneseEn ?? "",
      correctAnswerId,
      explanation: question.explanation ?? "",
      explanationEn: question.explanationEn ?? "",
      diagnosticTags: normalizeStringArray(question.diagnosticTags, `${fieldPrefix}: diagnosticTags`, errors),
      choices,
    };
    optionalString(normalized, "context", question.context);
    optionalString(normalized, "contextEn", question.contextEn);
    if (acceptedAnswers.length > 0) normalized.acceptedAnswers = acceptedAnswers;
    optionalString(normalized, "jlptLevel", question.jlptLevel);
    if (Number.isInteger(question.difficultyScore)) normalized.difficultyScore = question.difficultyScore;
    const grammarPoints = normalizeStringArray(question.grammarPoints, `${fieldPrefix}: grammarPoints`, errors);
    if (grammarPoints.length > 0) normalized.grammarPoints = grammarPoints;
    const vocabulary = normalizeStringArray(question.vocabulary, `${fieldPrefix}: vocabulary`, errors);
    if (vocabulary.length > 0) normalized.vocabulary = vocabulary;
    optionalString(normalized, "reviewStatus", question.reviewStatus);
    optionalString(normalized, "reviewNotes", question.reviewNotes);
    optionalString(normalized, "source", question.source);
    optionalString(normalized, "author", question.author);
    return normalized;
  });

  const diagnosticTags = normalizeStringArray(quiz.diagnosticTags, "diagnosticTags", errors);

  return {
    ok: errors.length === 0,
    errors,
    quiz: {
      id,
      title,
      subtitle,
      description,
      difficulty,
      diagnosticTags,
      questions,
    },
  };
}

export async function loadAdminQuizCatalog(db) {
  const quizzes = await all(
    db,
    `
      SELECT id, title, subtitle, description, difficulty, published
      FROM quizzes
      ORDER BY display_order ASC, id ASC
    `,
  );
  const tagRows = await all(
    db,
    `
      SELECT quiz_id, tag
      FROM quiz_tags
      ORDER BY quiz_id ASC, sort_order ASC, tag ASC
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
      published: quiz.published !== 0,
      diagnosticTags: tagsByQuiz.get(quiz.id) ?? [],
    })),
  };
}

export async function loadAdminQuizBank(db, quizId) {
  const quiz = await first(
    db,
    `
      SELECT id, title, subtitle, description, difficulty, published
      FROM quizzes
      WHERE id = ?1
    `,
    quizId,
  );
  if (!quiz) return null;

  const [questions, choices, tagRows, grammarRows, vocabularyRows, quizTagRows] =
    await Promise.all([
      all(db, "SELECT * FROM questions WHERE quiz_id = ?1 ORDER BY sort_order ASC, id ASC", quizId),
      all(db, "SELECT * FROM choices WHERE quiz_id = ?1 ORDER BY question_id ASC, sort_order ASC, id ASC", quizId),
      all(db, "SELECT question_id, tag FROM question_tags WHERE quiz_id = ?1 ORDER BY question_id ASC, sort_order ASC, tag ASC", quizId),
      all(db, "SELECT question_id, grammar_point FROM question_grammar_points WHERE quiz_id = ?1 ORDER BY question_id ASC, sort_order ASC, grammar_point ASC", quizId),
      all(db, "SELECT question_id, vocabulary FROM question_vocabulary WHERE quiz_id = ?1 ORDER BY question_id ASC, sort_order ASC, vocabulary ASC", quizId),
      all(db, "SELECT tag FROM quiz_tags WHERE quiz_id = ?1 ORDER BY sort_order ASC, tag ASC", quizId),
    ]);

  const choicesByQuestion = new Map();
  for (const row of choices) {
    const choice = { id: row.id, label: row.label };
    optionalString(choice, "labelEn", row.label_en);
    optionalString(choice, "explanation", row.explanation);
    optionalString(choice, "explanationEn", row.explanation_en);
    pushGrouped(choicesByQuestion, row.question_id, choice);
  }
  const tagsByQuestion = new Map();
  for (const row of tagRows) pushGrouped(tagsByQuestion, row.question_id, row.tag);
  const grammarByQuestion = new Map();
  for (const row of grammarRows) pushGrouped(grammarByQuestion, row.question_id, row.grammar_point);
  const vocabularyByQuestion = new Map();
  for (const row of vocabularyRows) pushGrouped(vocabularyByQuestion, row.question_id, row.vocabulary);

  return {
    id: quiz.id,
    title: quiz.title,
    subtitle: quiz.subtitle,
    description: quiz.description,
    difficulty: quiz.difficulty,
    published: quiz.published !== 0,
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
      if (row.difficulty_score != null) question.difficultyScore = row.difficulty_score;
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

export async function loadAllAdminQuizBanks(db) {
  const catalog = await loadAdminQuizCatalog(db);
  const quizzes = [];
  for (const summary of catalog.quizzes) {
    const quiz = await loadAdminQuizBank(db, summary.id);
    if (quiz) quizzes.push(quiz);
  }
  return { quizzes };
}

export async function saveAdminQuizBank(db, rawQuiz, actor = "admin") {
  const validation = validateAdminQuiz(rawQuiz);
  if (!validation.ok) return validation;

  const quiz = validation.quiz;
  const displayOrderRow = await first(
    db,
    "SELECT COALESCE(MAX(display_order), 0) + 1 AS next_order FROM quizzes",
  );
  const displayOrder = Number(displayOrderRow?.next_order ?? 1);

  await run(
    db,
    `
      INSERT INTO quizzes (id, title, subtitle, description, difficulty, display_order, published)
      VALUES (?1, ?2, ?3, ?4, ?5, ?6, 1)
      ON CONFLICT(id) DO UPDATE SET
        title = excluded.title,
        subtitle = excluded.subtitle,
        description = excluded.description,
        difficulty = excluded.difficulty
    `,
    quiz.id,
    quiz.title,
    quiz.subtitle,
    quiz.description,
    quiz.difficulty,
    displayOrder,
  );

  for (const table of [
    "question_vocabulary",
    "question_grammar_points",
    "question_tags",
    "choices",
    "questions",
    "quiz_tags",
  ]) {
    await run(db, `DELETE FROM ${table} WHERE quiz_id = ?1`, quiz.id);
  }

  for (let index = 0; index < quiz.diagnosticTags.length; index += 1) {
    await run(
      db,
      "INSERT INTO quiz_tags (quiz_id, tag, sort_order) VALUES (?1, ?2, ?3)",
      quiz.id,
      quiz.diagnosticTags[index],
      index + 1,
    );
  }

  for (let questionIndex = 0; questionIndex < quiz.questions.length; questionIndex += 1) {
    const question = quiz.questions[questionIndex];
    await run(
      db,
      `
        INSERT INTO questions (
          quiz_id, id, sort_order, type, prompt, prompt_en, context, context_en,
          japanese, japanese_en, correct_answer_id, accepted_answers_json,
          explanation, explanation_en, jlpt_level, difficulty_score,
          review_status, review_notes, source, author
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20)
      `,
      quiz.id,
      question.id,
      questionIndex + 1,
      question.type,
      question.prompt,
      question.promptEn,
      question.context ?? null,
      question.contextEn ?? null,
      question.japanese,
      question.japaneseEn,
      question.correctAnswerId,
      JSON.stringify(question.acceptedAnswers ?? []),
      question.explanation,
      question.explanationEn,
      question.jlptLevel ?? null,
      question.difficultyScore ?? null,
      question.reviewStatus ?? null,
      question.reviewNotes ?? null,
      question.source ?? null,
      question.author ?? null,
    );

    for (let tagIndex = 0; tagIndex < question.diagnosticTags.length; tagIndex += 1) {
      await run(
        db,
        "INSERT INTO question_tags (quiz_id, question_id, tag, sort_order) VALUES (?1, ?2, ?3, ?4)",
        quiz.id,
        question.id,
        question.diagnosticTags[tagIndex],
        tagIndex + 1,
      );
    }
    for (let gpIndex = 0; gpIndex < (question.grammarPoints ?? []).length; gpIndex += 1) {
      await run(
        db,
        "INSERT INTO question_grammar_points (quiz_id, question_id, grammar_point, sort_order) VALUES (?1, ?2, ?3, ?4)",
        quiz.id,
        question.id,
        question.grammarPoints[gpIndex],
        gpIndex + 1,
      );
    }
    for (let vocabIndex = 0; vocabIndex < (question.vocabulary ?? []).length; vocabIndex += 1) {
      await run(
        db,
        "INSERT INTO question_vocabulary (quiz_id, question_id, vocabulary, sort_order) VALUES (?1, ?2, ?3, ?4)",
        quiz.id,
        question.id,
        question.vocabulary[vocabIndex],
        vocabIndex + 1,
      );
    }
    for (let choiceIndex = 0; choiceIndex < question.choices.length; choiceIndex += 1) {
      const choice = question.choices[choiceIndex];
      await run(
        db,
        `
          INSERT INTO choices (
            quiz_id, question_id, id, sort_order, label, label_en, explanation, explanation_en
          ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
        `,
        quiz.id,
        question.id,
        choice.id,
        choiceIndex + 1,
        choice.label,
        choice.labelEn ?? null,
        choice.explanation ?? null,
        choice.explanationEn ?? null,
      );
    }
  }

  await insertRevision(db, quiz.id, actor);
  return { ok: true, errors: [], quiz };
}

async function insertRevision(db, quizId, actor) {
  try {
    await run(
      db,
      "INSERT INTO admin_content_revisions (quiz_id, actor, change_summary) VALUES (?1, ?2, ?3)",
      quizId,
      actor,
      "Admin content save",
    );
  } catch {
    // Older local databases may not have the optional revision table yet.
  }
}

function parseQuizImportPayload(payload) {
  if (Array.isArray(payload)) return payload;
  if (payload && typeof payload === "object") {
    if (Array.isArray(payload.quizzes)) return payload.quizzes;
    if (payload.quiz && typeof payload.quiz === "object") return [payload.quiz];
    if (payload.csv && typeof payload.csv === "object") return quizzesFromCsvTables(payload.csv);
  }
  return [];
}

export async function previewAdminImport(payload) {
  const quizzes = parseQuizImportPayload(payload);
  const results = quizzes.map((quiz) => validateAdminQuiz(quiz));
  return {
    ok: results.every((result) => result.ok),
    totalQuizzes: quizzes.length,
    totalQuestions: results.reduce((sum, result) => sum + result.quiz.questions.length, 0),
    errors: results.flatMap((result) => result.errors),
    quizzes: results.map((result) => result.quiz),
  };
}

export async function applyAdminImport(db, payload, actor = "admin") {
  const preview = await previewAdminImport(payload);
  if (!preview.ok) return preview;
  const saved = [];
  for (const quiz of preview.quizzes) {
    const result = await saveAdminQuizBank(db, quiz, actor);
    if (!result.ok) {
      return {
        ...preview,
        ok: false,
        errors: result.errors,
      };
    }
    saved.push(result.quiz.id);
  }
  return { ...preview, savedQuizIds: saved };
}

function csvEscape(value) {
  const text = value == null ? "" : String(value);
  return /[",\n\r]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

export function quizzesToCsvTables(quizzes) {
  const quizRows = [[
    "quiz_id",
    "title",
    "subtitle",
    "description",
    "difficulty",
    "diagnostic_tags",
  ]];
  const questionRows = [[
    "quiz_id",
    "question_id",
    "sort_order",
    "type",
    "prompt",
    "prompt_en",
    "context",
    "context_en",
    "japanese",
    "japanese_en",
    "correct_answer_id",
    "accepted_answers",
    "explanation",
    "explanation_en",
    "diagnostic_tags",
    "jlpt_level",
    "difficulty_score",
    "grammar_points",
    "vocabulary",
    "review_status",
    "review_notes",
    "source",
    "author",
  ]];
  const choiceRows = [[
    "quiz_id",
    "question_id",
    "choice_id",
    "sort_order",
    "label",
    "label_en",
    "explanation",
    "explanation_en",
  ]];

  for (const quiz of quizzes) {
    quizRows.push([
      quiz.id,
      quiz.title,
      quiz.subtitle,
      quiz.description,
      quiz.difficulty,
      joinPipe(quiz.diagnosticTags),
    ]);
    for (let questionIndex = 0; questionIndex < quiz.questions.length; questionIndex += 1) {
      const question = quiz.questions[questionIndex];
      questionRows.push([
        quiz.id,
        question.id,
        questionIndex + 1,
        question.type,
        question.prompt,
        question.promptEn,
        question.context ?? "",
        question.contextEn ?? "",
        question.japanese,
        question.japaneseEn,
        question.correctAnswerId,
        joinPipe(question.acceptedAnswers ?? []),
        question.explanation,
        question.explanationEn,
        joinPipe(question.diagnosticTags),
        question.jlptLevel ?? "",
        question.difficultyScore ?? "",
        joinPipe(question.grammarPoints ?? []),
        joinPipe(question.vocabulary ?? []),
        question.reviewStatus ?? "",
        question.reviewNotes ?? "",
        question.source ?? "",
        question.author ?? "",
      ]);
      for (let choiceIndex = 0; choiceIndex < question.choices.length; choiceIndex += 1) {
        const choice = question.choices[choiceIndex];
        choiceRows.push([
          quiz.id,
          question.id,
          choice.id,
          choiceIndex + 1,
          choice.label,
          choice.labelEn ?? "",
          choice.explanation ?? "",
          choice.explanationEn ?? "",
        ]);
      }
    }
  }

  const stringify = (rows) => rows.map((row) => row.map(csvEscape).join(",")).join("\n");
  return {
    quizzes: stringify(quizRows),
    questions: stringify(questionRows),
    choices: stringify(choiceRows),
  };
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const char = text[i];
    if (quoted) {
      if (char === '"' && text[i + 1] === '"') {
        field += '"';
        i += 1;
      } else if (char === '"') {
        quoted = false;
      } else {
        field += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ",") {
      row.push(field);
      field = "";
    } else if (char === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else if (char !== "\r") {
      field += char;
    }
  }
  row.push(field);
  if (row.some((value) => value.length > 0)) rows.push(row);
  return rows;
}

function rowsToObjects(csvText) {
  const rows = parseCsv(csvText);
  const headers = rows.shift() ?? [];
  return rows.map((row) => Object.fromEntries(headers.map((header, index) => [header, row[index] ?? ""])));
}

export function quizzesFromCsvTables(csvTables) {
  const quizRows = rowsToObjects(csvTables.quizzes ?? "");
  const questionRows = rowsToObjects(csvTables.questions ?? "");
  const choiceRows = rowsToObjects(csvTables.choices ?? "");
  const choicesByQuestion = new Map();
  for (const row of choiceRows) {
    const key = `${row.quiz_id}\u0000${row.question_id}`;
    pushGrouped(choicesByQuestion, key, {
      id: row.choice_id,
      label: row.label,
      labelEn: row.label_en || undefined,
      explanation: row.explanation || undefined,
      explanationEn: row.explanation_en || undefined,
      sortOrder: Number(row.sort_order || "0"),
    });
  }
  for (const values of choicesByQuestion.values()) {
    values.sort((a, b) => a.sortOrder - b.sortOrder || a.id.localeCompare(b.id));
  }

  const questionsByQuiz = new Map();
  for (const row of questionRows) {
    const key = `${row.quiz_id}\u0000${row.question_id}`;
    pushGrouped(questionsByQuiz, row.quiz_id, {
      id: row.question_id,
      type: row.type || "multipleChoice",
      prompt: row.prompt,
      promptEn: row.prompt_en,
      context: row.context || undefined,
      contextEn: row.context_en || undefined,
      japanese: row.japanese,
      japaneseEn: row.japanese_en,
      correctAnswerId: row.correct_answer_id,
      acceptedAnswers: splitPipe(row.accepted_answers),
      explanation: row.explanation,
      explanationEn: row.explanation_en,
      diagnosticTags: splitPipe(row.diagnostic_tags),
      jlptLevel: row.jlpt_level || undefined,
      difficultyScore: row.difficulty_score ? Number(row.difficulty_score) : undefined,
      grammarPoints: splitPipe(row.grammar_points),
      vocabulary: splitPipe(row.vocabulary),
      reviewStatus: row.review_status || undefined,
      reviewNotes: row.review_notes || undefined,
      source: row.source || undefined,
      author: row.author || undefined,
      choices: (choicesByQuestion.get(key) ?? []).map(({ sortOrder, ...choice }) => choice),
      sortOrder: Number(row.sort_order || "0"),
    });
  }
  for (const values of questionsByQuiz.values()) {
    values.sort((a, b) => a.sortOrder - b.sortOrder || a.id.localeCompare(b.id));
  }

  return quizRows.map((row) => ({
    id: row.quiz_id,
    title: row.title,
    subtitle: row.subtitle,
    description: row.description,
    difficulty: row.difficulty,
    diagnosticTags: splitPipe(row.diagnostic_tags),
    questions: (questionsByQuiz.get(row.quiz_id) ?? []).map(({ sortOrder, ...question }) => question),
  }));
}
