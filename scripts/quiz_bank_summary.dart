// Prints a per-bank summary of every JSON file in `assets/quiz_banks/`:
//   - quiz id
//   - title
//   - question count
//   - reviewed / draft / needs_review counts (from optional reviewStatus)
//   - first / last question id
//   - question type counts
//   - diagnostic tag counts (aggregated across all questions)
//
// Run from repo root (or anywhere — the script resolves paths from
// `Platform.script`):
//
//   dart run scripts/quiz_bank_summary.dart
//
// Pure Dart — does not require the Flutter runtime.

import 'dart:convert';
import 'dart:io';

import 'package:jpquizapp/models/question_review_status.dart';
import 'package:jpquizapp/models/quiz.dart';

import '_quiz_bank_files.dart';

void main() {
  final dir = resolveQuizBankDir();
  final List<File> files;
  try {
    files = listQuizBankJsonFiles(dir);
  } on FileSystemException catch (e) {
    stderr.writeln('ERROR: ${e.message}: ${e.path}');
    exitCode = 1;
    return;
  }

  if (files.isEmpty) {
    stderr.writeln('ERROR: no JSON files found under ${dir.path}');
    exitCode = 1;
    return;
  }

  var hadParseError = false;

  for (final file in files) {
    final path = relativePath(file);
    final Quiz quiz;
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map<String, dynamic>) {
        stderr.writeln('ERROR $path: root must be a JSON object');
        hadParseError = true;
        continue;
      }
      quiz = Quiz.fromJson(decoded);
    } on FormatException catch (e) {
      stderr.writeln('ERROR $path: ${e.message}');
      hadParseError = true;
      continue;
    } catch (e) {
      stderr.writeln('ERROR $path: $e');
      hadParseError = true;
      continue;
    }

    _printQuizSummary(quiz);
  }

  if (hadParseError) {
    exitCode = 1;
  }
}

void _printQuizSummary(Quiz quiz) {
  final tagCounts = <String, int>{};
  final typeCounts = <String, int>{};
  var reviewedCount = 0;
  var draftCount = 0;
  var needsReviewCount = 0;
  for (final q in quiz.questions) {
    typeCounts.update(q.type.name, (v) => v + 1, ifAbsent: () => 1);
    for (final tag in q.diagnosticTags) {
      tagCounts.update(tag, (v) => v + 1, ifAbsent: () => 1);
    }
    switch (q.reviewStatus) {
      case QuestionReviewStatus.reviewed:
        reviewedCount++;
      case QuestionReviewStatus.draft:
        draftCount++;
      case QuestionReviewStatus.needsReview:
        needsReviewCount++;
      case null:
        break;
    }
  }

  final firstId = quiz.questions.isNotEmpty ? quiz.questions.first.id : '-';
  final lastId = quiz.questions.isNotEmpty ? quiz.questions.last.id : '-';

  final header = '── ${quiz.id.name} ';
  stdout.writeln(header.padRight(60, '─'));

  // Single-value rows (aligned).
  const labelWidth = 20;
  void row(String label, String value) {
    stdout.writeln('${label.padRight(labelWidth)}: $value');
  }

  row('title', quiz.title);
  row('question count', '${quiz.questions.length}');
  row('reviewed count', '$reviewedCount');
  row('draft count', '$draftCount');
  row('needs_review count', '$needsReviewCount');
  row('first question id', firstId);
  row('last question id', lastId);

  stdout.writeln('${'question type counts'.padRight(labelWidth)}:');
  if (typeCounts.isEmpty) {
    stdout.writeln('  (none)');
  } else {
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final maxCount = sortedTypes.first.value;
    final countWidth = maxCount.toString().length;
    for (final e in sortedTypes) {
      stdout.writeln('  ${e.key.padRight(28)} ${e.value.toString().padLeft(countWidth)}');
    }
  }

  stdout.writeln('${'diagnostic tag counts'.padRight(labelWidth)}:');
  if (tagCounts.isEmpty) {
    stdout.writeln('  (none)');
  } else {
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final maxTagLen =
        sortedTags.map((e) => e.key.length).fold<int>(0, (a, b) => a > b ? a : b);
    final maxCount = sortedTags.first.value;
    final countWidth = maxCount.toString().length;
    for (final e in sortedTags) {
      stdout.writeln(
        '  ${e.key.padRight(maxTagLen)} ${e.value.toString().padLeft(countWidth)}',
      );
    }
  }

  stdout.writeln('');
}
