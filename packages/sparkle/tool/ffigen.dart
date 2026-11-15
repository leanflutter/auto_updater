import 'package:ffigen/ffigen.dart';

final _sparkleName = RegExp(r'^(SPU|SU)[A-Z]');
// URL requests are used by Sparkle's download delegate. Include their SDK
// enum declarations so FFIgen can see the fixed types in the API graph.
const _foundationHeaders = {
  'NSItemProvider.h',
  'NSObjCRuntime.h',
  'NSStream.h',
  'NSURL.h',
  'NSURLHandle.h',
  'NSURLRequest.h',
};

Future<void> main() async {
  final root = Uri.base;
  final headers = root.resolve('src/include/');
  final headerDir = headers.resolve('Sparkle/');

  await FfiGenerator(
    input: Input(
      entryPoints: [headerDir.resolve('Sparkle.h')],
      include: (header) =>
          header.path.startsWith(headerDir.path) ||
          _foundationHeaders.any((name) => header.path.endsWith('/$name')),
      appendCompilerOptions: true,
      compilerOptions: ['-I${headers.toFilePath()}'],
    ),
    objectiveC: const ObjectiveC(),
    output: Output(
      dart: DartOutput(path: root.resolve('lib/src/sparkle_bindings.g.dart')),
      objectiveCFile: root.resolve('src/sparkle_bindings.g.m'),
      style: const DynamicLibraryBindings(wrapperName: 'SparkleBindings'),
      preamble: '// Regenerate using the command in README.md.',
    ),
    visitors: [
      Visitor(
        objCInterface: (node) {
          final name = node.originalName;
          node.isIncluded =
              (_sparkleName.hasMatch(name) && name != 'SUUpdater') ||
              name == 'NSURLRequest' ||
              name == 'NSMutableURLRequest';
          node.includeCategories = false;
        },
        objCProtocol: (node) => node.isIncluded =
            _sparkleName.hasMatch(node.originalName) &&
            node.originalName != 'SUUpdaterDelegate',
        objCMethod: (node) {
          // FFIgen cannot generate ARC callback shims for this deprecated
          // selector's two Objective-C out parameters.
          if (node.parent.originalName == 'SUVersionDisplay' &&
              node.selector == 'formatVersion:andVersion:') {
            node.isIncluded = false;
          }
        },
        enumClass: (node) {
          node.isIncluded = _sparkleName.hasMatch(node.originalName);
          // Sparkle and these Foundation types use fixed-width enum backing
          // types on both supported macOS architectures.
          node.silenceWarning =
              node.isIncluded ||
              node.originalName == 'NSItemProviderRepresentationVisibility' ||
              node.originalName == 'NSComparisonResult' ||
              node.originalName == 'NSStreamEvent' ||
              node.originalName == 'NSStreamStatus' ||
              node.originalName.startsWith('NSURL');
        },
        global: (node) => node.isIncluded = const {
          'SUSparkleErrorDomain',
          'SPUNoUpdateFoundReasonKey',
          'SPULatestAppcastItemFoundKey',
          'SPUNoUpdateFoundUserInitiatedKey',
        }.contains(node.originalName),
      ),
    ],
  ).generate();
}
