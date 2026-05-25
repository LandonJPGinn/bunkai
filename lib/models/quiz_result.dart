class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.correctCount,
    required this.totalCount,
    required this.diagnosticMisses,
    required this.diagnosticTagsInRun,
  });

  final String quizId;
  final int correctCount;
  final int totalCount;
  final Map<String, int> diagnosticMisses;

  /// Union of [QuizQuestion.diagnosticTags] on questions in this run
  /// (first [totalCount] questions), including tags on questions answered correctly.
  final Set<String> diagnosticTagsInRun;
}
