import 'dart:math';

import 'package:bunkai/models/answer_choice.dart';
import 'package:bunkai/models/practice_options.dart';
import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/models/quiz_question.dart';
import 'package:bunkai/models/quiz_type.dart';
import 'package:bunkai/services/practice_session_builder.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestion _mc({
  required String id,
  String? jlptLevel,
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
      difficulty: PracticeJlptFilter.all,
      countPreset: PracticeCountPreset.ten,
      random: Random(0),
    );
    expect(out.questions.length, 3);
    expect(out.questions.map((q) => q.id).toSet(), {'1', '2', '3'});
  });

  test('filter by jlpt band excludes non-matching', () {
    final base = _quizThreeBands();
    final out = buildPracticeSessionQuiz(
      base,
      difficulty: PracticeJlptFilter.n4,
      countPreset: PracticeCountPreset.all,
      random: Random(0),
    );
    expect(out.questions.map((q) => q.id).toSet(), {'1', '3'});
    expect(out.questions.length, 2);
  });

  test('fewer than requested count after filter', () {
    final base = _quizThreeBands();
    final out = buildPracticeSessionQuiz(
      base,
      difficulty: PracticeJlptFilter.n3,
      countPreset: PracticeCountPreset.fifty,
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
      difficulty: PracticeJlptFilter.n4,
      countPreset: PracticeCountPreset.all,
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
      difficulty: PracticeJlptFilter.all,
      countPreset: PracticeCountPreset.ten,
      random: random,
    );
    expect(out.questions.length, 10);
    expect(out.questions.map((q) => q.id).toSet().length, 10);
  });

  test('filteredQuestionsForPreview matches builder filter', () {
    final base = _quizThreeBands();
    expect(
      filteredQuestionsForPreview(base, PracticeJlptFilter.n3).length,
      1,
    );
  });
}
