/// Known bundled quiz ids.
///
/// Remote D1-backed quizzes can use any non-empty string id; these constants are
/// retained for bundled fallbacks, tests, and per-quiz presentation defaults.
abstract final class QuizId {
  static const String particleForensics = 'particleForensics';
  static const String clauseUntangler = 'clauseUntangler';
  static const String omissionDetective = 'omissionDetective';
  static const String registerRadar = 'registerRadar';
  static const String transitivityDuel = 'transitivityDuel';
  static const String verbConjugation = 'verbConjugation';

  static const List<String> values = [
    particleForensics,
    clauseUntangler,
    omissionDetective,
    registerRadar,
    transitivityDuel,
    verbConjugation,
  ];
}

/// Parses route arguments; any non-empty id can be loaded from the remote API.
String? quizIdFromRouteName(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
