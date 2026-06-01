import 'dart:io';

import 'package:path/path.dart' as p;

enum SparkleTool {
  generateKeys('generate_keys', 'generate_keys.bat'),
  signUpdate('sign_update', 'sign_update.bat');

  const SparkleTool(this.macosExecutable, this.windowsExecutable);

  final String macosExecutable;
  final String windowsExecutable;
}

class SparkleToolLookupException implements Exception {
  const SparkleToolLookupException({
    required this.tool,
    required this.searchedPaths,
  });

  final SparkleTool tool;
  final List<String> searchedPaths;

  @override
  String toString() {
    final paths = searchedPaths.map((path) => '  - $path').join('\n');
    return 'Could not find Sparkle ${tool.macosExecutable}.\n'
        'Looked in:\n'
        '$paths\n\n'
        'Run `flutter build macos` to fetch Sparkle with Swift Package '
        'Manager, run `pod install` to fetch Sparkle with CocoaPods, or set '
        'AUTO_UPDATER_SPARKLE_BIN to the directory containing Sparkle tools.';
  }
}

String sparkleToolExecutable(
  SparkleTool tool, {
  String? projectRoot,
  String? operatingSystem,
  Map<String, String>? environment,
}) {
  final currentOperatingSystem = operatingSystem ?? Platform.operatingSystem;
  final currentProjectRoot = projectRoot ?? Directory.current.path;

  if (currentOperatingSystem == 'macos') {
    return _macOSExecutable(
      tool,
      projectRoot: currentProjectRoot,
      environment: environment ?? Platform.environment,
    );
  }
  if (currentOperatingSystem == 'windows') {
    return _windowsExecutable(tool, currentProjectRoot);
  }
  throw UnsupportedError('auto_updater:${tool.macosExecutable}');
}

String _macOSExecutable(
  SparkleTool tool, {
  required String projectRoot,
  required Map<String, String> environment,
}) {
  final overrideBin = environment['AUTO_UPDATER_SPARKLE_BIN']?.trim();
  final searchedPaths = overrideBin == null || overrideBin.isEmpty
      ? <String>[
          p.join(
            projectRoot,
            'macos',
            'Pods',
            'Sparkle',
            'bin',
            tool.macosExecutable,
          ),
          p.join(
            projectRoot,
            'build',
            'macos',
            'SourcePackages',
            'artifacts',
            'sparkle',
            'Sparkle',
            'bin',
            tool.macosExecutable,
          ),
        ]
      : <String>[p.join(overrideBin, tool.macosExecutable)];

  for (final path in searchedPaths) {
    if (File(path).existsSync()) {
      return path;
    }
  }

  throw SparkleToolLookupException(tool: tool, searchedPaths: searchedPaths);
}

String _windowsExecutable(SparkleTool tool, String projectRoot) {
  return p.joinAll([
    projectRoot,
    'windows',
    'flutter',
    'ephemeral',
    '.plugin_symlinks',
    'auto_updater_windows',
    'windows',
    'WinSparkle-0.8.1',
    'bin',
    tool.windowsExecutable,
  ]);
}
