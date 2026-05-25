import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz.dart';

class AdminQuizApiException implements Exception {
  const AdminQuizApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AdminQuizApiException: $message';
}

class AdminImportPreview {
  const AdminImportPreview({
    required this.ok,
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.errors,
    required this.savedQuizIds,
  });

  final bool ok;
  final int totalQuizzes;
  final int totalQuestions;
  final List<String> errors;
  final List<String> savedQuizIds;

  factory AdminImportPreview.fromJson(Map<String, dynamic> json) {
    final errorsRaw = json['errors'];
    final savedRaw = json['savedQuizIds'];
    return AdminImportPreview(
      ok: json['ok'] == true,
      totalQuizzes: json['totalQuizzes'] is int
          ? json['totalQuizzes'] as int
          : 0,
      totalQuestions: json['totalQuestions'] is int
          ? json['totalQuestions'] as int
          : 0,
      errors: errorsRaw is List
          ? [for (final item in errorsRaw) item.toString()]
          : const [],
      savedQuizIds: savedRaw is List
          ? [for (final item in savedRaw) item.toString()]
          : const [],
    );
  }
}

class AdminQuizService {
  AdminQuizService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.base.resolve(path);

  Future<bool> checkSession() async {
    final response = await _client.get(_uri('/api/admin/session'));
    if (response.statusCode == 200) return true;
    if (response.statusCode == 401) return false;
    throw _exception(response, fallback: 'Could not check admin session.');
  }

  Future<void> login(String password) async {
    final response = await _client.post(
      _uri('/api/admin/login'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode == 200) return;
    throw _exception(response, fallback: 'Admin login failed.');
  }

  Future<void> logout() async {
    final response = await _client.post(_uri('/api/admin/logout'));
    if (response.statusCode == 200) return;
    throw _exception(response, fallback: 'Admin logout failed.');
  }

  Future<List<Quiz>> fetchQuizzes() async {
    final response = await _client.get(_uri('/api/admin/quizzes'));
    if (response.statusCode != 200) {
      throw _exception(response, fallback: 'Could not load admin quizzes.');
    }
    final decoded = _decodeObject(response);
    final quizzesRaw = decoded['quizzes'];
    if (quizzesRaw is! List) {
      throw const AdminQuizApiException('Admin quiz response was malformed.');
    }
    return [
      for (final raw in quizzesRaw)
        Quiz.fromJson(Map<String, dynamic>.from(raw as Map)),
    ];
  }

  Future<Quiz> saveQuiz(Quiz quiz) async {
    final response = await _client.put(
      _uri('/api/admin/quizzes/${Uri.encodeComponent(quiz.id)}'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'quiz': quiz.toJson()}),
    );
    if (response.statusCode != 200) {
      throw _exception(response, fallback: 'Could not save quiz.');
    }
    final decoded = _decodeObject(response);
    final quizRaw = decoded['quiz'];
    if (quizRaw is! Map) {
      throw const AdminQuizApiException('Saved quiz response was malformed.');
    }
    return Quiz.fromJson(Map<String, dynamic>.from(quizRaw));
  }

  Future<Map<String, String>> exportCsvTables() async {
    final response = await _client.get(_uri('/api/admin/export?format=csv'));
    if (response.statusCode != 200) {
      throw _exception(response, fallback: 'Could not export CSV.');
    }
    final decoded = _decodeObject(response);
    final csv = decoded['csv'];
    if (csv is! Map) {
      throw const AdminQuizApiException('CSV export response was malformed.');
    }
    return {
      'quizzes.csv': (csv['quizzes'] ?? '').toString(),
      'questions.csv': (csv['questions'] ?? '').toString(),
      'choices.csv': (csv['choices'] ?? '').toString(),
    };
  }

  Future<String> exportJson() async {
    final response = await _client.get(_uri('/api/admin/export'));
    if (response.statusCode != 200) {
      throw _exception(response, fallback: 'Could not export JSON.');
    }
    final decoded = jsonDecode(response.body);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  }

  Future<AdminImportPreview> previewImport(Object payload) =>
      _postImport('/api/admin/import/preview', payload);

  Future<AdminImportPreview> applyImport(Object payload) =>
      _postImport('/api/admin/import/apply', payload);

  Future<AdminImportPreview> _postImport(String path, Object payload) async {
    final response = await _client.post(
      _uri(path),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw _exception(response, fallback: 'Import request failed.');
    }
    return AdminImportPreview.fromJson(_decodeObject(response));
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const AdminQuizApiException('API response was not a JSON object.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  AdminQuizApiException _exception(
    http.Response response, {
    required String fallback,
  }) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is String) {
        final details = decoded['details'];
        final suffix = details is List && details.isNotEmpty
            ? '\n${details.map((item) => '- $item').join('\n')}'
            : '';
        return AdminQuizApiException(
          '${decoded['error']}$suffix',
          statusCode: response.statusCode,
        );
      }
    } catch (_) {
      // Use the fallback below.
    }
    return AdminQuizApiException(fallback, statusCode: response.statusCode);
  }
}
