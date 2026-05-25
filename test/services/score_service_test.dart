import 'package:jpquizapp/models/quiz_id.dart';
import 'package:jpquizapp/models/quiz_result.dart';
import 'package:jpquizapp/services/score_service.dart';
import 'package:flutter_test/flutter_test.dart';

QuizResult _result({required int correct, required int total}) {
  return QuizResult(
    quizId: QuizId.particleForensics,
    correctCount: correct,
    totalCount: total,
    diagnosticMisses: const {},
    diagnosticTagsInRun: const {},
  );
}

void main() {
  const score = ScoreService();

  test('isPassing at 70 percent inclusive', () {
    expect(score.isPassing(_result(correct: 7, total: 10)), isTrue);
    expect(score.percentRounded(_result(correct: 7, total: 10)), 70);
  });

  test('isPassing false below 70', () {
    expect(score.isPassing(_result(correct: 6, total: 10)), isFalse);
  });

  test('showConfetti only at 100 percent', () {
    expect(score.showConfetti(_result(correct: 10, total: 10)), isTrue);
    expect(score.showConfetti(_result(correct: 9, total: 10)), isFalse);
  });

  test('resultsHeadline reflects pass and perfect', () {
    expect(score.resultsHeadline(_result(correct: 5, total: 10)), 'Keep practicing');
    expect(score.resultsHeadline(_result(correct: 8, total: 10)), 'Nice work');
    expect(score.resultsHeadline(_result(correct: 10, total: 10)), 'Perfect score');
  });
}
