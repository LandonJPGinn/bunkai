import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/bundled_quiz_bank_paths.dart';
import '../models/quiz.dart';
import '../models/quiz_type.dart';
import '../models/quiz_summary.dart';
import 'quiz_bank_validation.dart';

export '../data/bundled_quiz_bank_paths.dart' show kBundledQuizBankAssetPaths;
export 'quiz_bank_validation.dart'
    show QuizBankFormatException, validateQuizBankContent;

/// Loads quiz banks from assets on demand and validates each parsed bank.
///
/// PERF: Call [ensureCatalogLoaded] for home metadata only; full question JSON
/// loads only via [ensureQuizLoaded]. Do not block `runApp` on full banks.
class QuizBankLoader {
  QuizBankLoader._();

  static final QuizBankLoader instance = QuizBankLoader._();

  static const Map<String, String> _assetPaths = kBundledQuizBankAssetPaths;

  /// Generated catalog — metadata only, small JSON for fast first paint.
  static const String _catalogAssetPath = 'assets/quiz_banks/quiz_catalog.json';
  static const String _compiledCatalogAssetPath =
      'assets/compiled/quiz_catalog.json';
  static const String _remoteCatalogPath = '/api/quiz-catalog';
  static const bool _remoteApiEnabled = bool.fromEnvironment(
    'JPQUIZAPP_REMOTE_API',
    defaultValue: kReleaseMode,
  );

  List<QuizSummary>? _catalog;
  final Map<String, Quiz> _quizzes = {};
  final Map<String, Future<Quiz>> _quizLoadsInFlight = {};

  bool _catalogLoaded = false;

  bool get isCatalogLoaded => _catalogLoaded;

  bool isQuizLoaded(String id) => _quizzes.containsKey(id);

  /// Idempotent. Parses [quiz_catalog.json] only.
  Future<void> ensureCatalogLoaded() async {
    if (_catalogLoaded) return;

    final raw = await _loadCatalogString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Quiz catalog: expected root object');
    }
    final list = decoded['quizzes'];
    if (list is! List) {
      throw const FormatException('Quiz catalog: expected "quizzes" array');
    }

