import '../data/approved_diagnostic_tags.dart';
import '../data/jlpt_question_levels.dart';
import '../models/question_review_status.dart';
import '../models/quiz.dart';

/// Minimum number of questions required for each bundled bank (contract tests).
const int kMinBundledQuizQuestionCount = 15;

/// ASCII Latin letters — heuristic for disallowed romaji in the `japanese` line.
/// Choice labels are not scanned (some banks use English glosses).
final RegExp _asciiLatinLetters = RegExp(r'[A-Za-z]');

/// Bundled JSON quiz banks failed one or more contract checks.
class QuizBankContractIssue {
  const QuizBankContractIssue({
    required this.quizId,
    this.questionId,
    required this.field,
    required this.reason,
  });

  final String quizId;
  final String? questionId;
  final String field;
  final String reason;

  /// Grep-friendly one-line format for test output.
  String toFailLine() {
    final q = questionId ?? '(quiz-level)';
    return 'FAIL | quizId=$quizId | questionId=$q | field=$field | reason=$reason';
  }
}

/// Strips common dialogue speaker tags so Latin in `A:` / `B:` is not treated as romaji.
String _stripDialogueSpeakerTags(String value) {
  return value.replaceAll('A: ', '').replaceAll('B: ', '');
}

/// Whether, after removing speaker tags, [value] still contains ASCII Latin letters
/// (heuristic for disallowed romaji in Japanese line content).
bool japaneseFieldContainsLatinLetters(String value) =>
    _asciiLatinLetters.hasMatch(_stripDialogueSpeakerTags(value));

