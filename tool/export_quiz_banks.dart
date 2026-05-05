// Validates and pretty-prints bundled quiz banks under assets/quiz_banks/.
// Run from repo root: dart run tool/export_quiz_banks.dart
//
// (Initial JSON was generated from legacy Dart lists; banks are now the source
// of truth — edit the JSON files, then run this to normalize formatting.)

import 'dart:convert';
import 'dart:io';

import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/services/quiz_bank_validation.dart';

void main() {
  const names = <String>[
    'particle_forensics.json',
    'clause_untangler.json',
    'omission_detective.json',
    'register_radar.json',
    'transitivity_duel.json',
    'verb_conjugation.json',
  ];

  final encoder = JsonEncoder.withIndent('  ');

  for (final name in names) {
    final file = File('assets/quiz_banks/$name');
    if (!file.existsSync()) {
      stderr.writeln('Missing ${file.path}');
      exitCode = 1;
      continue;
    }
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('${file.path}: root must be a JSON object');
      exitCode = 1;
      continue;
    }
    final quiz = Quiz.fromJson(decoded);
    validateQuizBankContent(quiz);
    file.writeAsStringSync(encoder.convert(quiz.toJson()));
    stdout.writeln('Validated ${file.path} (${quiz.questions.length} questions)');
  }
}
