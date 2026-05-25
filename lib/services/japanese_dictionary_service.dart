import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dictionary_entry.dart';
import 'japanese_tokenizer.dart';

/// Loads and caches the compiled dictionary lexicon asset.
///
/// PERF: Do not await in `main()` — call [ensureLoaded] from widgets or idle
/// preload so first paint is not blocked by lexicon JSON parse.
class JapaneseDictionaryService {
  JapaneseDictionaryService._();

  static final JapaneseDictionaryService instance =
      JapaneseDictionaryService._();

  static const String _compiledAssetPath =
      'assets/compiled/dictionary_lexicon.json';

  Map<String, List<DictionaryEntry>>? _bySurface;
  JapaneseTokenizer? _tokenizer;
  bool _loaded = false;
  Future<void>? _loadFuture;

  bool get isLoaded => _loaded;

  /// Idempotent; concurrent callers share one in-flight parse.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      _loadFuture ??= _performLoad();
      await _loadFuture!;
    } on Object {
      _loadFuture = null;
      rethrow;
    }
  }

  /// Alias for [ensureLoaded].
  Future<void> load() => ensureLoaded();

  Future<void> _performLoad() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(_compiledAssetPath);
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
      final entry = DictionaryEntry.fromJson(Map<String, dynamic>.from(item));
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
        'JapaneseDictionaryService.ensureLoaded() was not awaited before tokenizer.',
      );
    }
    return t;
  }

  Map<String, List<DictionaryEntry>> get _map {
    final m = _bySurface;
    if (m == null) {
      throw StateError(
        'JapaneseDictionaryService.ensureLoaded() was not awaited before use.',
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