List<QuizBankContractIssue> validateQuizBankContract(Quiz quiz) {
  final qid = quiz.id;
  final issues = <QuizBankContractIssue>[];

  if (quiz.questions.length < kMinBundledQuizQuestionCount) {
    issues.add(
      QuizBankContractIssue(
        quizId: qid,
        questionId: null,
        field: 'questions',
        reason:
            'expected at least $kMinBundledQuizQuestionCount questions, got ${quiz.questions.length}',
      ),
    );
  }

  for (var i = 0; i < quiz.diagnosticTags.length; i++) {
    final tag = quiz.diagnosticTags[i];
    if (!kApprovedDiagnosticTags.contains(tag)) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: null,
          field: 'diagnosticTags[$i]',
          reason: 'unknown quiz-level diagnostic tag "$tag"',
        ),
      );
    }
  }

  final seenQuestionIds = <String>{};

  for (final question in quiz.questions) {
    final id = question.id;

    if (!seenQuestionIds.add(id)) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'id',
          reason: 'duplicate question id within quiz',
        ),
      );
    }

    final canonicalAnswers = question.canonicalAnswers;
    if (canonicalAnswers.isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'acceptedAnswers',
          reason:
              'requires at least one canonical answer (acceptedAnswers or valid correct choice label)',
        ),
      );
    }

    if (question.choices.isNotEmpty) {
      final choiceIds = question.choices.map((c) => c.id).toList();
      final choiceIdSet = choiceIds.toSet();
      if (choiceIdSet.length != choiceIds.length) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'choices',
            reason: 'duplicate choice id within question',
          ),
        );
      }
      if (question.correctAnswerId.isNotEmpty &&
          !choiceIdSet.contains(question.correctAnswerId)) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'correctAnswerId',
            reason:
                '"${question.correctAnswerId}" is not among choice ids ${choiceIds.join(", ")}',
          ),
        );
      }
    }

    if (question.explanation.trim().isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'explanation',
          reason: 'explanation is empty or whitespace only',
        ),
      );
    }

    if (question.promptEn.trim().isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'promptEn',
          reason: 'promptEn is empty or whitespace only',
        ),
      );
    }
    if (question.japaneseEn.trim().isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'japaneseEn',
          reason: 'japaneseEn is empty or whitespace only',
        ),
      );
    }
    if (question.explanationEn.trim().isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'explanationEn',
          reason: 'explanationEn is empty or whitespace only',
        ),
      );
    }

    final qContext = question.context;
    if (qContext != null && qContext.trim().isNotEmpty) {
      final cEn = question.contextEn;
      if (cEn == null || cEn.trim().isEmpty) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'contextEn',
            reason: 'required when context is non-empty',
          ),
        );
      }
    } else if (question.contextEn != null &&
        question.contextEn!.trim().isNotEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'contextEn',
          reason: 'must be absent or empty when context is null or empty',
        ),
      );
    }

    if (question.diagnosticTags.isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'diagnosticTags',
          reason: 'at least one diagnostic tag required',
        ),
      );
    }

    for (var ti = 0; ti < question.diagnosticTags.length; ti++) {
      final tag = question.diagnosticTags[ti];
      if (!kApprovedDiagnosticTags.contains(tag)) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'diagnosticTags[$ti]',
            reason: 'unknown diagnostic tag "$tag"',
          ),
        );
      }
    }

    if (japaneseFieldContainsLatinLetters(question.japanese)) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'japanese',
          reason: 'contains ASCII Latin letters (romaji heuristic)',
        ),
      );
    }

    for (var ci = 0; ci < question.choices.length; ci++) {
      final choice = question.choices[ci];
      if (choice.label.trim().isEmpty) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'choices[$ci].label',
            reason: 'label is empty or whitespace only',
          ),
        );
      }
      final len = choice.labelEn?.trim().length ?? 0;
      if (len == 0) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'choices[$ci].labelEn',
            reason: 'labelEn is required',
          ),
        );
      }
      final cEx = choice.explanation;
      if (cEx != null && cEx.trim().isNotEmpty) {
        if (choice.explanationEn == null ||
            choice.explanationEn!.trim().isEmpty) {
          issues.add(
            QuizBankContractIssue(
              quizId: qid,
              questionId: id,
              field: 'choices[$ci].explanationEn',
              reason: 'required when explanation is set',
            ),
          );
        }
      } else if (choice.explanationEn != null &&
          choice.explanationEn!.trim().isNotEmpty) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'choices[$ci].explanationEn',
            reason: 'unexpected when explanation is empty or null',
          ),
        );
      }
    }

    final jlpt = question.jlptLevel;
    if (jlpt != null && !kJlptQuestionLevels.contains(jlpt)) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'jlptLevel',
          reason: 'invalid jlptLevel "$jlpt"',
        ),
      );
    }

    final diffScore = question.difficultyScore;
    if (diffScore != null && (diffScore < 1 || diffScore > 5)) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'difficultyScore',
          reason: 'expected 1–5, got $diffScore',
        ),
      );
    }

    for (var gi = 0; gi < question.grammarPoints.length; gi++) {
      if (question.grammarPoints[gi].trim().isEmpty) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'grammarPoints[$gi]',
            reason: 'entry is empty or whitespace only',
          ),
        );
      }
    }
    for (var vi = 0; vi < question.vocabulary.length; vi++) {
      if (question.vocabulary[vi].trim().isEmpty) {
        issues.add(
          QuizBankContractIssue(
            quizId: qid,
            questionId: id,
            field: 'vocabulary[$vi]',
            reason: 'entry is empty or whitespace only',
          ),
        );
      }
    }

    if (question.jlptLevel == null) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'jlptLevel',
          reason: 'bundled banks require jlptLevel',
        ),
      );
    }

    if (question.difficultyScore == null) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'difficultyScore',
          reason: 'bundled banks require difficultyScore (1–5)',
        ),
      );
    }

    if (question.grammarPoints.isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'grammarPoints',
          reason: 'bundled banks require at least one grammar point',
        ),
      );
    }

    if (question.vocabulary.isEmpty) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'vocabulary',
          reason: 'bundled banks require at least one vocabulary entry',
        ),
      );
    }

    if (question.reviewStatus != QuestionReviewStatus.draft) {
      issues.add(
        QuizBankContractIssue(
          quizId: qid,
          questionId: id,
          field: 'reviewStatus',
          reason: 'bundled banks require reviewStatus draft until reviewed',
        ),
      );
    }
  }

  return issues;
}
