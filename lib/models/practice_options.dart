/// User-selected practice session options (in-memory only).
enum PracticeCountPreset {
  ten,
  twenty,
  fifty,
  all,
}

/// JLPT band filter; [all] uses every question (subject to untagged rules in builder).
enum PracticeJlptFilter {
  all,
  n4,
  n4N3,
  n3,
  n3N2,
  n2,
}

extension PracticeJlptFilterX on PracticeJlptFilter {
  /// Band string for [QuizQuestion.jlptLevel] / [Quiz.difficulty], or null when [all].
  String? get bandString => switch (this) {
        PracticeJlptFilter.all => null,
        PracticeJlptFilter.n4 => 'N4',
        PracticeJlptFilter.n4N3 => 'N4-N3',
        PracticeJlptFilter.n3 => 'N3',
        PracticeJlptFilter.n3N2 => 'N3-N2',
        PracticeJlptFilter.n2 => 'N2',
      };

  String get menuLabel => switch (this) {
        PracticeJlptFilter.all => 'All',
        PracticeJlptFilter.n4 => 'N4',
        PracticeJlptFilter.n4N3 => 'N4–N3',
        PracticeJlptFilter.n3 => 'N3',
        PracticeJlptFilter.n3N2 => 'N3–N2',
        PracticeJlptFilter.n2 => 'N2',
      };
}

enum PracticeOrderMode {
  ordered,
  random,
}

extension PracticeCountPresetX on PracticeCountPreset {
  /// Max questions, or null when [PracticeCountPreset.all].
  int? get maxCount => switch (this) {
        PracticeCountPreset.ten => 10,
        PracticeCountPreset.twenty => 20,
        PracticeCountPreset.fifty => 50,
        PracticeCountPreset.all => null,
      };
}
