enum QuizId {
  particleForensics,
  clauseUntangler,
  omissionDetective,
  registerRadar,
  transitivityDuel,
  verbConjugation,
}

/// Parses route arguments; expects [QuizId.name] (e.g. `particleForensics`).
QuizId? quizIdFromRouteName(String value) {
  try {
    return QuizId.values.byName(value);
  } on ArgumentError {
    return null;
  }
}
