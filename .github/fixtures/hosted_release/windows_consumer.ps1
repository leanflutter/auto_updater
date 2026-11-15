param(
    [Parameter(Mandatory)][ValidateSet('x64', 'arm64')][string] $Architecture,
    [Parameter(Mandatory)][string] $ArchiveDirectory
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$archives = (Resolve-Path $ArchiveDirectory).Path
$workspace = Join-Path $env:RUNNER_TEMP 'hosted-updater-test'
$project = Join-Path $workspace 'consumer'
New-Item -ItemType Directory -Path $workspace | Out-Null
$portFile = Join-Path $workspace 'registry-port'
$registryScript = Join-Path $PSScriptRoot 'registry.py'
$registry = Start-Process -FilePath (Get-Command python).Source -PassThru `
    -ArgumentList ('"{0}" "{1}" "{2}"' -f $registryScript, $archives, $portFile) `
    -RedirectStandardOutput (Join-Path $workspace 'registry.out') `
    -RedirectStandardError (Join-Path $workspace 'registry.err')

Push-Location $workspace
try {
    for ($attempt = 0; $attempt -lt 50 -and !(Test-Path $portFile); $attempt++) {
        if ($registry.HasExited) { throw 'The loopback package registry exited.' }
        Start-Sleep -Milliseconds 200
    }
    $env:PUB_HOSTED_URL = 'http://127.0.0.1:' + (Get-Content -Raw $portFile).Trim()
    $env:PUB_CACHE = Join-Path $workspace 'pkg-cache'
    flutter create --no-pub --platforms=windows --org dev.leanflutter.hosted --project-name hosted_updater_fixture $project
    if ($LASTEXITCODE -ne 0) { throw 'Could not generate the Flutter Windows project.' }

    $guide = Get-Content -Raw (Join-Path $repo 'docs/en/quick-start.md')
    $core = [regex]::Match($guide, '(?m)^  auto_updater: (\^\d+\.\d+\.\d+)').Groups[1].Value
    $windows = [regex]::Match($guide, '(?m)^  auto_updater_winsparkle: (\^\d+\.\d+\.\d+)').Groups[1].Value
    if (!$core -or !$windows) { throw 'The quick-start does not contain hosted version constraints.' }
    @"
name: hosted_updater_fixture
description: Clean Windows consumer for the auto updater release.
publish_to: none
version: 1.0.0+1
environment:
  sdk: ^3.14.0
dependencies:
  flutter:
    sdk: flutter
  auto_updater: $core
  auto_updater_winsparkle: $windows
"@ | Set-Content -Encoding utf8NoBOM (Join-Path $project 'pubspec.yaml')

    Set-Location $project
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Could not resolve the published packages.' }
    if (Test-Path 'pubspec_overrides.yaml') { throw 'The hosted project has dependency overrides.' }
    $config = Get-Content -Raw '.dart_tool/package_config.json' | ConvertFrom-Json
    foreach ($name in @('auto_updater', 'auto_updater_platform_interface', 'auto_updater_winsparkle', 'winsparkle')) {
        $package = $config.packages | Where-Object name -eq $name
        if ($package.rootUri -notmatch "/hosted/[^/]+/$name-") {
            throw "Package $name did not come from the hosted cache."
        }
        Write-Host "Resolved $name from $($package.rootUri)"
    }
    $plugins = Get-Content -Raw '.flutter-plugins-dependencies' | ConvertFrom-Json
    if ($plugins.plugins.windows.name -notcontains 'auto_updater_winsparkle') {
        throw 'Flutter did not register the hosted WinSparkle plugin.'
    }

    $env:PATH = (Join-Path $env:ProgramFiles 'Git/usr/bin') + ';' + $env:PATH
    dart run auto_updater:generate_keys
    if ($LASTEXITCODE -ne 0 -or !(Test-Path 'dsa_pub.pem') -or !(Test-Path 'dsa_priv.pem')) {
        throw 'The hosted Windows generate_keys command did not generate both keys.'
    }
    Add-Content -Path 'windows/runner/Runner.rc' -Value ([Environment]::NewLine + 'DSAPub DSAPEM "../../dsa_pub.pem"')

    $runnerFile = 'windows/runner/main.cpp'
    $runner = Get-Content -Raw $runnerFile
    $end = '  ::CoUninitialize();'
    if ([regex]::Matches($runner, [regex]::Escape($end)).Count -ne 1) {
        throw 'The generated runner cleanup changed.'
    }
    $runner.Replace($end, "  window.Destroy();`r`n$end") | Set-Content -Encoding utf8NoBOM $runnerFile
    Copy-Item (Join-Path $PSScriptRoot 'windows_consumer.dart') 'lib/main.dart'

    $wixDir = Join-Path $workspace 'wix'
    dotnet tool install wix --version 5.0.2 --tool-path $wixDir
    if ($LASTEXITCODE -ne 0) { throw 'Could not install WiX for the test fixtures.' }
    foreach ($version in @('1.0.0', '2.0.0')) {
        $markerPath = Join-Path $workspace "version-$version.txt"
        Set-Content -LiteralPath $markerPath -Value $version
        & (Join-Path $wixDir 'wix.exe') build -arch $Architecture -d "Version=$version" -d "Marker=$markerPath" `
            (Join-Path $PSScriptRoot 'msi-update.wxs') -o (Join-Path $workspace "fixture-$version.msi")
        if ($LASTEXITCODE -ne 0) { throw "Could not build MSI $version." }
    }

    $env:TEST_MSI_PATH = Join-Path $workspace 'fixture-2.0.0.msi'
    $signature = (dart run auto_updater:sign_update $env:TEST_MSI_PATH 'dsa_priv.pem' | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $signature -notmatch '^sparkle:dsaSignature="([A-Za-z0-9+/=]+)" length="(\d+)"$') {
        throw 'The hosted Windows sign_update command did not produce a DSA signature and length.'
    }
    $env:TEST_MSI_SIGNATURE = $Matches[1]
    if ([long]$Matches[2] -ne (Get-Item $env:TEST_MSI_PATH).Length) {
        throw 'The hosted Windows sign_update command reported an incorrect file length.'
    }
    Write-Host 'Hosted generate_keys and sign_update produced the application key and exact MSI length.'
    Remove-Item -LiteralPath 'dsa_priv.pem'

    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'The fresh Windows Release build failed.' }
    $release = (Resolve-Path "build/windows/$Architecture/runner/Release").Path
    if (!(Test-Path (Join-Path $release 'WinSparkle.dll')) -or !(Test-Path (Join-Path $release 'auto_updater_winsparkle_plugin.dll'))) {
        throw 'The installed hosted package did not bundle both updater libraries.'
    }

    $baseline = Join-Path $workspace 'fixture-1.0.0.msi'
    $setup = Start-Process msiexec.exe -PassThru -Wait -ArgumentList ('/i "{0}" /qn /norestart' -f $baseline)
    $installed = Join-Path $env:LOCALAPPDATA 'LeanFlutterMsiFixture/version.txt'
    if ($setup.ExitCode -ne 0 -or (Get-Content $installed) -ne '1.0.0') {
        throw "The baseline MSI did not install. Exit code $($setup.ExitCode)."
    }
    $env:TEST_MSI_LOG = Join-Path $workspace 'update-msi.log'
    $stdout = Join-Path $workspace 'app.out'
    $stderr = Join-Path $workspace 'app.err'
    $app = Start-Process -WorkingDirectory $release -PassThru (Join-Path $release 'hosted_updater_fixture.exe') `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    if (!$app.WaitForExit(55000)) {
        $app.Kill()
        throw 'The hosted Flutter project did not exit.'
    }
    $app.WaitForExit()
    Get-Content $stdout, $stderr -ErrorAction SilentlyContinue
    $result = Get-Content (Join-Path $release 'hosted-updater.result') -Raw
    Write-Host $result
    Write-Host "Hosted Flutter project exit code: $($app.ExitCode)"
    if ($app.ExitCode -ne 0 -or $result -notmatch '^Hosted packages delivered available, downloaded, and shutdown\.') {
        throw 'The hosted application did not complete its native update callbacks.'
    }
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        # A major upgrade removes the old marker before installing the new one.
        $installedVersion = Get-Content -LiteralPath $installed -ErrorAction SilentlyContinue
        if ($installedVersion -eq '2.0.0' -and
            (Select-String -LiteralPath $env:TEST_MSI_LOG -Pattern 'Installation success or error status: 0' -Quiet -ErrorAction SilentlyContinue)) {
            Write-Host "Windows Installer upgraded the DSA-signed hosted consumer fixture to 2.0.0 ($Architecture)."
            exit 0
        }
        Start-Sleep -Seconds 1
    }
    throw 'The hosted application exited, but Windows Installer did not finish upgrading the MSI.'
} catch {
    if ($env:TEST_MSI_LOG -and (Test-Path $env:TEST_MSI_LOG)) {
        Get-Content $env:TEST_MSI_LOG -Tail 50
    }
    if (Test-Path (Join-Path $workspace 'registry.err')) {
        Get-Content (Join-Path $workspace 'registry.err') -Tail 12
    }
    throw
} finally {
    Pop-Location
    if (!$registry.HasExited) { Stop-Process -Id $registry.Id }
}
