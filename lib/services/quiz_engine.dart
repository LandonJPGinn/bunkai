import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_type.dart';

class QuizEngine {
  QuizEngine(this._quiz)
      : assert(_quiz.questions.isNotEmpty, 'Quiz must have questions');

  final Quiz _quiz;

  int _index = 0;
  String? _selectedAnswerId;
  bool _locked = false;
  int _correctCount = 0;
  final Map<String, int> _diagnosticMisses = {};
  bool? _lastSubmittedCorrect;

  int get currentIndex => _index;
  int get totalQuestions => _quiz.questions.length;
  bool get isComplete => _index >= _quiz.questions.length;
  bool get isLocked => _locked;
  String? get selectedAnswerId => _selectedAnswerId;
  bool? get lastSubmittedCorrect => _lastSubmittedCorrect;

  QuizQuestion get currentQuestion => _quiz.questions[_index];

  bool get isLastQuestion => _index == _quiz.questions.length - 1;

  int get lockedCorrectCount => _correctCount;

  /// Submitted questions: advanced past [currentIndex], plus one if current is locked.
  int get lockedAnsweredCount => _index + (_locked ? 1 : 0);

  void selectAnswer(String choiceId) {
    if (_locked || isComplete) return;
    final q = currentQuestion;
    final valid = q.choices.any((c) => c.id == choiceId);
    if (!valid) return;
    _selectedAnswerId = choiceId;
  }

  void lockAnswer() {
    if (_locked || isComplete || _selectedAnswerId == null) return;
    final q = currentQuestion;
    if (q.type != QuizType.multipleChoice) {
      throw UnsupportedError('Question type ${q.type} is not supported yet');
    }
    final selected = _selectedAnswerId!;
    _locked = true;
    final correct = selected == q.correctAnswerId;
    _lastSubmittedCorrect = correct;
    if (correct) {
      _correctCount += 1;
    } else {
      for (final tag in q.diagnosticTags) {
        _diagnosticMisses[tag] = (_diagnosticMisses[tag] ?? 0) + 1;
      }
    }
  }

  void advance() {
    if (!_locked || isComplete) return;
    _locked = false;
    _selectedAnswerId = null;
    _lastSubmittedCorrect = null;
    _index += 1;
  }

  QuizResult buildResult() {
    final answered = _index + (_locked ? 1 : 0);
    final totalCount = answered.clamp(0, _quiz.questions.length);
    final tagsInRun = <String>{};
    for (final q in _quiz.questions.take(totalCount)) {
      tagsInRun.addAll(q.diagnosticTags);
    }
    return QuizResult(
      quizId: _quiz.id,
      correctCount: _correctCount,
      totalCount: totalCount,
      diagnosticMisses: Map<String, int>.unmodifiable(
        Map<String, int>.from(_diagnosticMisses),
      ),
      diagnosticTagsInRun: Set<String>.unmodifiable(tagsInRun),
    );
  }
}
