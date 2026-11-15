param(
    [Parameter(Mandatory)]
    [ValidateSet('x64', 'ARM64')]
    [string] $Architecture,
    [Parameter(Mandatory)]
    [string] $OutputDirectory
)

$ErrorActionPreference = 'Stop'
$revision = 'a8986caf620262f7d4581b241436ceaa0cc9370f'
$source = Join-Path ([IO.Path]::GetTempPath()) ("auto-updater-winsparkle-" + [guid]::NewGuid())
$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)

function Invoke-BuildCommand([string] $Program, [string[]] $Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Program failed with exit code $LASTEXITCODE."
    }
}

try {
    Invoke-BuildCommand git @('clone', '--depth', '1', '--branch', 'v0.9.4',
        '-c', 'advice.detachedHead=false', '-c', 'core.autocrlf=false', '-c', 'core.longpaths=true',
        'https://github.com/vslavik/winsparkle.git', $source)
    Push-Location $source
    try {
        $head = git rev-parse HEAD
        if ($LASTEXITCODE -ne 0 -or $head -ne $revision) {
            throw "Expected WinSparkle revision $revision, found $head."
        }

        Invoke-BuildCommand git @('submodule', 'update', '--init', '--recursive', '--depth', '1')
        Invoke-BuildCommand git @('apply', (Join-Path $PSScriptRoot 'resolve-relative-enclosures.patch'))
        Invoke-BuildCommand nuget @('restore', 'WinSparkle.sln', '-NonInteractive')
        Invoke-BuildCommand msbuild @('-m', '-t:Build', '-p:Configuration=Release',
            "-p:Platform=$Architecture", 'WinSparkle.sln')

        $destination = Join-Path $output "$Architecture/Release"
        New-Item -ItemType Directory -Force $destination | Out-Null
        Copy-Item "$Architecture/Release/WinSparkle.dll" $destination
    } finally {
        Pop-Location
    }
} finally {
    if (Test-Path $source) {
        Remove-Item -LiteralPath $source -Recurse -Force
    }
}
