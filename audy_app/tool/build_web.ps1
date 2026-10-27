param([string]$ApiBaseUrl = $env:API_BASE_URL)
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..')
try {
    $flutterCommand = if ($env:FLUTTER_BIN) { $env:FLUTTER_BIN } else { 'flutter' }
    $flutterVersion = (& $flutterCommand --version --machine | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0 -or $flutterVersion.frameworkRevision -ne 'db50e20168db8fee486b9abf32fc912de3bc5b6a') {
        throw 'Use Flutter 3.41.6 (the SDK used by mobile development).'
    }
    $sqliteHash = (Get-FileHash -LiteralPath 'web/sqlite3.wasm' -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($sqliteHash -ne '3c611e38db0a2609c34a141ccf70c89b407b262c9bf06877c4ba213cf9f3624b') {
        throw 'SQLite WebAssembly checksum mismatch.'
    }
    & $flutterCommand pub get --enforce-lockfile
    if ($LASTEXITCODE -ne 0) { throw 'Dependency restore failed.' }
    $dartCommand = Join-Path (Split-Path (Get-Command $flutterCommand).Source) 'dart.bat'
    & $dartCommand compile js -O4 web/drift_worker.dart -o web/drift_worker.js
    if ($LASTEXITCODE -ne 0) { throw 'Database worker build failed.' }
    $webBuildArgs = @('build', 'web', '--release', '--no-wasm-dry-run', '--pwa-strategy=none',
        "--dart-define=API_BASE_URL=$ApiBaseUrl", '--dart-define=ENABLE_DEBUG_ACCOUNTS=false')
    if ($env:SUPABASE_URL) { $webBuildArgs += "--dart-define=SUPABASE_URL=$env:SUPABASE_URL" }
    if ($env:SUPABASE_PUBLISHABLE_KEY) { $webBuildArgs += "--dart-define=SUPABASE_PUBLISHABLE_KEY=$env:SUPABASE_PUBLISHABLE_KEY" }
    # Windows PowerShell 5 treats Flutter's stderr deprecation notice as an
    # error record when redirected. Use the actual process exit code.
    $ErrorActionPreference = 'Continue'
    & $flutterCommand @webBuildArgs
    $webBuildExit = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($webBuildExit -ne 0) { throw 'Web release build failed.' }
    & $dartCommand run tool/prepare_web_artifact.dart
    if ($LASTEXITCODE -ne 0) { throw 'Web artifact preparation failed.' }
    & $dartCommand run tool/verify_web_build.dart
    if ($LASTEXITCODE -ne 0) { throw 'Web artifact validation failed.' }
} finally { Pop-Location }
