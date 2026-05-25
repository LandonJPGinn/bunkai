import 'package:flutter/material.dart';

import '../services/furigana_inline.dart';
import 'japanese_text_lookup.dart';

class DiagnosticTagChip extends StatelessWidget {
  const DiagnosticTagChip({
    super.key,
    required this.label,
    this.showFurigana = false,
  });

  final String label;
  final bool showFurigana;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.3,
    );
    final useFuriganaRenderer = label.contains('[') || hasCjkIdeograph(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: useFuriganaRenderer
          ? JapaneseTextLookup(
              text: label,
              showFurigana: showFurigana,
              style: style,
            )
          : Text(label, style: style),
    );
  }
}
