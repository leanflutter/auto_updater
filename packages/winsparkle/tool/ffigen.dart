import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final root = Uri.base;
  final headers = root.resolve('tool/WinSparkle/');

  await FfiGenerator(
    input: Input(
      entryPoints: [headers.resolve('winsparkle.h')],
      include: (header) => header.path.startsWith(headers.path),
      compilerOptions: [
        '--target=x86_64-pc-windows-msvc',
        '-I${root.resolve('tool/include/').toFilePath()}',
      ],
    ),
    output: Output(
      dart: DartOutput(
        path: root.resolve('lib/src/winsparkle_bindings.g.dart'),
      ),
      style: const DynamicLibraryBindings(wrapperName: 'WinSparkle'),
      preamble: '// Regenerate with: dart run tool/ffigen.dart',
    ),
    visitors: [
      Visitor(
        func: (node) =>
            node.isIncluded = node.originalName.startsWith('win_sparkle_'),
        struct: (node) => node.isIncluded =
            node.originalName == 'win_sparkle_config_methods_tag',
        typealias: (node) {
          if (node.originalName.startsWith('win_sparkle_')) {
            node.isIncluded = TypealiasInclude.always;
          }
        },
        macroConstant: (node) => node.isIncluded =
            node.originalName.startsWith('WIN_SPARKLE_VERSION_') ||
            node.originalName == 'WINSPARKLE_RETURN_ERROR',
      ),
    ],
  ).generate();
}
