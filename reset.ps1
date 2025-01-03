# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if ($env:CI -ne 'true') {
    echo 'not on CI'
    exit 1
}

function Remove-Command {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$name
    )
    where.exe "$name" | ForEach-Object { Remove-Item "$_" }
}

function Unset-Environment {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$pattern
    )
    Get-ChildItem env:*$pattern* -Name | ForEach-Object { [Environment]::SetEnvironmentVariable("$_", $null, [EnvironmentVariableTarget]::Machine) }
}

function Assert-Not-Callable {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$name
    )
    try {
        where.exe "$name" *> $null
    }
    catch {
        return
    }
    throw
}

function Assert-Environment-Does-Not-Match {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$pattern
    )
    if (Test-Path -Path env:*$pattern*) {
        throw
    }
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
    Remove-Command "$name"
    Assert-Not-Callable "$name"
}

@"
    JAVA
    ANDROID
    Chocolately
"@.Split([Environment]::NewLine) | ForEach-Object {
    $pattern = $_.Trim()
    Unset-Environment "$pattern"
    Assert-Environment-Does-Not-Match "$pattern"
}
