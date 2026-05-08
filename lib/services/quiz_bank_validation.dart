import '../data/jlpt_question_levels.dart';
import '../models/question_review_status.dart';
import '../models/quiz.dart';

/// Thrown when a bundled quiz bank JSON fails validation after parse.
class QuizBankFormatException implements Exception {
  QuizBankFormatException(this.message);

  final String message;

  @override
  String toString() => 'QuizBankFormatException: $message';
}

/// Validates [quiz] question rows (used by [QuizBankLoader] and tooling).
void validateQuizBankContent(Quiz quiz) {
  final quizId = quiz.id.name;
  final seenQuestionIds = <String>{};

  for (final question in quiz.questions) {
    final qid = question.id;
    if (!seenQuestionIds.add(qid)) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": duplicate question id',
      );
    }

    if (question.prompt.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": prompt is empty',
      );
    }
    if (question.japanese.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": japanese is empty',
      );
    }
    if (question.explanation.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": explanation is empty',
      );
    }
    if (question.promptEn.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": promptEn is empty',
      );
    }
    if (question.japaneseEn.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": japaneseEn is empty',
      );
    }
    if (question.explanationEn.trim().isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": explanationEn is empty',
      );
    }
    final ctx = question.context;
    if (ctx != null && ctx.trim().isNotEmpty) {
      final cEn = question.contextEn;
      if (cEn == null || cEn.trim().isEmpty) {
        throw QuizBankFormatException(
          'Quiz "$quizId" / question "$qid": contextEn is required when context is set',
        );
      }
    } else if (question.contextEn != null &&
        question.contextEn!.trim().isNotEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": contextEn present but context is empty or null',
      );
    }
    if (question.diagnosticTags.isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": diagnosticTags is empty',
      );
    }
    if (question.choices.length < 2) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": at least 2 choices required (got ${question.choices.length})',
      );
    }
    final choiceIds = question.choices.map((c) => c.id).toSet();
    if (!choiceIds.contains(question.correctAnswerId)) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": correctAnswerId "${question.correctAnswerId}" is not among choice ids',
      );
    }

    for (var i = 0; i < question.choices.length; i++) {
      final c = question.choices[i];
      if (c.labelEn == null || c.labelEn!.trim().isEmpty) {
        throw QuizBankFormatException(
          'Quiz "$quizId" / question "$qid": choices[$i].labelEn is required',
        );
      }
      final ex = c.explanation;
      if (ex != null && ex.trim().isNotEmpty) {
        if (c.explanationEn == null || c.explanationEn!.trim().isEmpty) {
          throw QuizBankFormatException(
            'Quiz "$quizId" / question "$qid": choices[$i].explanationEn '
            'is required when explanation is set',
          );
        }
      } else if (c.explanationEn != null &&
          c.explanationEn!.trim().isNotEmpty) {
        throw QuizBankFormatException(
          'Quiz "$quizId" / question "$qid": choices[$i].explanationEn '
          'present without Japanese explanation',
        );
      }
    }

    final jlpt = question.jlptLevel;
    if (jlpt != null && !kJlptQuestionLevels.contains(jlpt)) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": invalid jlptLevel "$jlpt"',
      );
    }

    final score = question.difficultyScore;
    if (score != null && (score < 1 || score > 5)) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": difficultyScore must be 1–5, got $score',
      );
    }

    for (var i = 0; i < question.grammarPoints.length; i++) {
      if (question.grammarPoints[i].trim().isEmpty) {
        throw QuizBankFormatException(
          'Quiz "$quizId" / question "$qid": grammarPoints[$i] is empty or whitespace only',
        );
      }
    }
    for (var i = 0; i < question.vocabulary.length; i++) {
      if (question.vocabulary[i].trim().isEmpty) {
        throw QuizBankFormatException(
          'Quiz "$quizId" / question "$qid": vocabulary[$i] is empty or whitespace only',
        );
      }
    }

    if (question.jlptLevel == null) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": jlptLevel is required',
      );
    }
    if (question.difficultyScore == null) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": difficultyScore is required',
      );
    }
    if (question.grammarPoints.isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": grammarPoints must be non-empty',
      );
    }
    if (question.vocabulary.isEmpty) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": vocabulary must be non-empty',
      );
    }
    if (question.reviewStatus != QuestionReviewStatus.draft) {
      throw QuizBankFormatException(
        'Quiz "$quizId" / question "$qid": reviewStatus must be draft',
      );
    }
  }
}
