import 'package:flutter/material.dart';

/// Five dots; [filledCount] in 1..5 are shown filled.
class DifficultyDots extends StatelessWidget {
  const DifficultyDots({
    super.key,
    required this.filledCount,
  }) : assert(filledCount >= 1 && filledCount <= 5);

  final int filledCount;

  static const int _total = 5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = scheme.primary;
    final off = scheme.outlineVariant.withValues(alpha: 0.45);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _total; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filledCount ? on : off,
              ),
            ),
          ),
      ],
    );
  }
}
