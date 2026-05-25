import 'package:jpquizapp/models/answer_choice.dart';
import 'package:jpquizapp/models/question_review_status.dart';
import 'package:jpquizapp/models/quiz_question.dart';
import 'package:jpquizapp/models/quiz_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizQuestion.fromMap', () {
    test('parses optional difficulty metadata', () {
      final q = QuizQuestion.fromMap({
        'id': 'x',
        'type': 'multipleChoice',
        'prompt': 'p',
        'japanese': 'j',
        'promptEn': 'p-en',
        'japaneseEn': 'j-en',
        'choices': [
          {'id': 'a', 'label': '1', 'labelEn': '1-en'},
          {'id': 'b', 'label': '2', 'labelEn': '2-en'},
        ],
        'correctAnswerId': 'a',
        'explanation': 'e',
        'explanationEn': 'e-en',
        'diagnosticTags': ['t'],
        'jlptLevel': 'N4',
        'difficultyScore': 2,
        'grammarPoints': ['g1', 'g2'],
        'vocabulary': ['駅', '会う'],
      });
      expect(q.jlptLevel, 'N4');
      expect(q.difficultyScore, 2);
      expect(q.grammarPoints, ['g1', 'g2']);
      expect(q.vocabulary, ['駅', '会う']);
    });

    test('toMap omits empty optional lists and null scalars', () {
      const q = QuizQuestion(
        id: 'x',
        type: QuizType.multipleChoice,
        prompt: 'p',
        japanese: 'j',
        promptEn: 'pe',
        japaneseEn: 'je',
        choices: [
          AnswerChoice(id: 'a', label: '1', labelEn: '1'),
          AnswerChoice(id: 'b', label: '2', labelEn: '2'),
        ],
        correctAnswerId: 'a',
        explanation: 'e',
        explanationEn: 'ee',
        diagnosticTags: ['t'],
      );
      final m = q.toMap();
      expect(m.containsKey('jlptLevel'), isFalse);
      expect(m.containsKey('difficultyScore'), isFalse);
      expect(m.containsKey('grammarPoints'), isFalse);
      expect(m.containsKey('vocabulary'), isFalse);
    });

    test('toMap includes optional fields when set', () {
      const q = QuizQuestion(
        id: 'x',
        type: QuizType.multipleChoice,
        prompt: 'p',
        japanese: 'j',
        promptEn: 'pe',
        japaneseEn: 'je',
        choices: [
          AnswerChoice(id: 'a', label: '1', labelEn: '1'),
          AnswerChoice(id: 'b', label: '2', labelEn: '2'),
        ],
        correctAnswerId: 'a',
        explanation: 'e',
        explanationEn: 'ee',
        diagnosticTags: ['t'],
        jlptLevel: 'N3-N2',
        difficultyScore: 5,
        grammarPoints: ['a'],
        vocabulary: ['b'],
      );
      final m = q.toMap();
      expect(m['jlptLevel'], 'N3-N2');
      expect(m['difficultyScore'], 5);
      expect(m['grammarPoints'], ['a']);
      expect(m['vocabulary'], ['b']);
    });

    test('canonicalAnswers prefers acceptedAnswers then falls back to choices', () {
      const typed = QuizQuestion(
        id: 'typed',
        type: QuizType.textInput,
        prompt: 'p',
        japanese: 'j',
        promptEn: 'pe',
        japaneseEn: 'je',
        acceptedAnswers: ['かな', 'かんじ'],
        explanation: 'e',
        explanationEn: 'ee',
        diagnosticTags: ['t'],
      );
      expect(typed.canonicalAnswers, ['かな', 'かんじ']);

      const fallback = QuizQuestion(
        id: 'fallback',
        type: QuizType.multipleChoice,
        prompt: 'p',
        japanese: 'j',
        promptEn: 'pe',
        japaneseEn: 'je',
        choices: [
          AnswerChoice(id: 'a', label: 'を', labelEn: 'wo'),
          AnswerChoice(id: 'b', label: 'に', labelEn: 'ni'),
        ],
        correctAnswerId: 'b',
        explanation: 'e',
        explanationEn: 'ee',
        diagnosticTags: ['t'],
      );
      expect(fallback.canonicalAnswers, ['に']);
    });

    test('rejects invalid jlptLevel', () {
      expect(
        () => QuizQuestion.fromMap({
          'id': 'x',
          'type': 'multipleChoice',
          'prompt': 'p',
          'japanese': 'j',
          'promptEn': 'p',
          'japaneseEn': 'j',
          'choices': [
            {'id': 'a', 'label': '1', 'labelEn': '1'},
            {'id': 'b', 'label': '2', 'labelEn': '2'},
          ],
          'correctAnswerId': 'a',
          'explanation': 'e',
          'explanationEn': 'e',
          'diagnosticTags': ['t'],
          'jlptLevel': 'N1',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('jlptLevel'),
          ),
        ),
      );
    });

    test('rejects out-of-range difficultyScore', () {
      expect(
        () => QuizQuestion.fromMap({
          'id': 'x',
          'type': 'multipleChoice',
          'prompt': 'p',
          'japanese': 'j',
          'promptEn': 'p',
          'japaneseEn': 'j',
          'choices': [
            {'id': 'a', 'label': '1', 'labelEn': '1'},
            {'id': 'b', 'label': '2', 'labelEn': '2'},
          ],
          'correctAnswerId': 'a',
          'explanation': 'e',
          'explanationEn': 'e',
          'diagnosticTags': ['t'],
          'difficultyScore': 6,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-string grammarPoints entry', () {
      expect(
        () => QuizQuestion.fromMap({
          'id': 'x',
          'type': 'multipleChoice',
          'prompt': 'p',
          'japanese': 'j',
          'promptEn': 'p',
          'japaneseEn': 'j',
          'choices': [
            {'id': 'a', 'label': '1', 'labelEn': '1'},
            {'id': 'b', 'label': '2', 'labelEn': '2'},
          ],
          'correctAnswerId': 'a',
          'explanation': 'e',
          'explanationEn': 'e',
          'diagnosticTags': ['t'],
          'grammarPoints': [1],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses optional review metadata', () {
      final q = QuizQuestion.fromMap({
        'id': 'x',
        'type': 'multipleChoice',
        'prompt': 'p',
        'japanese': 'j',
        'promptEn': 'p',
        'japaneseEn': 'j',
        'choices': [
          {'id': 'a', 'label': '1', 'labelEn': '1'},
          {'id': 'b', 'label': '2', 'labelEn': '2'},
        ],
        'correctAnswerId': 'a',
        'explanation': 'e',
        'explanationEn': 'e',
        'diagnosticTags': ['t'],
        'reviewStatus': 'needs_review',
        'reviewNotes': 'check okurigana',
        'source': 'midori',
        'author': 't',
      });
      expect(q.reviewStatus, QuestionReviewStatus.needsReview);
      expect(q.reviewNotes, 'check okurigana');
      expect(q.source, 'midori');
      expect(q.author, 't');
    });

    test('needs_review round-trips in toMap', () {
      final q = QuizQuestion.fromMap({
        'id': 'x',
        'type': 'multipleChoice',
        'prompt': 'p',
        'japanese': 'j',
        'promptEn': 'p',
        'japaneseEn': 'j',
        'choices': [
          {'id': 'a', 'label': '1', 'labelEn': '1'},
          {'id': 'b', 'label': '2', 'labelEn': '2'},
        ],
        'correctAnswerId': 'a',
        'explanation': 'e',
        'explanationEn': 'e',
        'diagnosticTags': ['t'],
        'reviewStatus': 'needs_review',
      });
      final m = q.toMap();
      expect(m['reviewStatus'], 'needs_review');
    });

    test('toMap omits unset review fields', () {
      const q = QuizQuestion(
        id: 'x',
        type: QuizType.multipleChoice,
        prompt: 'p',
        japanese: 'j',
        promptEn: 'pe',
        japaneseEn: 'je',
        choices: [
          AnswerChoice(id: 'a', label: '1', labelEn: '1'),
          AnswerChoice(id: 'b', label: '2', labelEn: '2'),
        ],
        correctAnswerId: 'a',
        explanation: 'e',
        explanationEn: 'ee',
        diagnosticTags: ['t'],
      );
      final m = q.toMap();
      expect(m.containsKey('reviewStatus'), isFalse);
      expect(m.containsKey('reviewNotes'), isFalse);
      expect(m.containsKey('source'), isFalse);
      expect(m.containsKey('author'), isFalse);
    });

    test('rejects invalid reviewStatus', () {
      expect(
        () => QuizQuestion.fromMap({
          'id': 'x',
          'type': 'multipleChoice',
          'prompt': 'p',
          'japanese': 'j',
          'promptEn': 'p',
          'japaneseEn': 'j',
          'choices': [
            {'id': 'a', 'label': '1', 'labelEn': '1'},
            {'id': 'b', 'label': '2', 'labelEn': '2'},
          ],
          'correctAnswerId': 'a',
          'explanation': 'e',
          'explanationEn': 'e',
          'diagnosticTags': ['t'],
          'reviewStatus': 'published',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('reviewStatus'),
          ),
        ),
      );
    });
  });
}
