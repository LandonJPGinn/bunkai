import {
  databaseFromContext,
  errorResponse,
  jsonResponse,
  loadQuizBank,
} from "../_quiz_content.js";

export async function onRequestGet(context) {
  const id = context.params.id;
  if (typeof id !== "string" || id.trim().length === 0) {
    return errorResponse(400, "Missing quiz id.");
  }

  try {
    const quiz = await loadQuizBank(databaseFromContext(context), id);
    if (!quiz) {
      return errorResponse(404, "Quiz not found.");
    }
    return jsonResponse(quiz);
  } catch (error) {
    console.error("quiz detail failed", { id, error });
    return errorResponse(500, "Could not load quiz.");
  }
}
