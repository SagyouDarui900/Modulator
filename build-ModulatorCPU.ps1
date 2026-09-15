$ErrorActionPreference = "Stop"

$sdk = (Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE "Documents") -Directory -Recurse -Filter "aviutl2_sdk" | Select-Object -First 1).FullName
$source = Join-Path $PSScriptRoot "Modulator.cpp"
$output = Join-Path $PSScriptRoot "Modulator.mod2"
$build = Join-Path $env:TEMP "ModulatorBuild"

if (-not $sdk) {
    throw "aviutl2_sdk was not found below Documents."
}

New-Item -ItemType Directory -Path $build -Force | Out-Null

try {
    & cl.exe /nologo /std:c++17 /EHsc /LD `
        ("/I" + $sdk) `
        ("/Fo" + "$build\Modulator.obj") `
        $source `
        /link `
        ("/OUT:" + "$build\Modulator.mod2") `
        ("/IMPLIB:" + "$build\Modulator.lib")

    if ($LASTEXITCODE -ne 0) {
        throw "Modulator.mod2 build failed."
    }

    Copy-Item -LiteralPath "$build\Modulator.mod2" -Destination $output -Force
}
finally {
    Remove-Item -LiteralPath $build -Recurse -Force -ErrorAction SilentlyContinue
}
