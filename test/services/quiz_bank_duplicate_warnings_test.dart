import 'package:bunkai/models/answer_choice.dart';
import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/models/quiz_question.dart';
import 'package:bunkai/models/quiz_type.dart';
import 'package:bunkai/services/quiz_bank_duplicate_warnings.dart';
import 'package:flutter_test/flutter_test.dart';

Quiz _minimalQuiz(List<QuizQuestion> questions) {
  return Quiz(
    id: QuizId.particleForensics,
    title: 'T',
    subtitle: 'S',
    description: 'D',
    difficulty: 'X',
    questions: questions,
  );
}

QuizQuestion _q({
  required String id,
  required String prompt,
  required String japanese,
  required List<AnswerChoice> choices,
  required String correctAnswerId,
}) {
  return QuizQuestion(
    id: id,
    type: QuizType.multipleChoice,
    prompt: prompt,
    japanese: japanese,
    promptEn: prompt,
    japaneseEn: japanese,
    choices: choices,
    correctAnswerId: correctAnswerId,
    explanation: 'explanation',
    explanationEn: 'explanation',
    diagnosticTags: const ['tag'],
  );
}

void main() {
  group('formatQuizBankDuplicateWarnings', () {
    test('empty question list yields no warnings', () {
      expect(formatQuizBankDuplicateWarnings(_minimalQuiz([])), isEmpty);
    });

    test('duplicate japanese (after normalization)', () {
      final quiz = _minimalQuiz([
        _q(
          id: 'pf_048',
          prompt: 'p1',
          japanese: '駅\u3000友だちに会いました。',
          choices: const [
            AnswerChoice(id: 'a', label: 'x', labelEn: 'x'),
            AnswerChoice(id: 'b', label: 'y', labelEn: 'y'),
          ],
          correctAnswerId: 'a',
        ),
        _q(
          id: 'pf_022',
          prompt: 'p2',
          japanese: '駅 友だちに会いました.', // halfwidth period
          choices: const [
            AnswerChoice(id: 'a', label: 'u', labelEn: 'u'),
            AnswerChoice(id: 'b', label: 'v', labelEn: 'v'),
          ],
          correctAnswerId: 'b',
        ),
      ]);
      final w = formatQuizBankDuplicateWarnings(quiz);
      expect(
        w.any(
          (s) =>
              s.contains('duplicate japanese') &&
              s.contains('pf_022') &&
              s.contains('pf_048'),
        ),
        isTrue,
      );
      expect(w.first, contains('WARNING particleForensics'));
      // Sorted ids: pf_022 before pf_048
      expect(w.first, contains('pf_022 and pf_048'));
    });

    test('duplicate prompt', () {
      final quiz = _minimalQuiz([
        _q(
          id: 'a1',
          prompt: 'Choose the best particle',
          japanese: 'j1',
          choices: const [
            AnswerChoice(id: 'a', label: 'x', labelEn: 'x'),
            AnswerChoice(id: 'b', label: 'y', labelEn: 'y'),
          ],
          correctAnswerId: 'a',
        ),
        _q(
          id: 'a2',
          prompt: 'Choose  the  best  particle',
          japanese: 'j2',
          choices: const [
            AnswerChoice(id: 'a', label: 'p', labelEn: 'p'),
            AnswerChoice(id: 'b', label: 'q', labelEn: 'q'),
          ],
          correctAnswerId: 'a',
        ),
      ]);
      final w = formatQuizBankDuplicateWarnings(quiz);
      expect(
        w.any((s) => s.contains('duplicate prompt') && s.contains('a1 and a2')),
        isTrue,
      );
    });

    test('same normalized japanese and same correctAnswerId', () {
      final quiz = _minimalQuiz([
        _q(
          id: 'x1',
          prompt: 'different one',
          japanese: '同じ文',
          choices: const [
            AnswerChoice(id: 'a', label: '1', labelEn: '1'),
            AnswerChoice(id: 'b', label: '2', labelEn: '2'),
          ],
          correctAnswerId: 'a',
        ),
        _q(
          id: 'x2',
          prompt: 'different two',
          japanese: '同じ文',
          choices: const [
            AnswerChoice(id: 'a', label: '3', labelEn: '3'),
            AnswerChoice(id: 'b', label: '4', labelEn: '4'),
          ],
          correctAnswerId: 'a',
        ),
      ]);
      final w = formatQuizBankDuplicateWarnings(quiz);
      expect(
        w.any(
          (s) =>
              s.contains('same japanese and correctAnswerId') &&
              s.contains('x1 and x2'),
        ),
        isTrue,
      );
    });

    test('repeated answer choice set (order-independent)', () {
      final quiz = _minimalQuiz([
        _q(
          id: 'c1',
          prompt: 'p1',
          japanese: 'j1',
          choices: const [
            AnswerChoice(id: 'w', label: 'は', labelEn: 'は'),
            AnswerChoice(id: 'x', label: 'が', labelEn: 'が'),
            AnswerChoice(id: 'y', label: 'を', labelEn: 'を'),
          ],
          correctAnswerId: 'w',
        ),
        _q(
          id: 'c2',
          prompt: 'p2',
          japanese: 'j2',
          choices: const [
            AnswerChoice(id: 'a', label: 'を', labelEn: 'を'),
            AnswerChoice(id: 'b', label: 'は', labelEn: 'は'),
            AnswerChoice(id: 'c', label: 'が', labelEn: 'が'),
          ],
          correctAnswerId: 'a',
        ),
      ]);
      final w = formatQuizBankDuplicateWarnings(quiz);
      expect(
        w.any(
          (s) =>
              s.contains('repeated answer choice set') && s.contains('c1 and c2'),
        ),
        isTrue,
      );
    });

    test('three ids use Oxford-style list with and', () {
      final quiz = _minimalQuiz([
        _q(
          id: 'z1',
          prompt: 'p',
          japanese: 'same',
          choices: const [
            AnswerChoice(id: 'a', label: 'x', labelEn: 'x'),
            AnswerChoice(id: 'b', label: 'y', labelEn: 'y'),
          ],
          correctAnswerId: 'a',
        ),
        _q(
          id: 'z2',
          prompt: 'p',
          japanese: 'same',
          choices: const [
            AnswerChoice(id: 'a', label: 'x', labelEn: 'x'),
            AnswerChoice(id: 'b', label: 'y', labelEn: 'y'),
          ],
          correctAnswerId: 'b',
        ),
        _q(
          id: 'z3',
          prompt: 'p',
          japanese: 'same',
          choices: const [
            AnswerChoice(id: 'a', label: 'x', labelEn: 'x'),
            AnswerChoice(id: 'b', label: 'y', labelEn: 'y'),
          ],
          correctAnswerId: 'b',
        ),
      ]);
      final w = formatQuizBankDuplicateWarnings(quiz);
      final dupJp = w.firstWhere((s) => s.contains('duplicate japanese'));
      expect(dupJp, contains('z1, z2 and z3'));
    });
  });
}
