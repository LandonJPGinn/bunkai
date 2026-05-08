import '../models/quiz_result.dart';

class ScoreService {
  const ScoreService();

  /// Minimum percent (inclusive) to count as a passing run for UI summary.
  static const int passingPercentThreshold = 70;

  double fraction(QuizResult result) {
    if (result.totalCount == 0) return 0;
    return result.correctCount / result.totalCount;
  }

  int percentRounded(QuizResult result) {
    return (fraction(result) * 100).round();
  }

  String summaryLabel(QuizResult result) {
    final p = percentRounded(result);
    if (p == 100) return 'Clean run';
    if (p >= 80) return 'Solid session';
    if (p >= 60) return 'Room to tighten';
    return 'Review recommended';
  }

  bool isPassing(QuizResult result) =>
      percentRounded(result) >= passingPercentThreshold;

  /// Celebration overlay only for a perfect score (still [isPassing]).
  bool showConfetti(QuizResult result) => percentRounded(result) == 100;

  String resultsHeadline(QuizResult result) {
    if (!isPassing(result)) return 'Keep practicing';
    if (showConfetti(result)) return 'Perfect score';
    return 'Nice work';
  }
}
