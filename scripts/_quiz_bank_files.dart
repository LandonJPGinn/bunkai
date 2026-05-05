// Shared helpers for scripts that read assets/quiz_banks/*.json.
//
// Pure Dart — does not import package:flutter.

import 'dart:io';

/// Resolves the repo's `assets/quiz_banks/` directory from [Platform.script],
/// independent of the current working directory.
///
/// Assumes scripts live one level under the repo root (e.g. `scripts/foo.dart`).
Directory resolveQuizBankDir() {
  final scriptFile = File.fromUri(Platform.script);
  final repoRoot = scriptFile.parent.parent;
  return Directory('${repoRoot.path}/assets/quiz_banks');
}

/// Returns all `.json` files under [dir], sorted by filename for stable output.
List<File> listQuizBankJsonFiles(Directory dir) {
  if (!dir.existsSync()) {
    throw FileSystemException('quiz banks directory not found', dir.path);
  }
  final files = dir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.json'))
      .toList();
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

/// Renders [file] as a repo-relative path when possible (for nicer log output).
String relativePath(File file) {
  final cwd = Directory.current.path.replaceAll('\\', '/');
  final p = file.path.replaceAll('\\', '/');
  if (p.startsWith('$cwd/')) return p.substring(cwd.length + 1);
  return p;
}
