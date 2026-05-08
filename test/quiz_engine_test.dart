import 'package:bunkai/models/answer_choice.dart';
import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/models/quiz_question.dart';
import 'package:bunkai/models/quiz_type.dart';
import 'package:bunkai/services/quiz_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizEngine', () {
    late Quiz miniQuiz;

    setUp(() {
      miniQuiz = const Quiz(
        id: QuizId.particleForensics,
        title: 'T',
        subtitle: 'S',
        description: 'D',
        difficulty: 'X',
        questions: [
          QuizQuestion(
            id: 't_q1',
            type: QuizType.multipleChoice,
            prompt: 'P1',
            japanese: 'J1',
            promptEn: 'P1',
            japaneseEn: 'J1',
            choices: [
              AnswerChoice(id: 'a', label: 'wrong', labelEn: 'wrong'),
              AnswerChoice(id: 'b', label: 'right', labelEn: 'right'),
            ],
            correctAnswerId: 'b',
            explanation: 'E1',
            explanationEn: 'E1',
            diagnosticTags: ['tagA', 'tagB'],
          ),
          QuizQuestion(
            id: 't_q2',
            type: QuizType.multipleChoice,
            prompt: 'P2',
            japanese: 'J2',
            promptEn: 'P2',
            japaneseEn: 'J2',
            choices: [
              AnswerChoice(id: 'a', label: 'ok', labelEn: 'ok'),
              AnswerChoice(id: 'b', label: 'no', labelEn: 'no'),
            ],
            correctAnswerId: 'a',
            explanation: 'E2',
            explanationEn: 'E2',
            diagnosticTags: ['tagC'],
          ),
        ],
      );
    });

    test('selectAnswer ignored after lock', () {
      final engine = QuizEngine(miniQuiz);
      engine.selectAnswer('b');
      engine.lockAnswer();
      expect(engine.isLocked, true);
      engine.selectAnswer('a');
      expect(engine.selectedAnswerId, 'b');
    });

    test('diagnosticMisses increment on wrong answer', () {
      final engine = QuizEngine(miniQuiz);
      engine.selectAnswer('a');
      engine.lockAnswer();
      expect(engine.lastSubmittedCorrect, false);
      final r = engine.buildResult();
      expect(r.diagnosticMisses['tagA'], 1);
      expect(r.diagnosticMisses['tagB'], 1);
      expect(r.correctCount, 0);
      expect(r.totalCount, 1);
      expect(r.diagnosticTagsInRun, {'tagA', 'tagB'});
    });

    test('correct answer advances counts and advance clears selection', () {
      final engine = QuizEngine(miniQuiz);
      engine.selectAnswer('b');
      engine.lockAnswer();
      expect(engine.lastSubmittedCorrect, true);
      expect(engine.lockedCorrectCount, 1);
      engine.advance();
      expect(engine.selectedAnswerId, isNull);
      expect(engine.lastSubmittedCorrect, isNull);
      expect(engine.isLocked, false);
      expect(engine.currentIndex, 1);

      engine.selectAnswer('a');
      engine.lockAnswer();
      expect(engine.lastSubmittedCorrect, true);
      final r = engine.buildResult();
      expect(r.correctCount, 2);
      expect(r.totalCount, 2);
      expect(r.diagnosticMisses, isEmpty);
      expect(r.diagnosticTagsInRun, {'tagA', 'tagB', 'tagC'});
    });

    test('wrong then right accumulates misses only for wrong', () {
      final engine = QuizEngine(miniQuiz);
      engine.selectAnswer('a');
      engine.lockAnswer();
      engine.advance();
      engine.selectAnswer('a');
      engine.lockAnswer();
      final r = engine.buildResult();
      expect(r.correctCount, 1);
      expect(r.diagnosticMisses['tagA'], 1);
      expect(r.diagnosticMisses['tagC'], isNull);
      expect(r.diagnosticTagsInRun, {'tagA', 'tagB', 'tagC'});
    });
  });
}
