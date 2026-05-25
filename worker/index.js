import {
  errorResponse,
  jsonResponse,
  loadQuizBank,
  loadQuizCatalog,
} from "../functions/api/_quiz_content.js";

function databaseFromEnv(env) {
  if (!env.DB) {
    throw new Error("D1 binding DB is not configured.");
  }
  return env.DB;
}

function logApi(message, details = {}) {
  console.log("jpquizapp api:", message, details);
}

function methodNotAllowed(request, pathname) {
  logApi("method not allowed", { method: request.method, pathname });
  return errorResponse(405, "Method not allowed.");
}

async function handleApiRequest(request, env) {
  const url = new URL(request.url);
  logApi("request", { method: request.method, pathname: url.pathname });

  if (url.pathname === "/api/quiz-catalog") {
    if (request.method !== "GET") return methodNotAllowed(request, url.pathname);

    try {
      const catalog = await loadQuizCatalog(databaseFromEnv(env));
      logApi("quiz catalog loaded", { count: catalog.quizzes.length });
      return jsonResponse(catalog);
    } catch (error) {
      console.error("quiz-catalog failed", error);
      return errorResponse(500, "Could not load quiz catalog.");
    }
  }

  const quizMatch = url.pathname.match(/^\/api\/quizzes\/([^/]+)$/);
  if (quizMatch) {
    if (request.method !== "GET") return methodNotAllowed(request, url.pathname);

    const id = decodeURIComponent(quizMatch[1]).trim();
    if (id.length === 0) {
      logApi("missing quiz id", { pathname: url.pathname });
      return errorResponse(400, "Missing quiz id.");
    }

    try {
      const quiz = await loadQuizBank(databaseFromEnv(env), id);
      if (!quiz) {
        logApi("quiz not found", { id });
        return errorResponse(404, "Quiz not found.");
      }
      logApi("quiz loaded", { id, questions: quiz.questions.length });
      return jsonResponse(quiz);
    } catch (error) {
      console.error("quiz detail failed", { id, error });
      return errorResponse(500, "Could not load quiz.");
    }
  }

  logApi("route not found", { method: request.method, pathname: url.pathname });
  return errorResponse(404, "API route not found.");
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.startsWith("/api/")) {
      return handleApiRequest(request, env);
    }

    return env.ASSETS.fetch(request);
  },
};
