# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

node --version
where.exe node

appium --version
where.exe appium

java -version
where.exe java

sdkmanager --list
where.exe sdkmanager

avdmanager list device
where.exe avdmanager

python --version
where.exe python
