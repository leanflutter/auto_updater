import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../bin/src/sparkle.dart';

void main() {
  late Directory project;

  setUp(() {
    project = Directory.systemTemp.createTempSync('auto_updater_');
  });

  tearDown(() {
    project.deleteSync(recursive: true);
  });

  test('finds the tool installed by SwiftPM in a Flutter build', () {
    final tool = File(
      p.joinAll([
        project.path,
        'build',
        'macos',
        'SourcePackages',
        'artifacts',
        'sparkle',
        'Sparkle',
        'bin',
        'generate_keys',
      ]),
    )..createSync(recursive: true);

    expect(
      findSparkleTool('generate_keys', projectDirectory: project.path),
      tool.path,
    );
  });

  test(
    'falls back to the CocoaPods tool when SwiftPM artifacts are absent',
    () {
      final tool = File(
        p.join(project.path, 'macos', 'Pods', 'Sparkle', 'bin', 'sign_update'),
      )..createSync(recursive: true);

      expect(
        findSparkleTool('sign_update', projectDirectory: project.path),
        tool.path,
      );
    },
  );

  test('accepts a custom Sparkle bin directory', () {
    final tool = File(p.join(project.path, 'custom tools', 'sign_update'))
      ..createSync(recursive: true);

    expect(
      findSparkleTool(
        'sign_update',
        projectDirectory: project.path,
        binDirectory: tool.parent.path,
      ),
      tool.path,
    );
  });
}
