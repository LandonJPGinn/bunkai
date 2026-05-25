import 'dart:math';

import 'package:jpquizapp/models/answer_choice.dart';
import 'package:jpquizapp/models/practice_options.dart';
import 'package:jpquizapp/models/quiz.dart';
import 'package:jpquizapp/models/quiz_id.dart';
import 'package:jpquizapp/models/quiz_question.dart';
import 'package:jpquizapp/models/quiz_type.dart';
import 'package:jpquizapp/services/practice_session_builder.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestion _mc({
  required String id,
  String? jlptLevel,
  List<String> diagnosticTags = const <String>[],
}) {
  return QuizQuestion(
    id: id,
    type: QuizType.multipleChoice,
    prompt: 'p',
    japanese: 'j',
    promptEn: 'p',
    japaneseEn: 'j',
    choices: const [
      AnswerChoice(id: 'a', label: 'A', labelEn: 'A'),
      AnswerChoice(id: 'b', label: 'B', labelEn: 'B'),
    ],
    correctAnswerId: 'a',
    explanation: 'e',
    explanationEn: 'e',
    jlptLevel: jlptLevel,
    diagnosticTags: diagnosticTags,
  );
}

Quiz _quizThreeBands() {
  return Quiz(
    id: QuizId.particleForensics,
    title: 'T',
    subtitle: 'S',
    description: 'D',
    difficulty: 'N4-N3',
    questions: [
      _mc(id: '1', jlptLevel: 'N4'),
      _mc(id: '2', jlptLevel: 'N3'),
      _mc(id: '3', jlptLevel: 'N4'),
    ],
  );
}

void main() {
  test('session respects cap and includes only bank questions', () {
    final base = _quizThreeBands();
    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.ten,
        jlptFilter: PracticeJlptFilter.all,
      ),
      random: Random(0),
    );
    expect(out.questions.length, 3);
    expect(out.questions.map((q) => q.id).toSet(), {'1', '2', '3'});
  });

  test('filter by jlpt band excludes non-matching', () {
    final base = _quizThreeBands();
    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
        jlptFilter: PracticeJlptFilter.n4,
      ),
      random: Random(0),
    );
    expect(out.questions.map((q) => q.id).toSet(), {'1', '3'});
    expect(out.questions.length, 2);
  });

  test('fewer than requested count after filter', () {
    final base = _quizThreeBands();
    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.fifty,
        jlptFilter: PracticeJlptFilter.n3,
      ),
      random: Random(0),
    );
    expect(out.questions.length, 1);
    expect(out.questions.single.id, '2');
  });

  test('untagged matches quiz.difficulty when band selected', () {
    final base = Quiz(
      id: QuizId.particleForensics,
      title: 'T',
      subtitle: 'S',
      description: 'D',
      difficulty: 'N4',
      questions: [
        _mc(id: 'u1', jlptLevel: null),
        _mc(id: 't1', jlptLevel: 'N3'),
      ],
    );
    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
        jlptFilter: PracticeJlptFilter.n4,
      ),
      random: Random(0),
    );
    expect(out.questions.map((q) => q.id).toList(), ['u1']);
  });

  test('shuffle has no duplicate ids in session', () {
    final questions = <QuizQuestion>[
      for (var i = 0; i < 12; i++) _mc(id: 'q$i', jlptLevel: 'N4'),
    ];
    final base = Quiz(
      id: QuizId.particleForensics,
      title: 'T',
      subtitle: 'S',
      description: 'D',
      difficulty: 'N4',
      questions: questions,
    );
    final random = Random(12345);
    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.ten,
        jlptFilter: PracticeJlptFilter.all,
      ),
      random: random,
    );
    expect(out.questions.length, 10);
    expect(out.questions.map((q) => q.id).toSet().length, 10);
  });

  test('filteredQuestionsForPreview matches builder filter', () {
    final base = _quizThreeBands();
    expect(
      filteredQuestionsForPreview(
        base,
        const PracticeQuizSettings(jlptFilter: PracticeJlptFilter.n3),
      ).length,
      1,
    );
  });

  test(
    'derivePracticeAvailableSettings returns only present difficulty levels',
    () {
      final base = _quizThreeBands();
      final available = derivePracticeAvailableSettings(base);
      expect(available.availableJlptFilters, [
        PracticeJlptFilter.all,
        PracticeJlptFilter.n4,
        PracticeJlptFilter.n3,
      ]);
      expect(available.showDifficultyControl, true);
    },
  );

  test('verb conjugation uses selected conjugation tags', () {
    final base = Quiz(
      id: QuizId.verbConjugation,
      title: 'T',
      subtitle: 'S',
      description: 'D',
      difficulty: 'N4',
      questions: [
        _mc(id: 't', diagnosticTags: ['te_form']),
        _mc(id: 'p', diagnosticTags: ['past_form']),
        _mc(id: 'n', diagnosticTags: ['nai_form']),
      ],
    );

    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
        conjugationTags: {'te_form', 'past_form'},
      ),
      random: Random(0),
    );
    expect(out.questions.map((q) => q.id).toSet(), {'t', 'p'});
  });

  test('verb conjugation reshapes prompt to source-form conversion task', () {
    final base = const Quiz(
      id: QuizId.verbConjugation,
      title: 'T',
      subtitle: 'S',
      description: 'D',
      difficulty: 'N4',
      questions: [
        QuizQuestion(
          id: 'vc1',
          type: QuizType.multipleChoice,
          prompt: '食べる → Convert to te-form.',
          japanese: '食べる → て形',
          promptEn: 'Convert to te-form.',
          japaneseEn: 'Eat -> te-form',
          choices: [
            AnswerChoice(id: 'a', label: '食べます', labelEn: 'tabemasu'),
            AnswerChoice(id: 'b', label: '食べた', labelEn: 'tabeta'),
            AnswerChoice(id: 'c', label: '食べて', labelEn: 'tabete'),
            AnswerChoice(id: 'd', label: '食べない', labelEn: 'tabenai'),
          ],
          correctAnswerId: 'c',
          explanation: 'e',
          explanationEn: 'e',
          diagnosticTags: ['verb_conjugation', 'te_form'],
        ),
      ],
    );

    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
      ),
      random: Random(0),
    );

    final q = out.questions.single;
    expect(q.promptEn, 'Convert to te form.');
    expect(q.prompt, 'Convert to te form.');
    expect(q.japanese, isNot('食べて'));
    expect({'食べます', '食べた', '食べない'}.contains(q.japanese), isTrue);
  });

  test('non-verb quizzes do not reshape prompt text', () {
    final base = const Quiz(
      id: QuizId.particleForensics,
      title: 'T',
      subtitle: 'S',
      description: 'D',
      difficulty: 'N4',
      questions: [
        QuizQuestion(
          id: 'p1',
          type: QuizType.multipleChoice,
          prompt: 'Original prompt',
          japanese: '元の日本語',
          promptEn: 'Original instruction',
          japaneseEn: 'Original Japanese line',
          choices: [
            AnswerChoice(id: 'a', label: 'A', labelEn: 'A'),
            AnswerChoice(id: 'b', label: 'B', labelEn: 'B'),
          ],
          correctAnswerId: 'a',
          explanation: 'e',
          explanationEn: 'e',
        ),
      ],
    );

    final out = buildPracticeSessionQuiz(
      base,
      settings: const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
      ),
      random: Random(0),
    );

    final q = out.questions.single;
    expect(q.prompt, 'Original prompt');
    expect(q.promptEn, 'Original instruction');
    expect(q.japanese, '元の日本語');
    expect(q.japaneseEn, 'Original Japanese line');
  });
}
