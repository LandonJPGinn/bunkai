import 'dart:math';

import '../../data/conjugation_lemmas.dart';
import '../../models/answer_choice.dart';
import '../../models/quiz_question.dart';
import '../../models/quiz_type.dart';
import 'conjugation_engine.dart';
import 'conjugation_rules.dart';

/// Builds typed-input conjugation questions from rules + lemmas.
class ConjugationQuizBuilder {
  ConjugationQuizBuilder({
    required ConjugationRules rules,
    required List<ConjugationLemma> lemmas,
    required int seed,
  })  : _engine = ConjugationEngine(rules),
        _rules = rules,
        _lemmas = List<ConjugationLemma>.from(lemmas),
        _random = Random(seed);

  final ConjugationEngine _engine;
  final ConjugationRules _rules;
  final List<ConjugationLemma> _lemmas;
  final Random _random;

  static const choiceIds = ['a', 'b', 'c', 'd'];

  List<QuizQuestion> build({int questionCount = 22}) {
    final out = <QuizQuestion>[];
    var guard = 0;
    while (out.length < questionCount && guard < questionCount * 40) {
      guard++;
      final lemma = _lemmas[_random.nextInt(_lemmas.length)];
      final categories = _rules.categoryKeysFor(lemma.group.jsonKey);
      if (categories.isEmpty) continue;
      final categoryKey = categories[_random.nextInt(categories.length)];
      final variants = _engine.conjugationsFor(
        lemma.surface,
        lemma.group,
        categoryKey,
      );
      if (variants.isEmpty) continue;
      final variantIndex = _random.nextInt(variants.length);
      final correct = variants[variantIndex % variants.length];
      final distractors = _collectDistractors(
        lemma: lemma,
        categoryKey: categoryKey,
        correct: correct,
      );
      final uniqueWrong = distractors.where((d) => d != correct).toList()
        ..shuffle(_random);
      final picked = <String>[];
      for (final d in uniqueWrong) {
        if (picked.length >= 3) break;
        if (!picked.contains(d)) picked.add(d);
      }
      if (picked.length < 3) continue;

      final labels = <String>[correct, ...picked];
      labels.shuffle(_random);
      final correctIndex = labels.indexOf(correct);
      final engCat = _englishCategoryLabel(categoryKey);
      final jpHint = _japaneseCategoryHint(categoryKey);
      final choices = [
        for (var i = 0; i < 4; i++)
          AnswerChoice(id: choiceIds[i], label: labels[i], labelEn: labels[i]),
      ];

      final id =
          'verbConjugation_gen_${out.length}_${Object.hash(lemma.surface, categoryKey, variantIndex)}';

      out.add(
        QuizQuestion(
          id: id,
          type: QuizType.textInput,
          prompt: '${lemma.surface} → Convert to / produce: $engCat.',
          japanese: '「${lemma.surface}」→ $jpHint',
          promptEn: '${lemma.surface} → Convert to / produce: $engCat.',
          japaneseEn:
              '\'${lemma.surface}\' → $engCat (hint: $jpHint)',
          acceptedAnswers: [correct],
          choices: choices,
          correctAnswerId: choiceIds[correctIndex],
          explanation:
              '「${lemma.surface}」の$jpHint として適切な形は「$correct」。',
          explanationEn:
              'For \'${lemma.surface}\', the right surface for '
              '$engCat is \'$correct\'.',
          diagnosticTags: _tagsForCategory(categoryKey),
        ),
      );
    }
    return out;
  }

  List<String> _collectDistractors({
    required ConjugationLemma lemma,
    required String categoryKey,
    required String correct,
  }) {
    final pool = <String>{};
    final otherCategories = _rules
        .categoryKeysFor(lemma.group.jsonKey)
        .where((c) => c != categoryKey)
        .toList()
      ..shuffle(_random);

    for (final cat in otherCategories) {
      if (pool.length >= 8) break;
      try {
        final v = _engine.conjugate(
          lemma.surface,
          lemma.group,
          cat,
          variantIndex: _random.nextInt(99),
        );
        if (v.isNotEmpty && v != correct) pool.add(v);
      } catch (_) {}
    }

    final others = List<ConjugationLemma>.from(_lemmas)
      ..shuffle(_random);
    for (final other in others) {
      if (pool.length >= 8) break;
      if (other.surface == lemma.surface && other.group == lemma.group) continue;
      try {
        final v = _engine.conjugate(
          other.surface,
          other.group,
          categoryKey,
          variantIndex: _random.nextInt(99),
        );
        if (v.isNotEmpty && v != correct) pool.add(v);
      } catch (_) {}
    }

    final list = pool.where((s) => s != correct).toList()..shuffle(_random);
    return list;
  }

