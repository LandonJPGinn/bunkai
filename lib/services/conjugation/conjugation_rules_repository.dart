import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'conjugation_rules.dart';
import 'rules_map_builder.dart';

/// Loads [ConjugationRules] from the bundled asset, with in-memory fallback.
class ConjugationRulesRepository {
  ConjugationRulesRepository._();

  static final ConjugationRulesRepository instance = ConjugationRulesRepository._();

  ConjugationRules? _rules;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  ConjugationRules get rules {
    final r = _rules;
    if (r == null) {
      throw StateError(
        'ConjugationRulesRepository: load() was not awaited before access.',
      );
    }
    return r;
  }

  /// Idempotent. Prefer awaiting from `main()` before `runApp`.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/data/conjugation_rules.json');
      _rules = ConjugationRules.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e, st) {
      debugPrint('ConjugationRulesRepository: asset load failed ($e); using builtin.');
      debugPrint('$st');
      _rules = ConjugationRules.fromJson(buildConjugationRulesMap());
    }
    _loaded = true;
  }

  /// For tests: inject rules without assets.
  void debugSetRules(ConjugationRules rules) {
    _rules = rules;
    _loaded = true;
  }
}
