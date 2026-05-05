import 'quiz_id.dart';
import 'quiz_question.dart';

class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.difficulty,
    this.diagnosticTags = const [],
    required this.questions,
  });

  final QuizId id;
  final String title;
  final String subtitle;
  final String description;
  final String difficulty;
  final List<String> diagnosticTags;
  final List<QuizQuestion> questions;

  Map<String, dynamic> toMap() => {
        'id': id.name,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'difficulty': difficulty,
        'diagnosticTags': diagnosticTags,
        'questions': questions.map((q) => q.toMap()).toList(),
      };

  /// JSON alias for [toMap] (local assets / serialization).
  Map<String, dynamic> toJson() => toMap();

  /// JSON alias for [fromMap].
  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz.fromMap(json);

  // Note: Quiz.id is currently constrained to the QuizId enum. Community packs
  // loaded via fromMap can only reference IDs that already exist in QuizId.
  // Migrating Quiz.id to a plain String is the future step that unlocks fully
  // arbitrary community quiz IDs.
  factory Quiz.fromMap(Map<String, dynamic> map) {
    final idName = map['id'];
    final title = map['title'];
    final subtitle = map['subtitle'];
    final description = map['description'];
    final difficulty = map['difficulty'];
    final diagnosticTagsRaw = map['diagnosticTags'];
    final questionsRaw = map['questions'];

    if (idName is! String) {
      throw const FormatException('Quiz.fromMap: missing field "id"');
    }
    if (title is! String) {
      throw const FormatException('Quiz.fromMap: missing field "title"');
    }
    if (subtitle is! String) {
      throw const FormatException('Quiz.fromMap: missing field "subtitle"');
    }
    if (description is! String) {
      throw const FormatException('Quiz.fromMap: missing field "description"');
    }
    if (difficulty is! String) {
      throw const FormatException('Quiz.fromMap: missing field "difficulty"');
    }
    if (questionsRaw is! List) {
      throw const FormatException('Quiz.fromMap: missing field "questions"');
    }

    final QuizId id;
    try {
      id = QuizId.values.byName(idName);
    } on ArgumentError {
      throw FormatException('Quiz.fromMap: unknown QuizId "$idName"');
    }

    return Quiz(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      difficulty: difficulty,
      diagnosticTags: diagnosticTagsRaw is List
          ? [for (final t in diagnosticTagsRaw) t as String]
          : const [],
      questions: [
        for (final raw in questionsRaw)
          QuizQuestion.fromMap(Map<String, dynamic>.from(raw as Map)),
      ],
    );
  }
}
