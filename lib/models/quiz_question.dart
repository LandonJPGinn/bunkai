import '../data/jlpt_question_levels.dart';
import 'answer_choice.dart';
import 'question_review_status.dart';
import 'quiz_type.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.japanese,
    this.context,
    required this.promptEn,
    required this.japaneseEn,
    this.contextEn,
    this.choices = const [],
    this.correctAnswerId = '',
    this.acceptedAnswers = const [],
    required this.explanation,
    required this.explanationEn,
    this.diagnosticTags = const [],
    this.jlptLevel,
    this.difficultyScore,
    this.grammarPoints = const [],
    this.vocabulary = const [],
    this.reviewStatus,
    this.reviewNotes,
    this.source,
    this.author,
  });

  final String id;
  final QuizType type;
  final String prompt;
  final String japanese;
  final String? context;

  /// English exam-style instructions (paired with [prompt]).
  final String promptEn;

  /// English gloss or transliteration of the main line (paired with [japanese]).
  final String japaneseEn;

  /// English counterpart to [context], when context is set.
  final String? contextEn;

  final List<AnswerChoice> choices;
  final String correctAnswerId;
  final List<String> acceptedAnswers;
  final String explanation;

  /// Brief English rationale (paired with [explanation]).
  final String explanationEn;

  final List<String> diagnosticTags;

  /// Optional JLPT band for this item; must be one of [kJlptQuestionLevels] when set.
  final String? jlptLevel;

  /// Optional difficulty 1–5 when set.
  final int? difficultyScore;

  final List<String> grammarPoints;
  final List<String> vocabulary;

  final QuestionReviewStatus? reviewStatus;
  final String? reviewNotes;
  final String? source;
  final String? author;

  /// Canonical acceptable answers for typed input.
  ///
  /// Priority:
  /// 1) Explicit [acceptedAnswers] from bank JSON.
  /// 2) Backward-compatible fallback to the correct choice label.
  List<String> get canonicalAnswers {
    final normalized = <String>[];
    final seen = <String>{};
    for (final answer in acceptedAnswers) {
      final trimmed = answer.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed)) normalized.add(trimmed);
    }
    if (normalized.isNotEmpty) {
      return normalized;
    }
    if (choices.isNotEmpty && correctAnswerId.isNotEmpty) {
      for (final choice in choices) {
        if (choice.id == correctAnswerId) {
          final trimmed = choice.label.trim();
          if (trimmed.isNotEmpty) {
            return [trimmed];
          }
          break;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'prompt': prompt,
        'japanese': japanese,
        if (context != null) 'context': context,
        'promptEn': promptEn,
        'japaneseEn': japaneseEn,
        if (contextEn != null) 'contextEn': contextEn,
        if (choices.isNotEmpty) 'choices': choices.map((c) => c.toMap()).toList(),
        if (correctAnswerId.isNotEmpty) 'correctAnswerId': correctAnswerId,
        if (acceptedAnswers.isNotEmpty) 'acceptedAnswers': acceptedAnswers,
        'explanation': explanation,
        'explanationEn': explanationEn,
        'diagnosticTags': diagnosticTags,
        if (jlptLevel != null) 'jlptLevel': jlptLevel,
        if (difficultyScore != null) 'difficultyScore': difficultyScore,
        if (grammarPoints.isNotEmpty) 'grammarPoints': grammarPoints,
        if (vocabulary.isNotEmpty) 'vocabulary': vocabulary,
        if (reviewStatus != null)
          'reviewStatus': questionReviewStatusToJson(reviewStatus!),
        if (reviewNotes != null) 'reviewNotes': reviewNotes,
        if (source != null) 'source': source,
        if (author != null) 'author': author,
      };

  /// JSON alias for [toMap].
  Map<String, dynamic> toJson() => toMap();

  /// JSON alias for [fromMap].
  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      QuizQuestion.fromMap(json);

  QuizQuestion copyWith({
    String? id,
    QuizType? type,
    String? prompt,
    String? japanese,
    String? context,
    String? promptEn,
    String? japaneseEn,
    String? contextEn,
    List<AnswerChoice>? choices,
    String? correctAnswerId,
    List<String>? acceptedAnswers,
    String? explanation,
    String? explanationEn,
    List<String>? diagnosticTags,
    String? jlptLevel,
    int? difficultyScore,
    List<String>? grammarPoints,
    List<String>? vocabulary,
    QuestionReviewStatus? reviewStatus,
    String? reviewNotes,
    String? source,
    String? author,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      japanese: japanese ?? this.japanese,
      context: context ?? this.context,
      promptEn: promptEn ?? this.promptEn,
      japaneseEn: japaneseEn ?? this.japaneseEn,
      contextEn: contextEn ?? this.contextEn,
      choices: choices ?? this.choices,
      correctAnswerId: correctAnswerId ?? this.correctAnswerId,
      acceptedAnswers: acceptedAnswers ?? this.acceptedAnswers,
      explanation: explanation ?? this.explanation,
      explanationEn: explanationEn ?? this.explanationEn,
      diagnosticTags: diagnosticTags ?? this.diagnosticTags,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      grammarPoints: grammarPoints ?? this.grammarPoints,
      vocabulary: vocabulary ?? this.vocabulary,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      source: source ?? this.source,
      author: author ?? this.author,
    );
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final typeName = map['type'];
    final prompt = map['prompt'];
    final japanese = map['japanese'];
    final context = map['context'];
    final promptEn = map['promptEn'];
    final japaneseEn = map['japaneseEn'];
    final contextEn = map['contextEn'];
    final choicesRaw = map['choices'];
    final correctAnswerId = map['correctAnswerId'];
    final acceptedAnswersRaw = map['acceptedAnswers'];
    final explanation = map['explanation'];
    final explanationEn = map['explanationEn'];
    final diagnosticTagsRaw = map['diagnosticTags'];
    final jlptLevelRaw = map['jlptLevel'];
    final difficultyScoreRaw = map['difficultyScore'];
    final grammarPointsRaw = map['grammarPoints'];
    final vocabularyRaw = map['vocabulary'];
    final reviewStatusRaw = map['reviewStatus'];
    final reviewNotesRaw = map['reviewNotes'];
    final sourceRaw = map['source'];
    final authorRaw = map['author'];

    if (id is! String) {
      throw const FormatException('QuizQuestion.fromMap: missing field "id"');
    }
    if (typeName is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "type"',
      );
    }
    if (prompt is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "prompt"',
      );
    }
    if (japanese is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "japanese"',
      );
    }
    if (choicesRaw != null && choicesRaw is! List) {
      throw const FormatException(
        'QuizQuestion.fromMap: field "choices" must be an array or absent',
      );
    }
    if (correctAnswerId != null && correctAnswerId is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: field "correctAnswerId" must be a string or absent',
      );
    }
    if (acceptedAnswersRaw != null && acceptedAnswersRaw is! List) {
      throw const FormatException(
        'QuizQuestion.fromMap: field "acceptedAnswers" must be an array or absent',
      );
    }
    if (explanation is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "explanation"',
      );
    }
    if (promptEn is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "promptEn"',
      );
    }
    if (japaneseEn is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "japaneseEn"',
      );
    }
    if (explanationEn is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: missing field "explanationEn"',
      );
    }
    if (contextEn != null && contextEn is! String) {
      throw const FormatException(
        'QuizQuestion.fromMap: field "contextEn" must be a string or absent',
      );
    }

    final QuizType type;
    try {
      type = QuizType.values.byName(typeName);
    } on ArgumentError {
      throw FormatException(
        'QuizQuestion.fromMap: unknown QuizType "$typeName"',
      );
    }

    String? jlptLevel;
    if (jlptLevelRaw != null) {
      if (jlptLevelRaw is! String) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "jlptLevel" must be a string or absent',
        );
      }
      if (!kJlptQuestionLevels.contains(jlptLevelRaw)) {
        throw FormatException(
          'QuizQuestion.fromMap: invalid jlptLevel "$jlptLevelRaw"',
        );
      }
      jlptLevel = jlptLevelRaw;
    }

    int? difficultyScore;
    if (difficultyScoreRaw != null) {
      if (difficultyScoreRaw is! int ||
          difficultyScoreRaw < 1 ||
          difficultyScoreRaw > 5) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "difficultyScore" must be an integer from 1 to 5 or absent',
        );
      }
      difficultyScore = difficultyScoreRaw;
    }

    List<String> grammarPoints = const [];
    if (grammarPointsRaw != null) {
      if (grammarPointsRaw is! List) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "grammarPoints" must be an array or absent',
        );
      }
      grammarPoints = [
        for (final item in grammarPointsRaw)
          if (item is String)
            item
          else
            throw const FormatException(
              'QuizQuestion.fromMap: grammarPoints entries must be strings',
            ),
      ];
    }

    List<String> vocabulary = const [];
    if (vocabularyRaw != null) {
      if (vocabularyRaw is! List) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "vocabulary" must be an array or absent',
        );
      }
      vocabulary = [
        for (final item in vocabularyRaw)
          if (item is String)
            item
          else
            throw const FormatException(
              'QuizQuestion.fromMap: vocabulary entries must be strings',
            ),
      ];
    }

    QuestionReviewStatus? reviewStatus;
    if (reviewStatusRaw != null) {
      if (reviewStatusRaw is! String) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "reviewStatus" must be a string or absent',
        );
      }
      reviewStatus = questionReviewStatusFromJson(reviewStatusRaw);
    }

    String? reviewNotes;
    if (reviewNotesRaw != null) {
      if (reviewNotesRaw is! String) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "reviewNotes" must be a string or absent',
        );
      }
      reviewNotes = reviewNotesRaw;
    }

    String? source;
    if (sourceRaw != null) {
      if (sourceRaw is! String) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "source" must be a string or absent',
        );
      }
      source = sourceRaw;
    }

    String? author;
    if (authorRaw != null) {
      if (authorRaw is! String) {
        throw const FormatException(
          'QuizQuestion.fromMap: field "author" must be a string or absent',
        );
      }
      author = authorRaw;
    }

    final parsedChoices = [
      for (final raw in (choicesRaw as List? ?? const []))
        AnswerChoice.fromMap(Map<String, dynamic>.from(raw as Map)),
    ];
    final parsedAcceptedAnswers = [
      for (final item in (acceptedAnswersRaw as List? ?? const []))
        if (item is String)
          item
        else
          throw const FormatException(
            'QuizQuestion.fromMap: acceptedAnswers entries must be strings',
          ),
    ];

    return QuizQuestion(
      id: id,
      type: type,
      prompt: prompt,
      japanese: japanese,
      context: context is String ? context : null,
      promptEn: promptEn,
      japaneseEn: japaneseEn,
      contextEn: contextEn is String ? contextEn : null,
      choices: parsedChoices,
      correctAnswerId: (correctAnswerId as String?) ?? '',
      acceptedAnswers: parsedAcceptedAnswers,
      explanation: explanation,
      explanationEn: explanationEn,
      diagnosticTags: diagnosticTagsRaw is List
          ? [for (final t in diagnosticTagsRaw) t as String]
          : const [],
      jlptLevel: jlptLevel,
      difficultyScore: difficultyScore,
      grammarPoints: grammarPoints,
      vocabulary: vocabulary,
      reviewStatus: reviewStatus,
      reviewNotes: reviewNotes,
      source: source,
      author: author,
    );
  }
}
