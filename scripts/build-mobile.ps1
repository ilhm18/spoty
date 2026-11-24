$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$distDir = Join-Path $projectRoot "dist"
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$goCommand = Get-Command go -ErrorAction SilentlyContinue
if (-not $goCommand) {
    $goCommand = Get-Command "C:\Program Files\Go\bin\go.exe" -ErrorAction SilentlyContinue
}
if (-not $goCommand) {
    throw "Go is not installed or not available in PATH"
}

$env:CGO_ENABLED = "0"
$env:GOOS = "android"
$env:GOARCH = "arm64"

Push-Location $projectRoot
try {
    & $goCommand.Source build -o (Join-Path $distDir "spicetify-mobile-android-arm64") .
} finally {
    Pop-Location
    Remove-Item Env:CGO_ENABLED -ErrorAction SilentlyContinue
    Remove-Item Env:GOOS -ErrorAction SilentlyContinue
    Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
}

Write-Host "Built: $distDir\spicetify-mobile-android-arm64"
