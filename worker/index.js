import {
  errorResponse,
  jsonResponse,
  loadQuizBank,
  loadQuizCatalog,
} from "../functions/api/_quiz_content.js";
import {
  adminErrorResponse,
  adminJsonResponse,
  applyAdminImport,
  loadAdminQuizBank,
  loadAllAdminQuizBanks,
  loginAdmin,
  logoutAdmin,
  previewAdminImport,
  quizzesToCsvTables,
  requireAdmin,
  saveAdminQuizBank,
} from "../functions/api/_admin_content.js";

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

  if (url.pathname === "/api/admin/login") {
    if (request.method !== "POST") return methodNotAllowed(request, url.pathname);
    try {
      return await loginAdmin(request, env);
    } catch (error) {
      console.error("admin login failed", error);
      return adminErrorResponse(500, "Admin login is not configured.");
    }
  }

  if (url.pathname === "/api/admin/logout") {
    if (request.method !== "POST") return methodNotAllowed(request, url.pathname);
    return logoutAdmin();
  }

  if (url.pathname.startsWith("/api/admin/")) {
    const unauthorized = await requireAdmin(request, env);
    if (unauthorized) return unauthorized;
    return handleAdminApiRequest(request, env, url);
  }

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

async function handleAdminApiRequest(request, env, url) {
  if (url.pathname === "/api/admin/session") {
    if (request.method !== "GET") return methodNotAllowed(request, url.pathname);
    return adminJsonResponse({ authenticated: true });
  }

  const db = databaseFromEnv(env);

  if (url.pathname === "/api/admin/quizzes") {
    if (request.method === "GET") {
      const payload = await loadAllAdminQuizBanks(db);
      return adminJsonResponse(payload);
    }
    return methodNotAllowed(request, url.pathname);
  }

  if (url.pathname === "/api/admin/export") {
    if (request.method !== "GET") return methodNotAllowed(request, url.pathname);
    const payload = await loadAllAdminQuizBanks(db);
    if (url.searchParams.get("format") === "csv") {
      return adminJsonResponse({ csv: quizzesToCsvTables(payload.quizzes) });
    }
    return adminJsonResponse(payload);
  }

  if (url.pathname === "/api/admin/import/preview") {
    if (request.method !== "POST") return methodNotAllowed(request, url.pathname);
    let body;
    try {
      body = await request.json();
    } catch {
      return adminErrorResponse(400, "Expected a JSON request body.");
    }
    return adminJsonResponse(await previewAdminImport(body));
  }

  if (url.pathname === "/api/admin/import/apply") {
    if (request.method !== "POST") return methodNotAllowed(request, url.pathname);
    let body;
    try {
      body = await request.json();
    } catch {
      return adminErrorResponse(400, "Expected a JSON request body.");
    }
    return adminJsonResponse(await applyAdminImport(db, body));
  }

  const quizMatch = url.pathname.match(/^\/api\/admin\/quizzes\/([^/]+)$/);
  if (quizMatch) {
    const id = decodeURIComponent(quizMatch[1]).trim();
    if (id.length === 0) return adminErrorResponse(400, "Missing quiz id.");

    if (request.method === "GET") {
      const quiz = await loadAdminQuizBank(db, id);
      if (!quiz) return adminErrorResponse(404, "Quiz not found.");
      return adminJsonResponse({ quiz });
    }

    if (request.method === "PUT") {
      let body;
      try {
        body = await request.json();
      } catch {
        return adminErrorResponse(400, "Expected a JSON request body.");
      }
      const quiz = body.quiz ?? body;
      if (quiz.id !== id) {
        return adminErrorResponse(400, "Route quiz id must match body quiz id.");
      }
      const result = await saveAdminQuizBank(db, quiz);
      if (!result.ok) {
        return adminErrorResponse(422, "Quiz content is invalid.", result.errors);
      }
      return adminJsonResponse({ quiz: result.quiz });
    }

    return methodNotAllowed(request, url.pathname);
  }

  logApi("admin route not found", { method: request.method, pathname: url.pathname });
  return adminErrorResponse(404, "Admin API route not found.");
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
