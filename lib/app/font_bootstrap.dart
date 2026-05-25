/// Legacy font preload hook.
///
/// Startup now uses local platform font fallbacks so first paint is not gated on
/// remote Google Font requests.
Future<void> preloadAppFonts() => Future<void>.value();

/// Kept for older call sites that only need to express home readiness.
Future<void> preloadHomeFonts() => preloadAppFonts();
