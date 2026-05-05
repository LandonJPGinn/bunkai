// Parsed conjugation rule JSON (godan / ichidan / irregular / adjectives).

class ConjugationFormRule {
  const ConjugationFormRule({
    this.before,
    this.after,
    this.result,
  });

  final String? before;
  final String? after;
  final String? result;

  bool get isResultOnly => result != null;
}

class ConjugationCategoryRules {
  const ConjugationCategoryRules({
    required this.forms,
    this.tetakei,
  });

  final List<ConjugationFormRule> forms;
  final bool? tetakei;
}

/// Full rule book keyed by verb/adjective class then category name (e.g. `negative`).
class ConjugationRules {
  ConjugationRules._(this._byGroup);

  final Map<String, Map<String, ConjugationCategoryRules>> _byGroup;

  factory ConjugationRules.fromJson(Map<String, dynamic> json) {
    final byGroup = <String, Map<String, ConjugationCategoryRules>>{};
    for (final groupEntry in json.entries) {
      final groupKey = groupEntry.key;
      final groupVal = groupEntry.value;
      if (groupVal is! Map<String, dynamic>) continue;
      final categories = <String, ConjugationCategoryRules>{};
      for (final catEntry in groupVal.entries) {
        final catVal = catEntry.value;
        if (catVal is! Map<String, dynamic>) continue;
        final formsRaw = catVal['forms'];
        if (formsRaw is! List) continue;
        final tetakei = catVal['tetakei'] as bool?;
        final forms = <ConjugationFormRule>[
          for (final raw in formsRaw)
            if (raw is Map<String, dynamic>) _parseForm(raw),
        ];
        categories[catEntry.key] = ConjugationCategoryRules(
          forms: forms,
          tetakei: tetakei,
        );
      }
      byGroup[groupKey] = categories;
    }
    return ConjugationRules._(byGroup);
  }

  static ConjugationFormRule _parseForm(Map<String, dynamic> raw) {
    final before = raw['before'] as String?;
    final after = raw['after'] as String?;
    final result = raw['result'] as String?;
    if (result != null && before == null && after == null) {
      return ConjugationFormRule(result: result);
    }
    if (before != null && after != null && result == null) {
      return ConjugationFormRule(before: before, after: after);
    }
    throw FormatException('Invalid conjugation form rule: $raw');
  }

  Map<String, ConjugationCategoryRules>? group(String name) => _byGroup[name];

  Iterable<String> groupKeys() => _byGroup.keys;

  List<String> categoryKeysFor(String groupName) {
    final g = _byGroup[groupName];
    if (g == null) return const [];
    return g.keys.toList()..sort();
  }

  bool hasCategory(String groupName, String categoryKey) =>
      _byGroup[groupName]?.containsKey(categoryKey) ?? false;
}
