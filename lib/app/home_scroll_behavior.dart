import 'package:flutter/material.dart';

/// Hides scrollbars while preserving default Material scroll physics (overscroll, etc.).
class HomeScrollBehavior extends MaterialScrollBehavior {
  const HomeScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
