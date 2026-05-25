// Writes assets/data/conjugation_rules.json from [rules_map_builder].
// Run from repo root: dart run tool/export_conjugation_rules.dart

import 'dart:convert';
import 'dart:io';

import 'package:jpquizapp/services/conjugation/rules_map_builder.dart';

void main() {
  final dir = Directory('assets/data');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  const encoder = JsonEncoder.withIndent('  ');
  final json = encoder.convert(buildConjugationRulesMap());
  File('assets/data/conjugation_rules.json').writeAsStringSync(json);
  // ignore: avoid_print
  print('Wrote assets/data/conjugation_rules.json (${json.length} chars).');
}
