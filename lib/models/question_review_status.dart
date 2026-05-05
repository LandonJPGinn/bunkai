/// Optional editorial state for a question in source JSON.
enum QuestionReviewStatus {
  draft,
  reviewed,
  needsReview,
}

/// JSON uses `needs_review`; Dart uses [needsReview].
String questionReviewStatusToJson(QuestionReviewStatus s) => switch (s) {
      QuestionReviewStatus.draft => 'draft',
      QuestionReviewStatus.reviewed => 'reviewed',
      QuestionReviewStatus.needsReview => 'needs_review',
    };

QuestionReviewStatus questionReviewStatusFromJson(String raw) {
  switch (raw) {
    case 'draft':
      return QuestionReviewStatus.draft;
    case 'reviewed':
      return QuestionReviewStatus.reviewed;
    case 'needs_review':
      return QuestionReviewStatus.needsReview;
    default:
      throw FormatException(
        'QuestionReviewStatus: invalid reviewStatus "$raw" '
        '(expected draft, reviewed, or needs_review)',
      );
  }
}
