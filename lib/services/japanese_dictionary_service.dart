import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dictionary_entry.dart';
import 'japanese_tokenizer.dart';

/// Loads and caches `assets/dictionary/japanese_lexicon.json`.
///
/// Call [load] from `main()` before UI uses lookups. Pattern matches
/// [QuizBankLoader].
class JapaneseDictionaryService {
  JapaneseDictionaryService._();

  static final JapaneseDictionaryService instance = JapaneseDictionaryService._();

  static const String _assetPath = 'assets/dictionary/japanese_lexicon.json';

  Map<String, List<DictionaryEntry>>? _bySurface;
  JapaneseTokenizer? _tokenizer;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Idempotent. Parses JSON array, groups homonyms by surface.
  Future<void> load() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException(
        'JapaneseDictionaryService: expected JSON array in asset',
      );
    }

    final next = <String, List<DictionaryEntry>>{};
    for (final item in decoded) {
      if (item is! Map) {
        throw const FormatException(
          'JapaneseDictionaryService: each entry must be an object',
        );
      }
      final entry = DictionaryEntry.fromJson(
        Map<String, dynamic>.from(item),
      );
      next.putIfAbsent(entry.surface, () => []).add(entry);
    }

    _bySurface = next;
    _tokenizer = JapaneseTokenizer.fromSurfaces(next.keys);
    _loaded = true;
  }

  /// Longest-match tokenizer over loaded surfaces; throws if not [isLoaded].
  JapaneseTokenizer get tokenizer {
    final t = _tokenizer;
    if (t == null) {
      throw StateError(
        'JapaneseDictionaryService.load() was not awaited before tokenizer.',
      );
    }
    return t;
  }

  Map<String, List<DictionaryEntry>> get _map {
    final m = _bySurface;
    if (m == null) {
      throw StateError(
        'JapaneseDictionaryService.load() was not awaited before use.',
      );
    }
    return m;
  }

  /// All dictionary rows for this exact surface (homonyms), or empty if none.
  List<DictionaryEntry> lookupSurface(String surface) =>
      List<DictionaryEntry>.from(_map[surface] ?? const []);

  /// For each surface string, the list of entries (empty if unknown).
  Map<String, List<DictionaryEntry>> lookupMany(List<String> surfaces) {
    final m = _map;
    return {
      for (final s in surfaces) s: List<DictionaryEntry>.from(m[s] ?? const []),
    };
  }

  bool containsSurface(String surface) => _map.containsKey(surface);

  /// All distinct dictionary surfaces (for tokenizer longest-match).
  Set<String> get surfaceKeys => _map.keys.toSet();
}
