param(
    [Parameter(Mandatory)][string] $ReleaseDirectory,
    [Parameter(Mandatory)][ValidateSet('x64', 'arm64')][string] $Architecture
)

$ErrorActionPreference = 'Stop'
$fixture = Join-Path $env:RUNNER_TEMP 'winsparkle-msi'
New-Item -Type Directory -Force $fixture | Out-Null
$tool = Join-Path $fixture 'wix'
dotnet tool install wix --version 5.0.2 --tool-path $tool
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$marker = Join-Path $env:LOCALAPPDATA 'LeanFlutterMsiFixture/version.txt'
foreach ($version in @('1.0.0', '2.0.0')) {
    $versionPath = Join-Path $fixture "version-$version.txt"
    $msi = Join-Path $fixture "fixture-$version.msi"
    Set-Content -Path $versionPath -Value $version
    $wixArgs = @('build', '-arch', $Architecture, '-d', "Version=$version", '-d', "Marker=$versionPath",
        (Join-Path $PSScriptRoot 'msi-update.wxs'), '-o', $msi)
    & (Join-Path $tool 'wix.exe') @wixArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$baseline = Join-Path $fixture 'fixture-1.0.0.msi'
$install = Start-Process msiexec.exe -PassThru -Wait -ArgumentList ('/i "{0}" /qn /norestart' -f $baseline)
if ($install.ExitCode -ne 0 -or !(Test-Path $marker) -or (Get-Content $marker) -ne '1.0.0') {
    throw "Installing the MSI fixture baseline failed with exit code $($install.ExitCode)."
}

$openssl = Join-Path $env:ProgramFiles 'Git/usr/bin/openssl.exe'
$key = Join-Path $fixture 'test-key.pem'
$public = Join-Path $fixture 'test-key.der'
$signature = Join-Path $fixture 'update.sig'
$env:CODEX_MSI_PATH = Join-Path $fixture 'fixture-2.0.0.msi'
& $openssl genpkey -algorithm Ed25519 -out $key
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $openssl pkey -in $key -pubout -outform DER -out $public
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $openssl pkeyutl -sign -inkey $key -rawin -in $env:CODEX_MSI_PATH -out $signature
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Remove-Item -LiteralPath $key
$publicDer = [IO.File]::ReadAllBytes($public)
$env:CODEX_MSI_PUBLIC = [Convert]::ToBase64String($publicDer, $publicDer.Length - 32, 32)
$env:CODEX_MSI_SIGNATURE = [Convert]::ToBase64String([IO.File]::ReadAllBytes($signature))
$env:CODEX_MSI_LOG = Join-Path $fixture 'upgrade.log'
$appPath = Join-Path $ReleaseDirectory 'auto_updater_example.exe'
$app = Start-Process -WorkingDirectory $ReleaseDirectory -PassThru $appPath
if (!$app.WaitForExit(55000)) {
    $app.Kill()
    throw 'Timed out waiting for the Flutter app to exit.'
}
$message = Get-Content (Join-Path $ReleaseDirectory 'msi-integration.result') -Raw
Write-Host $message
if ($app.ExitCode -ne 0) { exit $app.ExitCode }
if ($message -notmatch 'The shipped example received a shutdown request') {
    throw 'The Flutter example quit before receiving the updater request.'
}
for ($attempt = 0; $attempt -lt 30; $attempt++) {
    if ((Test-Path $marker) -and ((Get-Content $marker) -eq '2.0.0')) {
        Write-Host 'Windows Installer upgraded the signed WinSparkle MSI fixture to 2.0.0.'
        exit 0
    }
    Start-Sleep -Seconds 1
}
if (Test-Path $env:CODEX_MSI_LOG) { Get-Content $env:CODEX_MSI_LOG -Tail 80 }
throw 'WinSparkle requested shutdown but the MSI fixture did not upgrade.'
