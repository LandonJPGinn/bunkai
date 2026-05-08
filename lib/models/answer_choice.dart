class AnswerChoice {
  const AnswerChoice({
    required this.id,
    required this.label,
    this.explanation,
    this.labelEn,
    this.explanationEn,
  });

  final String id;
  final String label;
  final String? explanation;

  /// English gloss for [label] (e.g. particle name in English).
  final String? labelEn;

  /// English rationale paired with [explanation] when present.
  final String? explanationEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        if (explanation != null) 'explanation': explanation,
        if (labelEn != null) 'labelEn': labelEn,
        if (explanationEn != null) 'explanationEn': explanationEn,
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
    final labelEn = map['labelEn'];
    final explanationEn = map['explanationEn'];

    if (id is! String) {
      throw const FormatException('AnswerChoice.fromMap: missing field "id"');
    }
    if (label is! String) {
      throw const FormatException(
        'AnswerChoice.fromMap: missing field "label"',
      );
    }
    if (labelEn != null && labelEn is! String) {
      throw const FormatException(
        'AnswerChoice.fromMap: field "labelEn" must be a string or absent',
      );
    }
    if (explanationEn != null && explanationEn is! String) {
      throw const FormatException(
        'AnswerChoice.fromMap: field "explanationEn" must be a string or absent',
      );
    }

    return AnswerChoice(
      id: id,
      label: label,
      explanation: explanation is String ? explanation : null,
      labelEn: labelEn is String ? labelEn : null,
      explanationEn: explanationEn is String ? explanationEn : null,
    );
  }
}
