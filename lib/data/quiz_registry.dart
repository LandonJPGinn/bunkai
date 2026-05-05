// Bundled quiz packs and lookups.
//
// Question banks live in assets/quiz_banks/*.json, loaded by [QuizBankLoader]
// before [runApp] (see lib/main.dart).

import '../models/quiz.dart';
import '../models/quiz_id.dart';
import '../models/quiz_pack.dart';
import '../services/quiz_bank_loader.dart';

QuizPack coreBunkaiPack() {
  final loader = QuizBankLoader.instance;
  return QuizPack(
    id: 'core_bunkai',
    title: 'Core BunKai Pack',
    author: 'BunKai',
    description: 'The original six diagnostic quizzes shipped with BunKai.',
    quizzes: [
      loader.quizFor(QuizId.particleForensics),
      loader.quizFor(QuizId.clauseUntangler),
      loader.quizFor(QuizId.omissionDetective),
      loader.quizFor(QuizId.registerRadar),
      loader.quizFor(QuizId.transitivityDuel),
      loader.quizFor(QuizId.verbConjugation),
    ],
  );
}

List<QuizPack> allQuizPacks() => [coreBunkaiPack()];

List<Quiz> allQuizzes() => [
      for (final pack in allQuizPacks()) ...pack.quizzes,
    ];

Quiz? quizById(QuizId id) {
  for (final q in allQuizzes()) {
    if (q.id == id) return q;
  }
  return null;
}
