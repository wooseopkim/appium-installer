# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if ($env:CI -ne 'true') {
    exit 1
}

function Remove-Command {
    param (
        $name
    )
    where.exe "$name" | ForEach-Object { Remove-Item $_ }
}

function Unset-Environment {
    param (
        $pattern
    )
    Get-ChildItem env:*$pattern* -Name | ForEach-Object { [Environment]::SetEnvironmentVariable($_, $null, [EnvironmentVariableTarget]::Machine) }
}

function Ensure-Not-Callable {
    param (
        $name
    )
    where.exe "$name" *> $null
    -Not $?
}

function Ensure-Environment-Empty {
    param (
        $pattern
    )
    -Not (Test-Path -Path env:*$pattern*)
}

@"
    sdkmanager
    avdmanager
    java
    gradle
    node
    npm
    python
    appium
    choco
"@.Split([Environment]::NewLine) | ForEach-Object {
    $name = $_.Trim()
    Remove-Command $name
    Ensure-Not-Callable $name
}

@"
    JAVA
    ANDROID
    Chocolately
"@.Split([Environment]::NewLine) | ForEach-Object {
    $pattern = $_.Trim()
    Unset-Environment $pattern
    Ensure-Environment-Empty $pattern
}
