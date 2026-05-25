// Validates every JSON file in `assets/quiz_banks/` against the same rules
// `QuizBankLoader.ensureQuizLoaded` / `validateQuizBankContent` enforce.
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

import 'package:jpquizapp/data/bundled_quiz_bank_paths.dart';
import 'package:jpquizapp/models/quiz.dart';
import 'package:jpquizapp/services/quiz_bank_duplicate_warnings.dart';
import 'package:jpquizapp/services/quiz_bank_validation.dart';

import '_quiz_bank_files.dart';

void main() {
  final dir = resolveQuizBankDir();
  final List<File> files;
  try {
    files = listQuizBankJsonFiles(
      dir,
    ).where((f) => _jsonBasename(f) != 'quiz_catalog.json').toList();
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

  // Reverse-lookup: filename -> registered quiz id, so we can match the loader's
  // "JSON id must equal the registered id" rule when applicable.
  final registeredIdByFilename = <String, String>{};
  for (final entry in kBundledQuizBankAssetPaths.entries) {
    final base = entry.value.split('/').last;
    registeredIdByFilename[base] = entry.key;
  }

  var totalErrors = 0;
  var filesWithErrors = 0;
  final lexiconAuditErrors = _validateLexiconAndBuildLookup(dir);
  final dictionarySurfaces = _loadDictionarySurfaceSet(dir);
  totalErrors += lexiconAuditErrors.length;
  if (lexiconAuditErrors.isNotEmpty) {
    filesWithErrors++;
    for (final err in lexiconAuditErrors) {
      stderr.writeln('FAIL assets/dictionary/japanese_lexicon.json: $err');
    }
  }

  for (final file in files) {
    final path = relativePath(file);
    final errors = _validateFile(
      file,
      registeredIdByFilename,
      dictionarySurfaces,
    );
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
    try {
      _writeQuizCatalog(dir);
      stdout.writeln(
        'Wrote ${_catalogBasename()} from bundled banks '
        '(metadata-only for fast home load).',
      );
    } on Object catch (e) {
      stderr.writeln('ERROR writing quiz catalog: $e');
      exitCode = 1;
    }
  } else {
    stderr.writeln(
      '${files.length} files validated, $totalErrors '
      '${totalErrors == 1 ? 'error' : 'errors'} in $filesWithErrors '
      '${filesWithErrors == 1 ? 'file' : 'files'}',
    );
    exitCode = 1;
  }
}

String _catalogBasename() => 'quiz_catalog.json';

/// Writes `quiz_catalog.json` next to bank JSON files — derived metadata only.
void _writeQuizCatalog(Directory dir) {
  final quizzes = <Map<String, dynamic>>[];
  for (final entry in kBundledQuizBankAssetPaths.entries) {
    final relativeAssetPath = entry.value;
    final baseName = relativeAssetPath.split('/').last;
    final file = File('${dir.path}/$baseName');
    final raw = file.readAsStringSync();
    final quiz = Quiz.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    quizzes.add({
      'id': quiz.id,
      'title': quiz.title,
      'subtitle': quiz.subtitle,
      'description': quiz.description,
      'difficulty': quiz.difficulty,
      'diagnosticTags': quiz.diagnosticTags,
    });
  }
  final out = File('${dir.path}/${_catalogBasename()}');
  const encoder = JsonEncoder.withIndent('  ');
  out.writeAsStringSync(encoder.convert({'quizzes': quizzes}));
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
  Map<String, String> registeredIdByFilename,
  Set<String> dictionarySurfaces,
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
      'JSON "id" is "${quiz.id}" but expected "$registeredId" '
      'for registered path',
    );
  }

  try {
    validateQuizBankContent(quiz);
  } on QuizBankFormatException catch (e) {
    errors.add(e.message);
  }
  errors.addAll(_validateFuriganaCoverage(quiz, dictionarySurfaces));

  return errors;
}

Set<String> _loadDictionarySurfaceSet(Directory quizBankDir) {
  final path = '${quizBankDir.parent.path}/dictionary/japanese_lexicon.json';
  final file = File(path);
  if (!file.existsSync()) return const {};
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List) return const {};
  final out = <String>{};
  for (final row in decoded) {
    if (row is! Map) continue;
    final surface = row['surface'];
    if (surface is String && surface.trim().isNotEmpty) {
      out.add(surface.trim());
    }
  }
  return out;
}

List<String> _validateFuriganaCoverage(
  Quiz quiz,
  Set<String> dictionarySurfaces,
) {
  if (dictionarySurfaces.isEmpty) return const [];
  final errors = <String>[];
  for (final q in quiz.questions) {
    if (q.japanese.contains('日本') &&
        !q.japanese.contains('日本[') &&
        !dictionarySurfaces.contains('日本')) {
      errors.add(
        'Quiz "${quiz.id}" / question "${q.id}": '
        'contains 日本 but dictionary is missing surface "日本" '
        '(likely furigana mismatch such as にほん)',
      );
    }
  }
  return errors;
}

List<String> _validateLexiconAndBuildLookup(Directory quizBankDir) {
  final path = '${quizBankDir.parent.path}/dictionary/japanese_lexicon.json';
  final file = File(path);
  if (!file.existsSync()) {
    return ['dictionary file not found at $path'];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List) {
    return ['dictionary root must be a JSON array'];
  }
  final errors = <String>[];
  final placeholderDefinition = RegExp(
    r'^(todo|tbd|n/?a|none|-+)$',
    caseSensitive: false,
  );
  for (var i = 0; i < decoded.length; i++) {
    final row = decoded[i];
    if (row is! Map) {
      errors.add('entry[$i] must be an object');
      continue;
    }
    final surface = row['surface'];
    final reading = row['reading'];
    final definitions = row['definitions'];
    if (surface is! String || surface.trim().isEmpty) {
      errors.add('entry[$i] has invalid surface');
      continue;
    }
    if (reading is! String || reading.trim().isEmpty) {
      errors.add('entry[$i] "$surface" has empty reading');
    }
    if (definitions is! List || definitions.isEmpty) {
      errors.add('entry[$i] "$surface" must have non-empty definitions');
      continue;
    }
    final cleaned = definitions
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) {
      errors.add('entry[$i] "$surface" has no usable definitions');
      continue;
    }
    for (final d in cleaned) {
      if (placeholderDefinition.hasMatch(d)) {
        errors.add('entry[$i] "$surface" has placeholder definition "$d"');
      }
    }
  }
  return errors;
}
