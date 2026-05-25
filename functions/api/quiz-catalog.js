import {
  databaseFromContext,
  errorResponse,
  jsonResponse,
  loadQuizCatalog,
} from "./_quiz_content.js";

export async function onRequestGet(context) {
  try {
    const catalog = await loadQuizCatalog(databaseFromContext(context));
    return jsonResponse(catalog);
  } catch (error) {
    console.error("quiz-catalog failed", error);
    return errorResponse(500, "Could not load quiz catalog.");
  }
}
