import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app_router.dart';
import '../app/bunkai_tokens.dart';

/// Top marketing rail: brand + Home / Quizzes.
class SiteNavBar extends StatelessWidget {
  const SiteNavBar({super.key});

  String? _routeName(BuildContext context) =>
      ModalRoute.of(context)?.settings.name;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    final route = _routeName(context);
    final onHome = route == AppRoutes.home;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: t.borderSoft),
        boxShadow: t.shadowSoft,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 480;
          final row = Row(
            children: [
              _BrandMark(
                onTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
              ),
              if (!narrow) const Spacer(),
              if (narrow) const SizedBox(width: 8),
              _NavPill(
                label: 'Home',
                selected: onHome,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
              ),
              const SizedBox(width: 6),
              _NavPill(
                label: 'Quizzes',
                selected: false,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (_) => false,
                  arguments: const HomeRouteArgs(scrollToQuizzes: true),
                ),
              ),
            ],
          );
          if (narrow) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: c.maxWidth),
                child: row,
              ),
            );
          }
          return row;
        },
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.brandMark,
                style: GoogleFonts.notoSansJp(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: t.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'BunKai',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: t.textStrong,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    return Material(
      color: selected ? t.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? t.accent : t.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Smaller header for quiz flow: back/close, title, actions.
class SiteCompactHeader extends StatelessWidget {
  const SiteCompactHeader({
    super.key,
    this.leading,
    required this.title,
    this.actions = const [],
  });

  final Widget? leading;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: t.surface2.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderSoft),
        boxShadow: t.shadowSoft,
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: title.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: t.textMain,
                    ),
                  ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
