# Powershell version of https://chromium.googlesource.com/chromium/src/+/master/docs/windows_build_instructions.md
# This script fetches v8
param (
    [string]$V8_VERSION = (&{If([string]::IsNullOrWhiteSpace($env:V8_VERSION)) {"7.4.288.25"} Else {$env:V8_VERSION}})
)

$path = "$PSScriptRoot\v8"
# Fixes fetch error "LookupError: unknown encoding: cp65001"
$env:PYTHONIOENCODING = "UTF-8"

If(!(test-path $path)) {
    New-Item -ItemType Directory -Force -Path $path
    Set-Location $path
    Write-Output "Fetching V8 sources..."
    $start_time = Get-Date
    fetch --no-history v8
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}
Else {
    Set-Location $path
}

Set-Location "$path\v8"
Write-Output "Syncing V8 sources..."
$start_time = Get-Date
Write-Output "Using V8 Version $V8_VERSION"
git checkout $V8_VERSION
cmd.exe /c "gclient sync -D"
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
Set-Location $PSScriptRoot