  List<String> _tagsForCategory(String categoryKey) {
    final tags = <String>{'verb_conjugation'};
    if (categoryKey.contains('potential')) {
      tags.add('potential_form');
    } else if (categoryKey.contains('te-form')) {
      tags.add('te_form');
    } else if (categoryKey.contains('polite')) {
      tags.add('masu_form');
    } else if (categoryKey.contains('negative')) {
      tags.add('nai_form');
    } else if (categoryKey.contains('past')) {
      tags.add('past_form');
    }
    return tags.toList();
  }
}

String _englishCategoryLabel(String key) {
  const map = {
    'negative': 'negative plain (non-past)',
    'polite': 'polite non-past (ます)',
    'polite negative': 'polite negative non-past',
    'past': 'plain past (た形)',
    'past negative': 'plain past negative',
    'polite past': 'polite past',
    'polite past negative': 'polite past negative',
    'te-form': 'te-form',
    'te-form negative': 'te-form negative',
    'conditional': 'conditional (たら)',
    'conditional negative': 'conditional negative',
    'provisional': 'provisional (ば)',
    'provisional negative': 'provisional negative',
    'potential': 'potential plain',
    'potential negative': 'potential negative',
    'polite potential': 'polite potential',
    'polite potential negative': 'polite potential negative',
    'imperative': 'imperative',
    'imperative negative': 'imperative negative',
    'passive': 'passive plain',
    'passive negative': 'passive negative',
    'passive past': 'passive past',
    'passive past negative': 'passive past negative',
    'passive te-form': 'passive te-form',
    'polite passive': 'polite passive',
    'polite passive negative': 'polite passive negative',
    'polite passive past': 'polite passive past',
    'polite passive past negative': 'polite passive past negative',
    'causative': 'causative',
    'causative negative': 'causative negative',
    'causative past': 'causative past',
    'causative past negative': 'causative past negative',
    'causative passive': 'causative passive',
    'causative passive negative': 'causative passive negative',
    'causative passive past': 'causative passive past',
    'causative passive past negative': 'causative passive past negative',
    'progressive': 'progressive (〜ている)',
    'progressive negative': 'progressive negative',
    'polite progressive': 'polite progressive',
    'polite progressive negative': 'polite progressive negative',
    'progressive past': 'progressive past',
    'progressive past negative': 'progressive past negative',
    'polite progressive past': 'polite progressive past',
    'polite progressive past negative': 'polite progressive past negative',
    'desire': 'desire (たい)',
    'desire negative': 'desire negative',
    'desire past': 'desire past',
    'desire past negative': 'desire past negative',
    'desire te-form': 'desire te-form',
    'desire te-form negative': 'desire te-form negative',
    'desire polite': 'desire polite',
    'desire polite negative': 'desire polite negative',
    'desire polite past': 'desire polite past',
    'desire polite past negative': 'desire polite past negative',
    'volitional': 'volitional',
    'polite volitional': 'polite volitional',
  };
  return map[key] ?? key;
}

String _japaneseCategoryHint(String key) {
  const map = {
    'negative': 'ない形（普通体・非過去）',
    'polite': '丁寧の非過去（ます）',
    'polite negative': '丁寧の否定（非過去）',
    'past': 'た形（普通体・過去）',
    'past negative': '過去の否定（普通体）',
    'polite past': '丁寧の過去',
    'polite past negative': '丁寧の過去・否定',
    'te-form': 'て形',
    'te-form negative': 'ないで／なくて',
    'potential': '可能の普通体',
    'volitional': '意志形',
    'polite volitional': '丁寧の意志（ましょう）',
  };
  return map[key] ?? _englishCategoryLabel(key);
}
