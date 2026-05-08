/// Cleans instruction copy shown above the question (e.g. strips legacy
/// per-item question numbers from quiz bank English).
String normalizeQuizInstructions(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return s;

  final patterns = <RegExp>[
    RegExp(r'^q\s*\d+\s*:\s*', caseSensitive: false),
    RegExp(r'^question\s*(?:no\.?\s*)?\d+\s*:\s*', caseSensitive: false),
    RegExp(r'^vol\.?\s*\d+\s*:\s*', caseSensitive: false),
    RegExp(r'^no\.?\s*\d+\s*:\s*', caseSensitive: false),
    RegExp(
      r'^the\s+\d+(?:st|nd|rd|th)\s+questions?\s*:\s*',
      caseSensitive: false,
    ),
  ];

  for (var i = 0; i < 8; i++) {
    var changed = false;
    for (final re in patterns) {
      final next = s.replaceFirst(re, '').trim();
      if (next != s && next.isNotEmpty) {
        s = next;
        changed = true;
      }
    }
    if (!changed) break;
  }

  return s.trim();
}
