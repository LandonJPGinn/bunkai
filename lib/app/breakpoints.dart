/// Logical-pixel breakpoints aligned with the home quiz grid.
abstract final class LayoutBreakpoints {
  /// Common iPhone portrait widths, including Plus/Max Safari logical widths.
  static const double phone = 480;

  /// Below this width: single-column grid and tighter horizontal padding.
  static const double tablet = 600;

  /// At or above: three-column home grid.
  static const double desktop = 960;

  /// Progress header stacks into two rows below this inner width.
  static const double progressHeaderCompact = 520;

  static bool isPhoneWidth(double width) => width < phone;

  static bool isNarrowWidth(double width) => width < tablet;

  static double pageHorizontalPadding(double width) =>
      isPhoneWidth(width) ? 12 : 20;
}
