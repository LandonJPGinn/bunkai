import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/bundled_quiz_bank_paths.dart';
import '../models/quiz.dart';
import '../models/quiz_id.dart';
import 'quiz_bank_validation.dart';

export '../data/bundled_quiz_bank_paths.dart' show kBundledQuizBankAssetPaths;
export 'quiz_bank_validation.dart' show QuizBankFormatException, validateQuizBankContent;

/// Loads and validates per-quiz JSON from [assets/quiz_banks/].
///
/// Call [load] from `main()` before [runApp]. Accessors throw [StateError] if
/// used before a successful [load].
class QuizBankLoader {
  QuizBankLoader._();

  static final QuizBankLoader instance = QuizBankLoader._();

  static const Map<QuizId, String> _assetPaths = kBundledQuizBankAssetPaths;

  Map<QuizId, Quiz>? _byId;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Idempotent. Parses each bank, runs [validateQuizBankContent], caches by [QuizId].
  Future<void> load() async {
    if (_loaded) return;

    final next = <QuizId, Quiz>{};
    for (final entry in _assetPaths.entries) {
      final id = entry.key;
      final path = entry.value;
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw QuizBankFormatException(
          'Quiz "${id.name}" / question "?": expected root object in $path',
        );
      }
      final quiz = Quiz.fromJson(decoded);
      if (quiz.id != id) {
        throw QuizBankFormatException(
          'Quiz "${id.name}" / question "?": JSON "id" is "${quiz.id.name}" but expected "${id.name}" for $path',
        );
      }
      validateQuizBankContent(quiz);
      next[id] = quiz;
    }
    _byId = next;
    _loaded = true;
  }

  Quiz quizFor(QuizId id) {
    final map = _byId;
    if (map == null) {
      throw StateError(
        'QuizBankLoader: load() was not awaited before quizFor(${id.name}).',
      );
    }
    final q = map[id];
    if (q == null) {
      throw StateError('QuizBankLoader: no bank registered for ${id.name}.');
    }
    return q;
  }

  List<Quiz> allQuizzes() {
    final map = _byId;
    if (map == null) {
      throw StateError(
        'QuizBankLoader: load() was not awaited before allQuizzes().',
      );
    }
    return [
      map[QuizId.particleForensics]!,
      map[QuizId.clauseUntangler]!,
      map[QuizId.omissionDetective]!,
      map[QuizId.registerRadar]!,
      map[QuizId.transitivityDuel]!,
      map[QuizId.verbConjugation]!,
    ];
  }

  /// Same as [validateQuizBankContent]; kept for discoverability / tests.
  static void validateQuiz(Quiz quiz) => validateQuizBankContent(quiz);

  /// For tests: inject banks without assets.
  void debugSetQuizzes(Map<QuizId, Quiz> quizzes) {
    _byId = Map<QuizId, Quiz>.from(quizzes);
    _loaded = true;
  }

  /// For tests: reset loader state.
  void debugReset() {
    _byId = null;
    _loaded = false;
  }
}
