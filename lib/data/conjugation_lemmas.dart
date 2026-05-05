import '../services/conjugation/conjugation_engine.dart';

/// Lemma inventory with explicit conjugation class (cannot be inferred from spelling).
class ConjugationLemma {
  const ConjugationLemma({
    required this.surface,
    required this.group,
  });

  final String surface;
  final ConjugationGroup group;
}

/// Curated lemmas covering each conjugation group in the rule JSON.
const List<ConjugationLemma> kConjugationLemmas = [
  // Godan
  ConjugationLemma(surface: '書く', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '話す', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '読む', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '帰る', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '泳ぐ', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '死ぬ', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '飛ぶ', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '買う', group: ConjugationGroup.godan),
  ConjugationLemma(surface: '待つ', group: ConjugationGroup.godan),
  // Ichidan
  ConjugationLemma(surface: '食べる', group: ConjugationGroup.ichidan),
  ConjugationLemma(surface: '見る', group: ConjugationGroup.ichidan),
  ConjugationLemma(surface: '起きる', group: ConjugationGroup.ichidan),
  ConjugationLemma(surface: '寝る', group: ConjugationGroup.ichidan),
  // Irregulars
  ConjugationLemma(surface: '行く', group: ConjugationGroup.iku),
  ConjugationLemma(surface: '来る', group: ConjugationGroup.kuru),
  ConjugationLemma(surface: 'する', group: ConjugationGroup.suru),
  ConjugationLemma(surface: '勉強する', group: ConjugationGroup.suru),
  ConjugationLemma(surface: 'ある', group: ConjugationGroup.aru),
  ConjugationLemma(surface: 'いる', group: ConjugationGroup.iru),
  // Adjectives
  ConjugationLemma(surface: '寒い', group: ConjugationGroup.iAdjective),
  ConjugationLemma(surface: '高い', group: ConjugationGroup.iAdjective),
  ConjugationLemma(surface: 'いい', group: ConjugationGroup.ii),
  ConjugationLemma(surface: '静かだ', group: ConjugationGroup.naAdjective),
];