    _catalog = [
      for (final item in list)
        QuizSummary.fromCatalogJson(Map<String, dynamic>.from(item as Map)),
    ];
    _catalogLoaded = true;
  }

  /// Throws if [ensureCatalogLoaded] has not completed successfully.
  List<QuizSummary> get catalogSummaries {
    final list = _catalog;
    if (list == null) {
      throw StateError(
        'QuizBankLoader: catalog not loaded; await ensureCatalogLoaded() first.',
      );
    }
    return List<QuizSummary>.unmodifiable(list);
  }

  /// Loads one bank JSON if missing from cache; validates; caches by quiz id.
  Future<Quiz> ensureQuizLoaded(String id) async {
    final cached = _quizzes[id];
    if (cached != null) return cached;

    _quizLoadsInFlight[id] ??= _parseAndCacheQuiz(id);
    try {
      return await _quizLoadsInFlight[id]!;
    } finally {
      _quizLoadsInFlight.remove(id);
    }
  }

  Future<Quiz> _parseAndCacheQuiz(String id) async {
    if (kIsWeb && _remoteApiEnabled) {
      try {
        final quiz = _parseQuizString(
          id,
          await _loadRemoteString('/api/quizzes/${Uri.encodeComponent(id)}'),
        );
        _quizzes[id] = quiz;
        return quiz;
      } catch (error) {
        debugPrint(
          'QuizBankLoader: remote quiz "$id" failed; using assets. $error',
        );
      }
    }

    final raw = await _loadBundledQuizString(id);
    final quiz = _parseQuizString(id, raw);
    _quizzes[id] = quiz;
    return quiz;
  }

  Quiz _parseQuizString(String id, String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw QuizBankFormatException(
        'Quiz "$id" / question "?": expected root object',
      );
    }
    final parsedQuiz = Quiz.fromJson(decoded);
    final quiz = Quiz(
      id: parsedQuiz.id,
      title: parsedQuiz.title,
      subtitle: parsedQuiz.subtitle,
      description: parsedQuiz.description,
      difficulty: parsedQuiz.difficulty,
      diagnosticTags: parsedQuiz.diagnosticTags,
      questions: [
        for (final q in parsedQuiz.questions)
          q.copyWith(type: QuizType.textInput),
      ],
    );
    if (quiz.id != id) {
      throw QuizBankFormatException(
        'Quiz "$id" / question "?": JSON "id" is "${quiz.id}" but expected "$id"',
      );
    }
    validateQuizBankContent(quiz);
    return quiz;
  }

  Future<String> _loadCatalogString() async {
    if (kIsWeb && _remoteApiEnabled) {
      try {
        return await _loadRemoteString(_remoteCatalogPath);
      } catch (_) {
        // Bundled assets are the offline/dev fallback when Pages Functions are
        // unavailable.
      }
    }
    return _loadAssetStringWithFallback(
      preferred: _compiledCatalogAssetPath,
      fallback: _catalogAssetPath,
    );
  }

  Future<String> _loadBundledQuizString(String id) {
    final path = _assetPaths[id];
    if (path == null) {
      throw StateError(
        'QuizBankLoader: no remote quiz or bundled asset for $id.',
      );
    }
    return _loadAssetStringWithFallback(
      preferred: 'assets/compiled/quiz_banks/$id.json',
      fallback: path,
    );
  }

  Future<String> _loadRemoteString(String path) {
    return NetworkAssetBundle(Uri.base).loadString(path);
  }

  Future<String> _loadAssetStringWithFallback({
    required String preferred,
    required String fallback,
  }) async {
    try {
      return await rootBundle.loadString(preferred);
    } catch (_) {
      return rootBundle.loadString(fallback);
    }
  }

  /// Requires [ensureQuizLoaded] (or [loadAllForTests]) for this [id] first.
  Quiz quizFor(String id) {
    final q = _quizzes[id];
    if (q == null) {
      throw StateError(
        'QuizBankLoader: quiz $id not loaded. '
        'Await ensureQuizLoaded($id) or loadAllForTests().',
      );
    }
    return q;
  }

  /// Fixed pack order from [kBundledQuizBankAssetPaths].
  List<Quiz> allQuizzes() {
    final ordered = <Quiz>[];
    for (final id in _assetPaths.keys) {
      try {
        ordered.add(quizFor(id));
      } on StateError {
        throw StateError(
          'QuizBankLoader: allQuizzes() requires every bank loaded '
          '(use loadAllForTests). Missing $id.',
        );
      }
    }
    return ordered;
  }

  /// Loads catalog plus every bank — tests and tooling only.
  Future<void> loadAllForTests() async {
    await ensureCatalogLoaded();
    for (final id in _assetPaths.keys) {
      await ensureQuizLoaded(id);
    }
  }

  /// Same as [validateQuizBankContent]; kept for discoverability / tests.
  static void validateQuiz(Quiz quiz) => validateQuizBankContent(quiz);

  /// For tests: inject banks without assets.
  void debugSetQuizzes(Map<String, Quiz> quizzes) {
    _quizzes
      ..clear()
      ..addAll(quizzes);
    _catalogLoaded = true;
    _catalog = [
      for (final id in kBundledQuizBankAssetPaths.keys)
        if (quizzes[id] != null) _summaryFromQuiz(quizzes[id]!),
      for (final entry in quizzes.entries)
        if (!kBundledQuizBankAssetPaths.containsKey(entry.key))
          _summaryFromQuiz(entry.value),
    ];
  }

  static QuizSummary _summaryFromQuiz(Quiz q) => QuizSummary(
    id: q.id,
    title: q.title,
    subtitle: q.subtitle,
    description: q.description,
    difficulty: q.difficulty,
    diagnosticTags: q.diagnosticTags,
  );

  /// For tests: reset loader state.
  void debugReset() {
    _catalog = null;
    _catalogLoaded = false;
    _quizzes.clear();
    _quizLoadsInFlight.clear();
  }
}
