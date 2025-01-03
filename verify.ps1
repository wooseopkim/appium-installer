# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

echo '::group::node'
node --version
where.exe node
echo '::endgroup::'

echo '::group::appium'
appium --version
where.exe appium
echo '::endgroup::'

echo '::group::java'
java -version
where.exe java
echo '::endgroup::'

echo '::group::sdkmanager'
sdkmanager --list
where.exe sdkmanager
echo '::endgroup::'

echo '::group::avdmanager'
avdmanager list device
where.exe avdmanager
echo '::endgroup::'

echo '::group::python'
python --version
where.exe python
echo '::endgroup::'
