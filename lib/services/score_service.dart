import '../models/quiz_result.dart';

class ScoreService {
  const ScoreService();

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
}
