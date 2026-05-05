import 'dart:math';

import '../models/practice_options.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';

/// Builds a session [Quiz] with a subset / order of questions from [base].
Quiz buildPracticeSessionQuiz(
  Quiz base, {
  required PracticeJlptFilter difficulty,
  required PracticeCountPreset countPreset,
  required PracticeOrderMode mode,
  Random? random,
}) {
  final filtered = _filterByDifficulty(base, difficulty);
  final picked = _pickQuestions(
    filtered,
    countPreset: countPreset,
    mode: mode,
    random: random ?? Random(),
  );
  return Quiz(
    id: base.id,
    title: base.title,
    subtitle: base.subtitle,
    description: base.description,
    difficulty: base.difficulty,
    diagnosticTags: base.diagnosticTags,
    questions: picked,
  );
}

/// Questions that match the difficulty filter, in original bank order.
List<QuizQuestion> filteredQuestionsForPreview(
  Quiz base,
  PracticeJlptFilter difficulty,
) {
  return _filterByDifficulty(base, difficulty);
}

List<QuizQuestion> _filterByDifficulty(
  Quiz base,
  PracticeJlptFilter difficulty,
) {
  if (difficulty == PracticeJlptFilter.all) {
    return List<QuizQuestion>.from(base.questions);
  }
  final band = difficulty.bandString!;
  return [
    for (final q in base.questions)
      if (_matchesBand(q, base, band)) q,
  ];
}

bool _matchesBand(QuizQuestion q, Quiz base, String band) {
  if (q.jlptLevel == band) return true;
  if (q.jlptLevel == null && base.difficulty == band) return true;
  return false;
}

List<QuizQuestion> _pickQuestions(
  List<QuizQuestion> filtered, {
  required PracticeCountPreset countPreset,
  required PracticeOrderMode mode,
  required Random random,
}) {
  final max = countPreset.maxCount;
  final takeCount = max == null
      ? filtered.length
      : (max < filtered.length ? max : filtered.length);
  if (takeCount == 0) return [];

  if (mode == PracticeOrderMode.ordered) {
    return filtered.take(takeCount).toList();
  }

  final copy = List<QuizQuestion>.from(filtered);
  copy.shuffle(random);
  return copy.take(takeCount).toList();
}
