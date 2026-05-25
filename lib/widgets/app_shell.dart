import 'package:flutter/material.dart';

import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';
import 'page_backdrop.dart';
import 'site_header.dart';

enum AppShellHeaderMode {
  /// No header chrome (home landing).
  none,

  /// [SiteNavBar] — Home / Quizzes.
  marketing,

  /// [SiteCompactHeader] — quiz flow title row.
  compact,
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.headerMode = AppShellHeaderMode.marketing,
    this.bottomInsetPadding = 16,
  });

  final Widget body;

  /// Used when [headerMode] is [AppShellHeaderMode.compact].
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final AppShellHeaderMode headerMode;
  final double bottomInsetPadding;

  @override
  Widget build(BuildContext context) {
    final maxW = context.jpQuizAppTokens.maxContentWidth;
    final width = MediaQuery.sizeOf(context).width;
    final phone = LayoutBreakpoints.isPhoneWidth(width);
    final horizontal = LayoutBreakpoints.pageHorizontalPadding(width);
    final topPadding = phone ? 8.0 : 12.0;
    final bottomPadding = phone
        ? bottomInsetPadding.clamp(10.0, 16.0).toDouble()
        : bottomInsetPadding;

    final double headerGap = switch (headerMode) {
      AppShellHeaderMode.none => 0,
      AppShellHeaderMode.marketing => phone ? 12 : 18,
      AppShellHeaderMode.compact => phone ? 8 : 12,
    };

    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (headerMode) {
          AppShellHeaderMode.none => const SizedBox.shrink(),
          AppShellHeaderMode.marketing => const SiteNavBar(),
          AppShellHeaderMode.compact => SiteCompactHeader(
            leading: leading,
            title: title ?? '',
            actions: actions ?? const [],
          ),
        },
        SizedBox(height: headerGap),
        Expanded(child: body),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  topPadding,
                  horizontal,
                  bottomPadding,
                ),
                child: inner,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
