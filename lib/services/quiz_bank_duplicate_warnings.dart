import '../models/quiz.dart';
import '../models/quiz_question.dart';
import 'quiz_bank_text_normalize.dart';

const int _kUnitSeparator = 0x1F; // US — cannot appear in normalized text

/// Per-question rows that may be duplicates, for local validation / scripts.
///
/// Warnings are based on [normalizeQuizBankText] equality (no fuzzy matching).
List<String> formatQuizBankDuplicateWarnings(Quiz quiz) {
  final quizName = quiz.id.name;
  final out = <String>[];
  final questions = quiz.questions;

  _appendGroups(
    out,
    quizName,
    _groupBy(questions, (q) => normalizeQuizBankText(q.japanese)),
    'duplicate japanese',
    (q) => q.japanese,
  );

  _appendGroups(
    out,
    quizName,
    _groupBy(questions, (q) => normalizeQuizBankText(q.prompt)),
    'duplicate prompt',
    (q) => q.prompt,
  );

  _appendGroups(
    out,
    quizName,
    _groupBy(questions, (q) {
      final j = normalizeQuizBankText(q.japanese);
      if (j.isEmpty) return '';
      final answers = q.canonicalAnswers
          .map(normalizeQuizBankText)
          .where((a) => a.isNotEmpty)
          .toList()
        ..sort();
      if (answers.isEmpty) return '';
      return '$j\u0000${answers.join(String.fromCharCode(_kUnitSeparator))}';
    }),
    'same japanese and canonical answers',
    (q) => q.japanese,
  );

  _appendGroups(
    out,
    quizName,
    _groupBy(questions, _choiceSetKey),
    'repeated answer choice set',
    (q) => _formatChoiceSetSample(q),
  );

  return out;
}

String _choiceSetKey(QuizQuestion q) {
  if (q.choices.isEmpty) return '';
  final parts = [for (final c in q.choices) normalizeQuizBankText(c.label)]
    ..sort();
  return parts.join(String.fromCharCode(_kUnitSeparator));
}

String _formatChoiceSetSample(QuizQuestion q) {
  final parts = [for (final c in q.choices) normalizeQuizBankText(c.label)]
    ..sort();
  return parts.join(' / ');
}

Map<String, List<QuizQuestion>> _groupBy(
  List<QuizQuestion> questions,
  String Function(QuizQuestion q) keyFn,
) {
  final map = <String, List<QuizQuestion>>{};
  for (final q in questions) {
    final k = keyFn(q);
    if (k.isEmpty) continue;
    map.putIfAbsent(k, () => []).add(q);
  }
  return map;
}

void _appendGroups(
  List<String> out,
  String quizName,
  Map<String, List<QuizQuestion>> groups,
  String reasonTag,
  String Function(QuizQuestion q) sampleLine,
) {
  for (final entry in groups.entries) {
    final list = entry.value;
    if (list.length < 2) continue;
    final sorted = [...list]..sort((a, b) => a.id.compareTo(b.id));
    final ids = sorted.map((q) => q.id).toList();
    final sample = sampleLine(sorted.first);
    final idStr = _formatIdList(ids);
    final buf = StringBuffer()
      ..writeln('WARNING $quizName $idStr may be duplicates ($reasonTag):')
      ..write('  ')
      ..write(sample);
    out.add(buf.toString());
  }
}

String _formatIdList(List<String> ids) {
  if (ids.isEmpty) return '';
  if (ids.length == 1) return ids.single;
  if (ids.length == 2) {
    return '${ids[0]} and ${ids[1]}';
  }
  return '${ids.sublist(0, ids.length - 1).join(', ')} and ${ids.last}';
}
