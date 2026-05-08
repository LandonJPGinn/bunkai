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

extension PracticeCountPresetX on PracticeCountPreset {
  /// Max questions, or null when [PracticeCountPreset.all].
  int? get maxCount => switch (this) {
        PracticeCountPreset.ten => 10,
        PracticeCountPreset.twenty => 20,
        PracticeCountPreset.fifty => 50,
        PracticeCountPreset.all => null,
      };
}

/// Persisted practice settings for a single quiz.
class PracticeQuizSettings {
  const PracticeQuizSettings({
    this.countPreset = PracticeCountPreset.ten,
    this.jlptFilter = PracticeJlptFilter.all,
  });

  final PracticeCountPreset countPreset;
  final PracticeJlptFilter jlptFilter;

  static const PracticeQuizSettings defaults = PracticeQuizSettings();

  PracticeQuizSettings copyWith({
    PracticeCountPreset? countPreset,
    PracticeJlptFilter? jlptFilter,
  }) {
    return PracticeQuizSettings(
      countPreset: countPreset ?? this.countPreset,
      jlptFilter: jlptFilter ?? this.jlptFilter,
    );
  }

  String get countLabel => switch (countPreset) {
        PracticeCountPreset.ten => '10',
        PracticeCountPreset.twenty => '20',
        PracticeCountPreset.fifty => '50',
        PracticeCountPreset.all => 'All',
      };

  Map<String, String> toStorageMap() {
    return <String, String>{
      'countPreset': countPreset.name,
      'jlptFilter': jlptFilter.name,
    };
  }

  static PracticeQuizSettings fromStorageMap(Map<String, Object?> value) {
    return PracticeQuizSettings(
      countPreset: _parseCount(value['countPreset']),
      jlptFilter: _parseJlpt(value['jlptFilter']),
    );
  }

  static PracticeCountPreset _parseCount(Object? value) {
    if (value is String) {
      for (final preset in PracticeCountPreset.values) {
        if (preset.name == value) return preset;
      }
    }
    return PracticeCountPreset.ten;
  }

  static PracticeJlptFilter _parseJlpt(Object? value) {
    if (value is String) {
      for (final filter in PracticeJlptFilter.values) {
        if (filter.name == value) return filter;
      }
    }
    return PracticeJlptFilter.all;
  }
}
