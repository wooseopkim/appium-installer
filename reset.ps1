# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

if ($env:CI -ne 'true') {
    throw 'not on CI'
}

function Remove-Command {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$name
    )
    where.exe "$name" | ForEach-Object {
        Remove-Item "$_"
        Write-Output "command removed: $_"
    }
}

function Destroy-Environment {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$pattern
    )
    Get-ChildItem env:*$pattern* -Name | ForEach-Object {
        $envPath = "env:$_"
        if ($env:GITHUB_ACTIONS -eq 'true') {
            $envValue = (Get-Item -Path "$envPath").Value
            if (Test-Path -Path "$envValue") {
                try {
                    Remove-Item -Path "$envValue" -Force -Recurse
                    Write-Output "environment variable content removed: $envValue"
                }
                catch {}
            }
        }
        Remove-Item -Path "$envPath"
        Write-Output "environment variable removed: $envPath"
    }
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
    throw $(where.exe "$name")
}

function Assert-Environment-Does-Not-Match {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$pattern
    )
    if (Test-Path -Path env:*$pattern*) {
        throw (Get-ChildItem env:*$pattern* -Name)
    }
}

@'
    sdkmanager
    avdmanager
    java
    gradle
    node
    npm
    python
    appium
    choco
'@.Split("`n") | ForEach-Object {
    $name = $_.Trim()
    Remove-Command "$name"
    Assert-Not-Callable "$name"
}

@'
    JAVA
    ANDROID
    Chocolatey
'@.Split("`n") | ForEach-Object {
    $pattern = $_.Trim()
    Destroy-Environment "$pattern"
    Assert-Environment-Does-Not-Match "$pattern"
}
