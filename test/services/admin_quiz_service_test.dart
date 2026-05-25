import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jpquizapp/services/admin_quiz_service.dart';

void main() {
  test('fetchQuizzes parses admin quiz response', () async {
    final service = AdminQuizService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/admin/quizzes');
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'quizzes': [
              {
                'id': 'sample',
                'title': 'Sample',
                'subtitle': 'Sub',
                'description': 'Desc',
                'difficulty': 'N5',
                'diagnosticTags': ['draft'],
                'questions': [
                  {
                    'id': 'q1',
                    'type': 'textInput',
                    'prompt': 'Type',
                    'promptEn': 'Type',
                    'japanese': 'answer',
                    'japaneseEn': 'answer',
                    'acceptedAnswers': ['answer'],
                    'explanation': 'Reason',
                    'explanationEn': 'Reason',
                    'diagnosticTags': ['draft'],
                  },
                ],
              },
            ],
          })),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final quizzes = await service.fetchQuizzes();
    expect(quizzes, hasLength(1));
    expect(quizzes.single.id, 'sample');
    expect(quizzes.single.questions.single.acceptedAnswers, ['answer']);
  });

  test('previewImport reports validation errors', () async {
    final service = AdminQuizService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/admin/import/preview');
        return http.Response(
          jsonEncode({
            'ok': false,
            'totalQuizzes': 1,
            'totalQuestions': 0,
            'errors': ['title is required'],
          }),
          200,
        );
      }),
    );

    final preview = await service.previewImport({'quizzes': []});
    expect(preview.ok, isFalse);
    expect(preview.errors, ['title is required']);
  });
}
