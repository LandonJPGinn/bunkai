import 'package:flutter/material.dart';

import '../app/color/oklch.dart';

// OKLCH equivalents of the prior `Color(0xFF0D1118)` / `Color(0xFFFAFAFA)`.
final Color _onDark = const Oklch(0.1768, 0.0159, 261.52).toColor();
final Color _onLight = const Oklch(0.9851, 0.000, 89.88).toColor();

Color _onAccentColor(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.45 ? _onDark : _onLight;
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  /// Overrides theme primary when set (e.g. quiz topic accent).
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary;
    final fg = foregroundColor ?? _onAccentColor(bg);

    final child = FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        backgroundColor: bg,
        foregroundColor: fg,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
    if (expanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
