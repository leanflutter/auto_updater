import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        input.config.code.targetOS != OS.macOS) {
      return;
    }

    // FFIgen's Objective-C helpers use the Dart library URI as their asset ID.
    await CBuilder.library(
      name: 'sparkle_ffi',
      assetName: 'src/sparkle_bindings.g.dart',
      sources: ['src/sparkle_bindings.g.m'],
      includes: ['src/include'],
      frameworks: ['Foundation'],
      flags: ['-fobjc-arc'],
    ).run(input: input, output: output);
  });
}
