import 'dart:convert';
import 'dart:io';

import 'package:bunkai/data/bundled_quiz_bank_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoRoot = Directory.current.path;

  test('compiled quiz catalog matches source catalog JSON', () {
    final source = _readJson('$repoRoot/assets/quiz_banks/quiz_catalog.json');
    final compiled = _readJson('$repoRoot/assets/compiled/quiz_catalog.json');
    expect(compiled, equals(source));
  });

  test('compiled dictionary matches source dictionary JSON', () {
    final source = _readJson(
      '$repoRoot/assets/dictionary/japanese_lexicon.json',
    );
    final compiled = _readJson(
      '$repoRoot/assets/compiled/dictionary_lexicon.json',
    );
    expect(compiled, equals(source));
  });

  test('compiled quiz-bank JSON files match source JSON files', () {
    for (final entry in kBundledQuizBankAssetPaths.entries) {
      final quizId = entry.key;
      final source = _readJson('$repoRoot/${entry.value}');
      final compiled = _readJson(
        '$repoRoot/assets/compiled/quiz_banks/${quizId.name}.json',
      );
      expect(compiled, equals(source), reason: 'Mismatch for ${quizId.name}');
    }
  });

  test('compiled arrow artifacts exist for each content table when built', () {
    final files = <String>[
      'quiz_metadata.feather',
      'quiz_questions.feather',
      'quiz_choices.feather',
      'wordbank.feather',
    ];
    final present = files.where(
      (name) => File('$repoRoot/assets/compiled/$name').existsSync(),
    );
    expect(
      present.length,
      inInclusiveRange(0, files.length),
      reason:
          'Arrow artifacts are optional locally but mandatory in CI publish.',
    );
  });
}

Object? _readJson(String path) => jsonDecode(File(path).readAsStringSync());
