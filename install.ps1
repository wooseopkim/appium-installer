# https://github.com/PowerShell/PowerShell/issues/3415#issuecomment-1354457563
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

# https://learn.microsoft.com/en-us/androidArchive/blogs/virtual_pc_guy/a-self-elevating-powershell-script

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   { 
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
    }
else
   { 
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
    }

$androidArch = 'x86_64'
$androidSDkVersion = '34' # https://developer.android.com/tools/releases/platforms
$androidPackage = "system-images;android-$androidSdkVersion;google_apis;$androidArch"

function Add-Path {
    param (
        $Path
    )

    $env:PATH += ";$Path"
    echo $Path | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
    refreshenv
}

# https://docs.chocolatey.org/en-us/choco/setup#install-with-powershell.exe
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# https://stackoverflow.com/a/46760714
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# https://appium.io/docs/en/2.0/quickstart/install/
choco install -y nodejs-lts # https://community.chocolatey.org/packages/nodejs-lts
npm i -g appium@next

# https://appium.io/docs/en/2.0/quickstart/uiauto2-driver/
choco install -y androidstudio # https://community.chocolatey.org/packages/AndroidStudio
$AndroidSdkRoot = "$env:USERPROFILE\AppData\Local\Android\sdk"
if ($env:GITHUB_ACTIONS) {
    $AndroidSdkRoot = "C:\Android\android-sdk"
}
echo "$AndroidSdkRoot"
ls "$AndroidSdkRoot\cmdline-tools"
ls "$AndroidSdkRoot\cmdline-tools\latest"
ls "$AndroidSdkRoot\cmdline-tools\latest\bin"
Add-Path "$AndroidSdkRoot\emulator"
Add-Path "$AndroidSdkRoot\cmdline-tools\latest\bin"
Add-Path "$AndroidSdkRoot\tools"
Add-Path "$AndroidSdkRoot\tools\bin"
Add-Path "$AndroidSdkRoot\platform-tools"
Add-Path "$AndroidSdkRoot\build-tools"
refreshenv
$temurinParams = "/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /INSTALLDIR=$env:ProgramFiles\Eclipse Adoptium\"
choco install -y Temurin17 --params="$temurinParams" # https://community.chocolatey.org/packages/Temurin17
refreshenv
echo y | sdkmanager.bat "$androidPackage"
avdmanager.bat create avd --name 'Appium' --force --abi "google_apis/$androidArch" --package "$androidPackage" --device 'Nexus 6P'

# https://appium.io/docs/en/2.0/quickstart/next-steps/
choco install -y python3 --version 3.11.3 # https://community.chocolatey.org/packages/python3/3.11.3

# download and install appium-inspector or use web version # https://github.com/appium/appium-inspector#installation

# https://adamtheautomator.com/how-to-sign-powershell-script/
