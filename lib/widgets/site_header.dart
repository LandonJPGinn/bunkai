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

class _BrandMark extends StatefulWidget {
  const _BrandMark({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<_BrandMark> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final fast = reduceMotion ? Duration.zero : t.motionFast;
    final curve = t.motionStandardCurve;
    final accent = _hover ? t.accent : t.accent.withValues(alpha: 0.9);
    final wordmark = _hover ? t.textStrong : t.textStrong.withValues(alpha: 0.92);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: fast,
                  curve: curve,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: accent,
                  ),
                  child: Text(t.brandMark),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: fast,
                  curve: curve,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: wordmark,
                  ),
                  child: const Text('BunKai'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatefulWidget {
  const _NavPill({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final fast = reduceMotion ? Duration.zero : t.motionFast;
    final curve = t.motionStandardCurve;
    final selected = widget.selected;

    final Color background;
    if (selected) {
      background = t.accentSoft;
    } else if (_hover) {
      background = t.accentSoft.withValues(alpha: 0.45);
    } else {
      background = Colors.transparent;
    }

    final Color textColor;
    if (selected) {
      textColor = t.accent;
    } else if (_hover) {
      textColor = t.textStrong;
    } else {
      textColor = t.textMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: fast,
        curve: curve,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: AnimatedDefaultTextStyle(
                duration: fast,
                curve: curve,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
                child: Text(widget.label),
              ),
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
