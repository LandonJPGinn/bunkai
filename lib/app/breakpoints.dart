/// Logical-pixel breakpoints aligned with the home quiz grid.
abstract final class LayoutBreakpoints {
  /// Below this width: single-column grid and tighter horizontal padding.
  static const double tablet = 600;

  /// At or above: three-column home grid.
  static const double desktop = 960;

  /// Progress header stacks into two rows below this inner width.
  static const double progressHeaderCompact = 520;

  static bool isNarrowWidth(double width) => width < tablet;
}
