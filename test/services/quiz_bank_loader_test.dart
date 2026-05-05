import 'package:bunkai/models/answer_choice.dart';
import 'package:bunkai/models/question_review_status.dart';
import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/models/quiz_question.dart';
import 'package:bunkai/models/quiz_type.dart';
import 'package:bunkai/services/quiz_bank_loader.dart';
import 'package:bunkai/services/quiz_bank_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    QuizBankLoader.instance.debugReset();
  });

  group('QuizBankLoader', () {
    test('load parses and validates all six asset banks', () async {
      await QuizBankLoader.instance.load();
      final all = QuizBankLoader.instance.allQuizzes();
      expect(all, hasLength(6));
      expect(all.map((q) => q.id).toSet(), equals(QuizId.values.toSet()));
      for (final q in all) {
        expect(q.questions, isNotEmpty);
      }
    });

    test('quizFor returns cached quiz', () async {
      await QuizBankLoader.instance.load();
      final a = QuizBankLoader.instance.quizFor(QuizId.particleForensics);
      final b = QuizBankLoader.instance.quizFor(QuizId.particleForensics);
      expect(identical(a, b), isTrue);
    });
  });

  group('validateQuizBankContent', () {
    test('throws with quiz and question id when correctAnswerId is invalid', () {
      final bad = Quiz(
        id: QuizId.particleForensics,
        title: 'T',
        subtitle: 'S',
        description: 'D',
        difficulty: 'X',
        questions: [
          QuizQuestion(
            id: 'bad_q1',
            type: QuizType.multipleChoice,
            prompt: 'p',
            japanese: 'j',
            choices: const [
              AnswerChoice(id: 'a', label: 'one'),
              AnswerChoice(id: 'b', label: 'two'),
            ],
            correctAnswerId: 'z',
            explanation: 'e',
            diagnosticTags: const ['t'],
          ),
        ],
      );
      expect(
        () => validateQuizBankContent(bad),
        throwsA(
          isA<QuizBankFormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('particleForensics'),
              contains('bad_q1'),
              contains('correctAnswerId'),
            ),
          ),
        ),
      );
    });

    test('throws on duplicate question id', () {
      final bad = Quiz(
        id: QuizId.clauseUntangler,
        title: 'T',
        subtitle: 'S',
        description: 'D',
        difficulty: 'X',
        questions: const [
          QuizQuestion(
            id: 'dup',
            type: QuizType.multipleChoice,
            prompt: 'p1',
            japanese: 'j1',
            choices: [
              AnswerChoice(id: 'a', label: 'x'),
              AnswerChoice(id: 'b', label: 'y'),
            ],
            correctAnswerId: 'a',
            explanation: 'e',
            diagnosticTags: const ['t'],
            jlptLevel: 'N4',
            difficultyScore: 1,
            grammarPoints: const ['g'],
            vocabulary: const ['v'],
            reviewStatus: QuestionReviewStatus.draft,
          ),
          QuizQuestion(
            id: 'dup',
            type: QuizType.multipleChoice,
            prompt: 'p2',
            japanese: 'j2',
            choices: [
              AnswerChoice(id: 'a', label: 'x'),
              AnswerChoice(id: 'b', label: 'y'),
            ],
            correctAnswerId: 'a',
            explanation: 'e',
            diagnosticTags: const ['t'],
            jlptLevel: 'N4',
            difficultyScore: 1,
            grammarPoints: const ['g'],
            vocabulary: const ['v'],
            reviewStatus: QuestionReviewStatus.draft,
          ),
        ],
      );
      expect(
        () => validateQuizBankContent(bad),
        throwsA(
          isA<QuizBankFormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('clauseUntangler'),
              contains('dup'),
              contains('duplicate'),
            ),
          ),
        ),
      );
    });

    test('throws when diagnosticTags is empty', () {
      final bad = Quiz(
        id: QuizId.registerRadar,
        title: 'T',
        subtitle: 'S',
        description: 'D',
        difficulty: 'X',
        questions: const [
          QuizQuestion(
            id: 'no_tags',
            type: QuizType.multipleChoice,
            prompt: 'p',
            japanese: 'j',
            choices: [
              AnswerChoice(id: 'a', label: 'x'),
              AnswerChoice(id: 'b', label: 'y'),
            ],
            correctAnswerId: 'a',
            explanation: 'e',
            diagnosticTags: [],
          ),
        ],
      );
      expect(
        () => validateQuizBankContent(bad),
        throwsA(
          isA<QuizBankFormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('registerRadar'),
              contains('no_tags'),
              contains('diagnosticTags'),
            ),
          ),
        ),
      );
    });

    test('throws when grammarPoints entry is whitespace only', () {
      final bad = Quiz(
        id: QuizId.omissionDetective,
        title: 'T',
        subtitle: 'S',
        description: 'D',
        difficulty: 'N4',
        questions: [
          QuizQuestion(
            id: 'gp_ws',
            type: QuizType.multipleChoice,
            prompt: 'p',
            japanese: 'j',
            choices: const [
              AnswerChoice(id: 'a', label: 'x'),
              AnswerChoice(id: 'b', label: 'y'),
            ],
            correctAnswerId: 'a',
            explanation: 'e',
            diagnosticTags: const ['t'],
            grammarPoints: const ['  '],
          ),
        ],
      );
      expect(
        () => validateQuizBankContent(bad),
        throwsA(
          isA<QuizBankFormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('omissionDetective'),
              contains('gp_ws'),
              contains('grammarPoints'),
            ),
          ),
        ),
      );
    });
  });
}
