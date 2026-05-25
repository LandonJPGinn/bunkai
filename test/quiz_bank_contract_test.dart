import 'dart:convert';
import 'dart:io';

import 'package:jpquizapp/data/bundled_quiz_bank_paths.dart';
import 'package:jpquizapp/models/quiz.dart';
import 'package:jpquizapp/services/quiz_bank_contract_validator.dart';
import 'package:jpquizapp/services/quiz_bank_duplicate_warnings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled quiz bank JSON files satisfy contract', () {
    final allIssues = <QuizBankContractIssue>[];
    var duplicateWarningCount = 0;

    for (final entry in kBundledQuizBankAssetPaths.entries) {
      final assetPath = entry.value;
      final file = File(assetPath);

      expect(
        file.existsSync(),
        isTrue,
        reason: 'bundled quiz bank file missing: $assetPath',
      );

      final decoded = jsonDecode(file.readAsStringSync());
      expect(decoded, isA<Map>());
      final quiz = Quiz.fromJson(
        Map<String, dynamic>.from(decoded as Map<dynamic, dynamic>),
      );
      expect(
        quiz.id,
        entry.key,
        reason: 'JSON id must match registered path for $assetPath',
      );

      final dupWarnings = formatQuizBankDuplicateWarnings(quiz);
      duplicateWarningCount += dupWarnings.length;
      for (final w in dupWarnings) {
        // ignore: avoid_print
        print(w);
      }

      allIssues.addAll(validateQuizBankContract(quiz));
    }

    if (duplicateWarningCount > 0) {
      // ignore: avoid_print
      print('WARNINGS SUMMARY | totalDuplicateWarnings=$duplicateWarningCount');
    }

    if (allIssues.isNotEmpty) {
      for (final issue in allIssues) {
        // ignore: avoid_print
        print(issue.toFailLine());
      }
      // ignore: avoid_print
      print('SUMMARY | totalIssues=${allIssues.length}');
    }

    expect(
      allIssues,
      isEmpty,
      reason:
          '${allIssues.length} quiz bank contract violation(s); see FAIL lines above',
    );
  });
}
