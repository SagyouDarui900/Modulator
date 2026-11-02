$ErrorActionPreference = "Stop"

# 1. Search aviutl2_sdk
$sdk = $null
if ($env:AVIUTL2_SDK -and (Test-Path (Join-Path $env:AVIUTL2_SDK "filter2.h"))) {
    $sdk = $env:AVIUTL2_SDK
}

if (-not $sdk) {
    $searchRoots = @(
        $PSScriptRoot,
        (Split-Path $PSScriptRoot -Parent),
        (Join-Path $env:USERPROFILE "Documents")
    )
    foreach ($root in $searchRoots) {
        if (Test-Path $root) {
            $found = Get-ChildItem -LiteralPath $root -Directory -Recurse -Filter "aviutl2_sdk" -ErrorAction SilentlyContinue |
                     Where-Object { Test-Path (Join-Path $_.FullName "filter2.h") } |
                     Select-Object -First 1
            if ($found) {
                $sdk = $found.FullName
                break
            }
        }
    }
}

if (-not $sdk) {
    throw "aviutl2_sdk was not found. Please set the AVIUTL2_SDK environment variable."
}

Write-Host "Using aviutl2_sdk at: $sdk" -ForegroundColor Cyan

# 2. Check cl.exe and load Visual Studio environment if necessary
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    $vcvars = $null
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($vsPath) {
            $candidate = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
            if (Test-Path $candidate) { $vcvars = $candidate }
        }
    }

    if ($vcvars) {
        Write-Host "Setting up MSVC environment using: $vcvars" -ForegroundColor Cyan
        $tempScript = [System.IO.Path]::GetTempFileName() + ".cmd"
        "@echo off`r`ncall `"$vcvars`" > nul`r`nset" | Out-File -FilePath $tempScript -Encoding ascii
        cmd.exe /c $tempScript | ForEach-Object {
            if ($_ -match '^(.*?)=(.*)$') {
                [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
            }
        }
        Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    throw "cl.exe was not found. Please run this script in a Visual Studio x64 command prompt or install Visual Studio C++ build tools."
}

$source = Join-Path $PSScriptRoot "Modulator.cpp"
$output = Join-Path $PSScriptRoot "Modulator.mod2"
$build  = Join-Path $env:TEMP "ModulatorBuild"

New-Item -ItemType Directory -Path $build -Force | Out-Null

try {
    # Compile with /O2 (Max speed), /Oi (Intrinsic functions), /Gy (Function-level linking), /openmp (OpenMP)
    & cl.exe /nologo /std:c++17 /EHsc /utf-8 /FIstdint.h /DUNICODE /D_UNICODE /O2 /Oi /Gy /openmp /LD `
        ("/I" + $sdk) `
        ("/Fo" + "$build\Modulator.obj") `
        $source `
        /link `
        /OPT:REF /OPT:ICF `
        ("/OUT:" + "$build\Modulator.mod2") `
        ("/IMPLIB:" + "$build\Modulator.lib")

    if ($LASTEXITCODE -ne 0) {
        throw "Modulator.mod2 build failed."
    }

    Copy-Item -LiteralPath "$build\Modulator.mod2" -Destination $output -Force
    Write-Host "Build succeeded -> $output" -ForegroundColor Green
}
finally {
    Remove-Item -LiteralPath $build -Recurse -Force -ErrorAction SilentlyContinue
}
