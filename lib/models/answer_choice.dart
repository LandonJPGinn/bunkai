class AnswerChoice {
  const AnswerChoice({
    required this.id,
    required this.label,
    this.explanation,
  });

  final String id;
  final String label;
  final String? explanation;

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        if (explanation != null) 'explanation': explanation,
      };

  /// JSON alias for [toMap].
  Map<String, dynamic> toJson() => toMap();

  /// JSON alias for [fromMap].
  factory AnswerChoice.fromJson(Map<String, dynamic> json) =>
      AnswerChoice.fromMap(json);

  factory AnswerChoice.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final label = map['label'];
    final explanation = map['explanation'];

    if (id is! String) {
      throw const FormatException('AnswerChoice.fromMap: missing field "id"');
    }
    if (label is! String) {
      throw const FormatException(
        'AnswerChoice.fromMap: missing field "label"',
      );
    }

    return AnswerChoice(
      id: id,
      label: label,
      explanation: explanation is String ? explanation : null,
    );
  }
}
