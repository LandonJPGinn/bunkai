import 'conjugation_rules.dart';

/// Verb/adjective class matching JSON top-level keys.
enum ConjugationGroup {
  godan('godan'),
  ichidan('ichidan'),
  iku('iku'),
  kuru('kuru'),
  suru('suru'),
  aru('aru'),
  iru('iru'),
  iAdjective('i-adjective'),
  ii('ii'),
  naAdjective('na-adjective');

  const ConjugationGroup(this.jsonKey);
  final String jsonKey;
}

/// Applies [ConjugationRules] to a lemma surface form.
class ConjugationEngine {
  ConjugationEngine(this._rules);

  final ConjugationRules _rules;

  /// All accepted surface strings for [lemma] under [group] and [categoryKey].
  /// When multiple `before` entries match the same suffix, each yields an answer.
  /// [variantIndex] narrows to one variant when the caller needs a single canonical form.
  List<String> conjugationsFor(
    String lemma,
    ConjugationGroup group,
    String categoryKey, {
    int variantIndex = 0,
  }) {
    final cat = _rules.group(group.jsonKey)?[categoryKey];
    if (cat == null) {
      throw ArgumentError('Unknown category $categoryKey for ${group.jsonKey}');
    }
    final forms = cat.forms;
    if (forms.isEmpty) return const [];

    // Result-only irregular rows (iku / kuru / aru / ii …).
    if (forms.every((f) => f.isResultOnly)) {
      return [for (final f in forms) f.result!];
    }

    final matches = <String>[];
    for (final f in forms) {
      if (f.before != null &&
          f.after != null &&
          lemma.endsWith(f.before!)) {
        matches.add(
          lemma.substring(0, lemma.length - f.before!.length) + f.after!,
        );
      }
    }
    if (matches.isEmpty) {
      throw ArgumentError(
        'No rule matched lemma "$lemma" for ${group.jsonKey}/$categoryKey',
      );
    }
    return matches;
  }

  /// Single surface string; uses [variantIndex] modulo number of matches.
  String conjugate(
    String lemma,
    ConjugationGroup group,
    String categoryKey, {
    int variantIndex = 0,
  }) {
    final all = conjugationsFor(lemma, group, categoryKey);
    if (all.isEmpty) return '';
    return all[variantIndex % all.length];
  }
}
