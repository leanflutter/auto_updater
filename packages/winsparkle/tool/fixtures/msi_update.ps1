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
    $wixArgs = @('build', '-arch', 'x64', '-d', "Version=$version", '-d', "Marker=$versionPath",
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
$root = Resolve-Path (Join-Path $PSScriptRoot '../..')
$dll = Resolve-Path (Join-Path $root '../auto_updater_winsparkle/windows/WinSparkle-0.9.4/x64/Release/WinSparkle.dll')
Push-Location $root
try {
    dart run tool/fixtures/msi_update.dart $dll.Path
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
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
