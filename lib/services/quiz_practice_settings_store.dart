import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_options.dart';
import '../models/quiz_id.dart';

/// Persists per-quiz practice settings locally.
class QuizPracticeSettingsStore {
  QuizPracticeSettingsStore._();

  static final QuizPracticeSettingsStore instance = QuizPracticeSettingsStore._();

  static const String _storageKey = 'practice_settings_by_quiz_v1';

  Future<PracticeQuizSettings> load(QuizId quizId) async {
    final all = await _readAll();
    final raw = all[quizId.name];
    if (raw is Map<String, Object?>) {
      return PracticeQuizSettings.fromStorageMap(raw);
    }
    return PracticeQuizSettings.defaults;
  }

  Future<void> save(QuizId quizId, PracticeQuizSettings settings) async {
    final all = await _readAll();
    all[quizId.name] = settings.toStorageMap();
    await _writeAll(all);
  }

  Future<Map<String, Object?>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) {
      return <String, Object?>{};
    }
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      return <String, Object?>{};
    }
    return decoded.map<String, Object?>(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  Future<void> _writeAll(Map<String, Object?> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(value));
  }
}
