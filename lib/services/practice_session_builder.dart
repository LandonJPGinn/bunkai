import 'dart:math';

import '../models/answer_choice.dart';
import '../models/practice_options.dart';
import '../models/quiz.dart';
import '../models/quiz_id.dart';
import '../models/quiz_question.dart';
import '../models/quiz_type.dart';

const List<PracticeJlptFilter> _jlptFilterOrder = <PracticeJlptFilter>[
  PracticeJlptFilter.n4,
  PracticeJlptFilter.n4N3,
  PracticeJlptFilter.n3,
  PracticeJlptFilter.n3N2,
  PracticeJlptFilter.n2,
];

PracticeQuizAvailableSettings derivePracticeAvailableSettings(Quiz base) {
  if (base.id == QuizId.verbConjugation) {
    final tags = <String>{};
    for (final q in base.questions) {
      for (final tag in q.diagnosticTags) {
        if (kConjugationPracticeTags.contains(tag)) {
          tags.add(tag);
        }
      }
    }
    final ordered = [
      for (final tag in kConjugationPracticeTags)
        if (tags.contains(tag)) tag,
    ];
    return PracticeQuizAvailableSettings(
      useConjugationFilter: true,
      availableConjugationTags: ordered,
    );
  }

  final available = <PracticeJlptFilter>[PracticeJlptFilter.all];
  for (final filter in _jlptFilterOrder) {
    if (_filterByDifficulty(base, filter).isNotEmpty) {
      available.add(filter);
    }
  }
  return PracticeQuizAvailableSettings(
    useConjugationFilter: false,
    availableJlptFilters: available,
  );
}

/// Builds a session [Quiz] with a subset / order of questions from [base].
Quiz buildPracticeSessionQuiz(
  Quiz base, {
  required PracticeQuizSettings settings,
  Random? random,
}) {
  final rng = random ?? Random();
  final available = derivePracticeAvailableSettings(base);
  final normalized = settings.sanitizedFor(available);
  final filtered = _filterQuestions(base, normalized, available);
  final picked = _pickQuestions(
    filtered,
    countPreset: normalized.countPreset,
    random: rng,
  );
  final sessionQuestions = base.id == QuizId.verbConjugation
      ? _reshapeVerbConjugationPrompts(picked, rng)
      : picked;
  return Quiz(
    id: base.id,
    title: base.title,
    subtitle: base.subtitle,
    description: base.description,
    difficulty: base.difficulty,
    diagnosticTags: base.diagnosticTags,
    questions: sessionQuestions,
  );
}

/// Questions that match the difficulty filter, in original bank order.
List<QuizQuestion> filteredQuestionsForPreview(
  Quiz base,
  PracticeQuizSettings settings,
) {
  final available = derivePracticeAvailableSettings(base);
  final normalized = settings.sanitizedFor(available);
  return _filterQuestions(base, normalized, available);
}

List<QuizQuestion> _filterQuestions(
  Quiz base,
  PracticeQuizSettings settings,
  PracticeQuizAvailableSettings available,
) {
  if (available.useConjugationFilter) {
    return _filterByConjugation(base, settings, available);
  }
  return _filterByDifficulty(base, settings.jlptFilter);
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

List<QuizQuestion> _filterByConjugation(
  Quiz base,
  PracticeQuizSettings settings,
  PracticeQuizAvailableSettings available,
) {
  final selected = settings.conjugationTags.isEmpty
      ? available.availableConjugationTags.toSet()
      : settings.conjugationTags;
  if (selected.isEmpty) {
    return List<QuizQuestion>.from(base.questions);
  }
  return [
    for (final q in base.questions)
      if (q.diagnosticTags.any(selected.contains)) q,
  ];
}

List<QuizQuestion> _pickQuestions(
  List<QuizQuestion> filtered, {
  required PracticeCountPreset countPreset,
  required Random random,
}) {
  final max = countPreset.maxCount;
  final takeCount = max == null
      ? filtered.length
      : (max < filtered.length ? max : filtered.length);
  if (takeCount == 0) return [];

  final copy = List<QuizQuestion>.from(filtered);
  copy.shuffle(random);
  return copy.take(takeCount).toList();
}

List<QuizQuestion> _reshapeVerbConjugationPrompts(
  List<QuizQuestion> questions,
  Random random,
) {
  return [
    for (final q in questions) _reshapeVerbConjugationQuestion(q, random),
  ];
}

QuizQuestion _reshapeVerbConjugationQuestion(QuizQuestion q, Random random) {
  AnswerChoice? correctChoice;
  for (final c in q.choices) {
    if (c.id == q.correctAnswerId) {
      correctChoice = c;
      break;
    }
  }
  final correctLabel = correctChoice?.label;
  if (correctLabel == null || correctLabel.isEmpty) return q;

  final distractorLabels = [
    for (final c in q.choices)
      if (c.id != q.correctAnswerId &&
          c.label.isNotEmpty &&
          c.label != correctLabel)
        c.label,
  ];
  if (distractorLabels.isEmpty) return q;

  final sourceForm = distractorLabels[random.nextInt(distractorLabels.length)];
  final targetLabel = _targetLabelForConjugationQuestion(q);
  final instruction = targetLabel.isEmpty
      ? 'Convert this verb form.'
      : 'Convert to $targetLabel.';

  return QuizQuestion(
    id: q.id,
    type: QuizType.textInput,
    prompt: instruction,
    japanese: sourceForm,
    context: q.context,
    promptEn: instruction,
    japaneseEn: sourceForm,
    contextEn: q.contextEn,
    choices: q.choices,
    correctAnswerId: q.correctAnswerId,
    acceptedAnswers: q.canonicalAnswers,
    explanation: q.explanation,
    explanationEn: q.explanationEn,
    diagnosticTags: q.diagnosticTags,
    jlptLevel: q.jlptLevel,
    difficultyScore: q.difficultyScore,
    grammarPoints: q.grammarPoints,
    vocabulary: q.vocabulary,
    reviewStatus: q.reviewStatus,
    reviewNotes: q.reviewNotes,
    source: q.source,
    author: q.author,
  );
}

String _targetLabelForConjugationQuestion(QuizQuestion q) {
  for (final tag in kConjugationPracticeTags) {
    if (q.diagnosticTags.contains(tag)) {
      return tag.conjugationMenuLabel.toLowerCase();
    }
  }
  for (final tag in q.diagnosticTags) {
    if (kConjugationPracticeTags.contains(tag)) {
      return tag.conjugationMenuLabel.toLowerCase();
    }
  }
  return '';
}
