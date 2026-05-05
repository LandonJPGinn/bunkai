import 'quiz.dart';

class QuizPack {
  const QuizPack({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.quizzes,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final List<Quiz> quizzes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'quizzes': quizzes.map((q) => q.toMap()).toList(),
      };

  /// JSON alias for [toMap].
  Map<String, dynamic> toJson() => toMap();

  /// JSON alias for [fromMap].
  factory QuizPack.fromJson(Map<String, dynamic> json) =>
      QuizPack.fromMap(json);

  factory QuizPack.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final title = map['title'];
    final author = map['author'];
    final description = map['description'];
    final quizzesRaw = map['quizzes'];

    if (id is! String) {
      throw const FormatException('QuizPack.fromMap: missing field "id"');
    }
    if (title is! String) {
      throw const FormatException('QuizPack.fromMap: missing field "title"');
    }
    if (author is! String) {
      throw const FormatException('QuizPack.fromMap: missing field "author"');
    }
    if (description is! String) {
      throw const FormatException(
        'QuizPack.fromMap: missing field "description"',
      );
    }
    if (quizzesRaw is! List) {
      throw const FormatException('QuizPack.fromMap: missing field "quizzes"');
    }

    return QuizPack(
      id: id,
      title: title,
      author: author,
      description: description,
      quizzes: [
        for (final raw in quizzesRaw)
          Quiz.fromMap(Map<String, dynamic>.from(raw as Map)),
      ],
    );
  }
}
