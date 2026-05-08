class DictionaryEntry {
  const DictionaryEntry({
    required this.surface,
    required this.reading,
    required this.partOfSpeech,
    required this.definitions,
    this.jlptLevel,
    this.tags = const [],
  });

  final String surface;
  final String reading;
  final String partOfSpeech;
  final List<String> definitions;
  final String? jlptLevel;
  final List<String> tags;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final surface = json['surface'];
    if (surface is! String || surface.isEmpty) {
      throw const FormatException('DictionaryEntry: "surface" must be a non-empty string');
    }
    final reading = json['reading'];
    if (reading is! String || reading.trim().isEmpty) {
      throw const FormatException(
        'DictionaryEntry: "reading" must be a non-empty string',
      );
    }
    final partOfSpeech = json['partOfSpeech'];
    if (partOfSpeech is! String) {
      throw const FormatException('DictionaryEntry: "partOfSpeech" must be a string');
    }
    final definitionsRaw = json['definitions'];
    if (definitionsRaw is! List) {
      throw const FormatException('DictionaryEntry: "definitions" must be an array');
    }
    final definitions = <String>[
      for (final d in definitionsRaw)
        if (d is String && d.trim().isNotEmpty) d.trim(),
    ];
    if (definitions.isEmpty) {
      throw const FormatException('DictionaryEntry: "definitions" must be non-empty');
    }
    String? jlptLevel;
    final j = json['jlptLevel'];
    if (j is String) jlptLevel = j;
    final tags = <String>[];
    final tagsRaw = json['tags'];
    if (tagsRaw is List) {
      for (final t in tagsRaw) {
        if (t is String) tags.add(t);
      }
    }
    return DictionaryEntry(
      surface: surface,
      reading: reading,
      partOfSpeech: partOfSpeech,
      definitions: definitions,
      jlptLevel: jlptLevel,
      tags: tags,
    );
  }
}
