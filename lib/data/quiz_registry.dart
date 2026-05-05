// Bundled quiz packs and lookups.
//
// PERF: Home grid uses catalog summaries ([quizSummariesForHome]); full banks load
// on demand via [QuizBankLoader.ensureQuizLoaded] when starting or retrying a quiz.

import '../models/quiz.dart';
import '../models/quiz_pack.dart';
import '../models/quiz_summary.dart';
import '../services/quiz_bank_loader.dart';

QuizPack coreBunkaiPack() {
  final loader = QuizBankLoader.instance;
  return QuizPack(
    id: 'core_bunkai',
    title: 'Core BunKai Pack',
    author: 'BunKai',
    description: 'The original six diagnostic quizzes shipped with BunKai.',
    quizzes: loader.allQuizzes(),
  );
}

List<QuizPack> allQuizPacks() => [coreBunkaiPack()];

/// Metadata rows for [HomeScreen] — awaits catalog asset only (small JSON).
Future<List<QuizSummary>> quizSummariesForHome() async {
  await QuizBankLoader.instance.ensureCatalogLoaded();
  return QuizBankLoader.instance.catalogSummaries;
}
