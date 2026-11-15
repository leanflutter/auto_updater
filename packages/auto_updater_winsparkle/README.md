# auto_updater_winsparkle

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater_winsparkle.svg
[pub-url]: https://pub.dev/packages/auto_updater_winsparkle

The WinSparkle implementation of [auto_updater](https://pub.dev/packages/auto_updater) for Windows.
Add both packages to your app's `pubspec.yaml` to use this implementation.

## Bundled WinSparkle

The x64 and ARM64 DLLs are built from WinSparkle 0.9.4 with a patch that
resolves relative enclosure URLs. To rebuild one of the DLLs, run this from
the package directory on Windows with Git, NuGet, and Visual Studio 2022
MSBuild available:

```powershell
./tool/build_winsparkle.ps1 -Architecture x64 -OutputDirectory windows/WinSparkle-0.9.4
```

Use `-Architecture ARM64` for the Arm64 DLL.

## License

[MIT](./LICENSE)
