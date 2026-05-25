import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';

class QuizEngine {
  QuizEngine(this._quiz)
      : assert(_quiz.questions.isNotEmpty, 'Quiz must have questions');

  final Quiz _quiz;

  int _index = 0;
  String _draftAnswer = '';
  String? _submittedAnswer;
  bool _locked = false;
  int _correctCount = 0;
  final Map<String, int> _diagnosticMisses = {};
  bool? _lastSubmittedCorrect;

  int get currentIndex => _index;
  int get totalQuestions => _quiz.questions.length;
  bool get isComplete => _index >= _quiz.questions.length;
  bool get isLocked => _locked;
  String get draftAnswer => _draftAnswer;
  String? get submittedAnswer => _submittedAnswer;
  bool? get lastSubmittedCorrect => _lastSubmittedCorrect;

  QuizQuestion get currentQuestion => _quiz.questions[_index];

  bool get isLastQuestion => _index == _quiz.questions.length - 1;

  int get lockedCorrectCount => _correctCount;

  /// Submitted questions: advanced past [currentIndex], plus one if current is locked.
  int get lockedAnsweredCount => _index + (_locked ? 1 : 0);

  void setDraftAnswer(String value) {
    if (_locked || isComplete) return;
    _draftAnswer = value;
  }

  void lockAnswer() {
    if (_locked || isComplete) return;
    final submitted = _draftAnswer.trim();
    if (submitted.isEmpty) return;
    final q = currentQuestion;
    _locked = true;
    _submittedAnswer = submitted;
    final correct = q.canonicalAnswers.contains(submitted);
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
    _draftAnswer = '';
    _submittedAnswer = null;
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
