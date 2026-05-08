import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Web-safe preload for theme fonts so kanji/Latin do not flash as placeholder blocks.
Future<void> preloadHomeFonts() {
  if (!kIsWeb) {
    return Future<void>.value();
  }
  return GoogleFonts.pendingFonts([
    GoogleFonts.inter(fontWeight: FontWeight.w400),
    GoogleFonts.inter(fontWeight: FontWeight.w500),
    GoogleFonts.inter(fontWeight: FontWeight.w600),
    GoogleFonts.inter(fontWeight: FontWeight.w700),
    GoogleFonts.notoSansJp(fontWeight: FontWeight.w400),
    GoogleFonts.notoSansJp(fontWeight: FontWeight.w500),
    GoogleFonts.notoSansJp(fontWeight: FontWeight.w600),
    GoogleFonts.notoSansJp(fontWeight: FontWeight.w700),
    GoogleFonts.notoSansJp(fontWeight: FontWeight.w900),
  ]);
}
