import '../models/quiz_id.dart';

/// Asset paths for each bundled bank JSON under [assets/quiz_banks/].
/// Single source of truth for [QuizBankLoader] and contract tests.
const Map<QuizId, String> kBundledQuizBankAssetPaths = {
  QuizId.particleForensics: 'assets/quiz_banks/particle_forensics.json',
  QuizId.clauseUntangler: 'assets/quiz_banks/clause_untangler.json',
  QuizId.omissionDetective: 'assets/quiz_banks/omission_detective.json',
  QuizId.registerRadar: 'assets/quiz_banks/register_radar.json',
  QuizId.transitivityDuel: 'assets/quiz_banks/transitivity_duel.json',
  QuizId.verbConjugation: 'assets/quiz_banks/verb_conjugation.json',
};
