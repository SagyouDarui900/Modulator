param(
    [string]$Version = "v1.1"
)

$ErrorActionPreference = "Stop"

# ビルドスクリプトを実行
& "$PSScriptRoot\build-ModulatorCPU.ps1"

$releaseRoot = Join-Path $PSScriptRoot "release"
$distDir     = Join-Path $releaseRoot "Modulator"
$zipPath     = Join-Path $releaseRoot "Modulator-$Version.zip"

if (Test-Path $releaseRoot) {
    Remove-Item $releaseRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

Copy-Item (Join-Path $PSScriptRoot "Modulator.anm2") -Destination $distDir
Copy-Item (Join-Path $PSScriptRoot "Modulator.mod2") -Destination $distDir
Copy-Item (Join-Path $PSScriptRoot "README.md") -Destination $distDir
Copy-Item (Join-Path $PSScriptRoot "LICENSE") -Destination $distDir
Copy-Item (Join-Path $PSScriptRoot "Modulator_LICENSE.txt") -Destination $distDir

Compress-Archive -Path $distDir -DestinationPath $zipPath -Force
Remove-Item $distDir -Recurse -Force

Write-Host "Package created: $zipPath" -ForegroundColor Green
