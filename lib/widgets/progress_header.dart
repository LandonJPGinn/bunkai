import 'package:flutter/material.dart';

import '../app/breakpoints.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.moduleLabel,
    required this.scoreCorrect,
    required this.scoreAnswered,
    this.accent,
  });

  final int current;
  final int total;
  final String moduleLabel;
  final int scoreCorrect;
  final int scoreAnswered;

  /// Progress bar color; falls back to [ColorScheme.primary].
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safeTotal = total <= 0 ? 1 : total;
    final value = ((current + 1).clamp(1, safeTotal)) / safeTotal;
    final scoreLabel = scoreAnswered == 0
        ? '—'
        : '$scoreCorrect / $scoreAnswered';

    final wide =
        MediaQuery.sizeOf(context).width >=
        LayoutBreakpoints.progressHeaderCompact;

    final barColor = accent ?? scheme.primary;

    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.95),
      letterSpacing: 0.08,
      fontWeight: FontWeight.w500,
    );
    final qStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: scheme.onSurface,
      letterSpacing: 0.06,
    );
    final scoreStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.06,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  moduleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              Text('Q ${current + 1} / $total', style: qStyle),
              const SizedBox(width: 14),
              Text('Score $scoreLabel', style: scoreStyle),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                moduleLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Q ${current + 1} / $total', style: qStyle),
                  Text('Score $scoreLabel', style: scoreStyle),
                ],
              ),
            ],
          ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: scheme.surfaceContainerHighest,
            color: barColor.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}
