// Validates every JSON file in `assets/quiz_banks/` against the same rules
// `QuizBankLoader.load()` enforces at app startup.
//
// Run from repo root (or anywhere — the script resolves paths from
// `Platform.script`):
//
//   dart run scripts/validate_quiz_banks.dart
//
// Exits 0 if all banks pass, 1 if any error is found. All errors are reported
// in a single pass (we don't stop at the first failure) so editors can fix
// many issues per run.
//
// Pure Dart — does not require the Flutter runtime.

import 'dart:convert';
import 'dart:io';

import 'package:bunkai/data/bundled_quiz_bank_paths.dart';
import 'package:bunkai/models/quiz.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/services/quiz_bank_duplicate_warnings.dart';
import 'package:bunkai/services/quiz_bank_validation.dart';

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

  // Reverse-lookup: filename -> registered QuizId, so we can match the loader's
  // "JSON id must equal the registered id" rule when applicable.
  final registeredIdByFilename = <String, QuizId>{};
  for (final entry in kBundledQuizBankAssetPaths.entries) {
    final base = entry.value.split('/').last;
    registeredIdByFilename[base] = entry.key;
  }

  var totalErrors = 0;
  var filesWithErrors = 0;

  for (final file in files) {
    final path = relativePath(file);
    final errors = _validateFile(file, registeredIdByFilename);
    if (errors.isEmpty) {
      // Question count is informational — only printed on success.
      try {
        final quiz = Quiz.fromJson(
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
        );
        stdout.writeln('OK   $path (${quiz.questions.length} questions)');
        for (final w in formatQuizBankDuplicateWarnings(quiz)) {
          stderr.writeln(w);
        }
      } catch (_) {
        stdout.writeln('OK   $path');
      }
    } else {
      filesWithErrors++;
      for (final err in errors) {
        stderr.writeln('FAIL $path: $err');
      }
      totalErrors += errors.length;
    }
  }

  stdout.writeln('');
  if (totalErrors == 0) {
    stdout.writeln('${files.length} files validated, 0 errors');
  } else {
    stderr.writeln(
      '${files.length} files validated, $totalErrors '
      '${totalErrors == 1 ? 'error' : 'errors'} in $filesWithErrors '
      '${filesWithErrors == 1 ? 'file' : 'files'}',
    );
    exitCode = 1;
  }
}

String _jsonBasename(File file) {
  if (file.uri.pathSegments.isNotEmpty) {
    return file.uri.pathSegments.last;
  }
  return file.path.split(RegExp(r'[\\/]')).last;
}

/// Runs all loader-time checks for [file] and returns a list of error
/// messages. Empty list means the file passed.
List<String> _validateFile(
  File file,
  Map<String, QuizId> registeredIdByFilename,
) {
  final errors = <String>[];

  final basename = _jsonBasename(file);
  if (!registeredIdByFilename.containsKey(basename)) {
    errors.add(
      'not listed in kBundledQuizBankAssetPaths (QuizBankLoader will not load '
      'this file)',
    );
  }

  final String raw;
  try {
    raw = file.readAsStringSync();
  } on FileSystemException catch (e) {
    errors.add('failed to read file: ${e.message}');
    return errors;
  }

  final dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException catch (e) {
    errors.add('invalid JSON: ${e.message}');
    return errors;
  }

  if (decoded is! Map<String, dynamic>) {
    errors.add('expected root JSON object, got ${decoded.runtimeType}');
    return errors;
  }

  final Quiz quiz;
  try {
    quiz = Quiz.fromJson(decoded);
  } on FormatException catch (e) {
    errors.add(e.message);
    return errors;
  } catch (e) {
    errors.add('parse error: $e');
    return errors;
  }

  final registeredId = registeredIdByFilename[basename];
  if (registeredId != null && quiz.id != registeredId) {
    errors.add(
      'JSON "id" is "${quiz.id.name}" but expected "${registeredId.name}" '
      'for registered path',
    );
  }

  try {
    validateQuizBankContent(quiz);
  } on QuizBankFormatException catch (e) {
    errors.add(e.message);
  }

  return errors;
}
