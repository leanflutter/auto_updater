import 'dart:io';

import 'package:auto_updater/src/sparkle_tools.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sparkle_tools_test.');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File touch(List<String> segments) {
    final file = File(p.joinAll([tempDir.path, ...segments]));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('');
    return file;
  }

  group('macOS Sparkle tool resolution', () {
    test('uses AUTO_UPDATER_SPARKLE_BIN before dependency manager paths', () {
      final envTool = touch(['override', 'sign_update']);
      touch(['macos', 'Pods', 'Sparkle', 'bin', 'sign_update']);
      touch([
        'build',
        'macos',
        'SourcePackages',
        'artifacts',
        'sparkle',
        'Sparkle',
        'bin',
        'sign_update',
      ]);

      final executable = sparkleToolExecutable(
        SparkleTool.signUpdate,
        projectRoot: tempDir.path,
        operatingSystem: 'macos',
        environment: {'AUTO_UPDATER_SPARKLE_BIN': envTool.parent.path},
      );

      expect(executable, envTool.path);
    });

    test('uses the CocoaPods Sparkle tool path when it exists', () {
      final podTool = touch([
        'macos',
        'Pods',
        'Sparkle',
        'bin',
        'generate_keys',
      ]);

      final executable = sparkleToolExecutable(
        SparkleTool.generateKeys,
        projectRoot: tempDir.path,
        operatingSystem: 'macos',
        environment: const {},
      );

      expect(executable, podTool.path);
    });

    test('uses the SwiftPM Sparkle artifact path when it exists', () {
      final swiftPackageTool = touch([
        'build',
        'macos',
        'SourcePackages',
        'artifacts',
        'sparkle',
        'Sparkle',
        'bin',
        'sign_update',
      ]);

      final executable = sparkleToolExecutable(
        SparkleTool.signUpdate,
        projectRoot: tempDir.path,
        operatingSystem: 'macos',
        environment: const {},
      );

      expect(executable, swiftPackageTool.path);
    });

    test('throws an actionable error when the Sparkle tool is missing', () {
      expect(
        () => sparkleToolExecutable(
          SparkleTool.generateKeys,
          projectRoot: tempDir.path,
          operatingSystem: 'macos',
          environment: const {},
        ),
        throwsA(
          isA<SparkleToolLookupException>()
              .having(
                (error) => error.toString(),
                'message',
                contains('Could not find Sparkle generate_keys'),
              )
              .having(
                (error) => error.toString(),
                'build hint',
                contains('flutter build macos'),
              )
              .having(
                (error) => error.toString(),
                'override hint',
                contains('AUTO_UPDATER_SPARKLE_BIN'),
              ),
        ),
      );
    });
  });

  test('keeps the Windows WinSparkle path unchanged', () {
    final executable = sparkleToolExecutable(
      SparkleTool.signUpdate,
      projectRoot: tempDir.path,
      operatingSystem: 'windows',
      environment: const {},
    );

    expect(
      executable,
      p.joinAll([
        tempDir.path,
        'windows',
        'flutter',
        'ephemeral',
        '.plugin_symlinks',
        'auto_updater_windows',
        'windows',
        'WinSparkle-0.8.1',
        'bin',
        'sign_update.bat',
      ]),
    );
  });
}
