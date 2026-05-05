import 'package:bunkai/services/conjugation/conjugation_engine.dart';
import 'package:bunkai/services/conjugation/conjugation_rules.dart';
import 'package:bunkai/services/conjugation/rules_map_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConjugationRules rules;
  late ConjugationEngine engine;

  setUp(() {
    rules = ConjugationRules.fromJson(buildConjugationRulesMap());
    engine = ConjugationEngine(rules);
  });

  group('ConjugationEngine', () {
    test('ichidan negative', () {
      expect(
        engine.conjugate('食べる', ConjugationGroup.ichidan, 'negative'),
        '食べない',
      );
    });

    test('godan te-form (く)', () {
      expect(
        engine.conjugate('書く', ConjugationGroup.godan, 'te-form'),
        '書いて',
      );
    });

    test('godan past (む)', () {
      expect(
        engine.conjugate('読む', ConjugationGroup.godan, 'past'),
        '読んだ',
      );
    });

    test('suru polite past', () {
      expect(
        engine.conjugate('する', ConjugationGroup.suru, 'polite past'),
        'しました',
      );
    });

    test('compound suru stem', () {
      expect(
        engine.conjugate('勉強する', ConjugationGroup.suru, 'negative'),
        '勉強しない',
      );
    });

    test('iku polite uses fixed result string', () {
      expect(
        engine.conjugate('行く', ConjugationGroup.iku, 'polite'),
        '行[い]きます',
      );
    });

    test('i-adjective negative', () {
      expect(
        engine.conjugate('寒い', ConjugationGroup.iAdjective, 'negative'),
        '寒くない',
      );
    });

    test('ii polite', () {
      expect(
        engine.conjugate('いい', ConjugationGroup.ii, 'polite'),
        'いいです',
      );
    });

    test('na-adjective polite past', () {
      expect(
        engine.conjugate('静かだ', ConjugationGroup.naAdjective, 'polite past'),
        '静かでした',
      );
    });

    test('ichidan potential lists both colloquial and standard', () {
      final both = engine.conjugationsFor(
        '食べる',
        ConjugationGroup.ichidan,
        'potential',
      );
      expect(both, containsAll(['食べられる', '食べれる']));
    });
  });
}
