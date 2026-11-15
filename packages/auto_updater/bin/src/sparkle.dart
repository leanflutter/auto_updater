import 'dart:io';

import 'package:path/path.dart' as p;

String findWinSparkleTool(String name) => p.joinAll([
  Directory.current.path,
  'windows',
  'flutter',
  'ephemeral',
  '.plugin_symlinks',
  'auto_updater_windows',
  'windows',
  'WinSparkle-0.9.4',
  'bin',
  'legacy_$name.bat',
]);

String findSparkleTool(
  String name, {
  String? projectDirectory,
  String? binDirectory,
}) {
  final binDirectories = [
    if (binDirectory != null && binDirectory.isNotEmpty)
      binDirectory
    else ...[
      p.joinAll([
        'build',
        'macos',
        'SourcePackages',
        'artifacts',
        'sparkle',
        'Sparkle',
        'bin',
      ]),
      p.join('macos', 'Pods', 'Sparkle', 'bin'),
    ],
  ];

  for (final directory in binDirectories) {
    final executable = p.absolute(
      projectDirectory ?? Directory.current.path,
      directory,
      name,
    );
    if (File(executable).existsSync()) {
      return executable;
    }
  }

  throw FileSystemException(
    'Could not find the Sparkle tool $name. Build the macOS app first or set '
    'SPARKLE_BIN_DIR to the directory containing the Sparkle tools.',
  );
}
