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

function methodNotAllowed() {
  return errorResponse(405, "Method not allowed.");
}

async function handleApiRequest(request, env) {
  const url = new URL(request.url);

  if (url.pathname === "/api/quiz-catalog") {
    if (request.method !== "GET") return methodNotAllowed();

    try {
      return jsonResponse(await loadQuizCatalog(databaseFromEnv(env)));
    } catch (error) {
      console.error("quiz-catalog failed", error);
      return errorResponse(500, "Could not load quiz catalog.");
    }
  }

  const quizMatch = url.pathname.match(/^\/api\/quizzes\/([^/]+)$/);
  if (quizMatch) {
    if (request.method !== "GET") return methodNotAllowed();

    const id = decodeURIComponent(quizMatch[1]).trim();
    if (id.length === 0) {
      return errorResponse(400, "Missing quiz id.");
    }

    try {
      const quiz = await loadQuizBank(databaseFromEnv(env), id);
      if (!quiz) {
        return errorResponse(404, "Quiz not found.");
      }
      return jsonResponse(quiz);
    } catch (error) {
      console.error("quiz detail failed", { id, error });
      return errorResponse(500, "Could not load quiz.");
    }
  }

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
