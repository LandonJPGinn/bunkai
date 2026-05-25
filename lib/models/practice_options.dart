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

/// Conjugation tags available for focused verb-form practice.
const List<String> kConjugationPracticeTags = <String>[
  'dictionary_form',
  'masu_form',
  'te_form',
  'past_form',
  'nai_form',
  'potential_form',
  'passive_form',
  'causative_form',
  'volitional_form',
  'conditional_ba_form',
  'tara_form',
  'imperative_form',
  'prohibitive_form',
];

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

extension PracticeConjugationTagX on String {
  String get conjugationMenuLabel => switch (this) {
        'dictionary_form' => 'Dictionary form',
        'masu_form' => 'Masu form',
        'te_form' => 'Te form',
        'past_form' => 'Past form',
        'nai_form' => 'Nai form',
        'potential_form' => 'Potential form',
        'passive_form' => 'Passive form',
        'causative_form' => 'Causative form',
        'volitional_form' => 'Volitional form',
        'conditional_ba_form' => 'Conditional -ba form',
        'tara_form' => 'Conditional -tara form',
        'imperative_form' => 'Imperative form',
        'prohibitive_form' => 'Prohibitive form',
        _ => replaceAll('_', ' '),
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

class PracticeQuizAvailableSettings {
  const PracticeQuizAvailableSettings({
    required this.useConjugationFilter,
    this.availableJlptFilters = const <PracticeJlptFilter>[
      PracticeJlptFilter.all,
    ],
    this.availableConjugationTags = const <String>[],
  });

  final bool useConjugationFilter;
  final List<PracticeJlptFilter> availableJlptFilters;
  final List<String> availableConjugationTags;

  bool get showDifficultyControl =>
      !useConjugationFilter &&
      availableJlptFilters.where((f) => f != PracticeJlptFilter.all).length > 1;
}

/// Persisted practice settings for a single quiz.
class PracticeQuizSettings {
  const PracticeQuizSettings({
    this.countPreset = PracticeCountPreset.ten,
    this.jlptFilter = PracticeJlptFilter.all,
    this.conjugationTags = const <String>{},
  });

  final PracticeCountPreset countPreset;
  final PracticeJlptFilter jlptFilter;
  final Set<String> conjugationTags;

  static const PracticeQuizSettings defaults = PracticeQuizSettings();

  PracticeQuizSettings copyWith({
    PracticeCountPreset? countPreset,
    PracticeJlptFilter? jlptFilter,
    Set<String>? conjugationTags,
  }) {
    return PracticeQuizSettings(
      countPreset: countPreset ?? this.countPreset,
      jlptFilter: jlptFilter ?? this.jlptFilter,
      conjugationTags: conjugationTags ?? this.conjugationTags,
    );
  }

  String get countLabel => switch (countPreset) {
        PracticeCountPreset.ten => '10',
        PracticeCountPreset.twenty => '20',
        PracticeCountPreset.fifty => '50',
        PracticeCountPreset.all => 'All',
      };

  String get summaryLabel {
    if (conjugationTags.isNotEmpty) {
      return 'Forms';
    }
    return jlptFilter.menuLabel;
  }

  Map<String, String> toStorageMap() {
    return <String, String>{
      'countPreset': countPreset.name,
      'jlptFilter': jlptFilter.name,
      if (conjugationTags.isNotEmpty)
        'conjugationTags': (conjugationTags.toList()..sort()).join(','),
    };
  }

  static PracticeQuizSettings fromStorageMap(Map<String, Object?> value) {
    return PracticeQuizSettings(
      countPreset: _parseCount(value['countPreset']),
      jlptFilter: _parseJlpt(value['jlptFilter']),
      conjugationTags: _parseConjugationTags(value['conjugationTags']),
    );
  }

  PracticeQuizSettings sanitizedFor(PracticeQuizAvailableSettings available) {
    if (available.useConjugationFilter) {
      final allowed = available.availableConjugationTags.toSet();
      final selected = conjugationTags.where(allowed.contains).toSet();
      return copyWith(
        conjugationTags: selected.isEmpty ? allowed : selected,
      );
    }

    final allowedFilters = available.availableJlptFilters.toSet();
    final fallback =
        allowedFilters.contains(PracticeJlptFilter.all)
            ? PracticeJlptFilter.all
            : available.availableJlptFilters.first;
    return copyWith(
      jlptFilter: allowedFilters.contains(jlptFilter) ? jlptFilter : fallback,
      conjugationTags: const <String>{},
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

  static Set<String> _parseConjugationTags(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toSet();
    }
    if (value is List) {
      return {
        for (final tag in value)
          if (tag is String && tag.isNotEmpty) tag,
      };
    }
    return const <String>{};
  }
}
