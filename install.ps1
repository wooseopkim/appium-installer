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
$androidSDkLevel = '33' # https://developer.android.com/tools/releases/platforms
$androidPackage = "system-images;android-$androidSdkLevel;google_apis;$androidArch"

# https://docs.chocolatey.org/en-us/choco/setup#install-with-powershell.exe
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# https://stackoverflow.com/a/46760714
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# https://appium.io/docs/en/2.0/quickstart/install/
; if($?) { choco install -y nodejs-lts } # https://community.chocolatey.org/packages/nodejs-lts
; if($?) { npm i -g appium@next }

# https://appium.io/docs/en/2.0/quickstart/uiauto2-driver/
# ; if($?) { choco install -y androidstudio } # https://community.chocolatey.org/packages/AndroidStudio
; if($?) { choco install -y android-sdk } # https://community.chocolatey.org/packages/android-sdk
; if($?) { refreshenv }
$temurinParams = "/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /INSTALLDIR=$env:ProgramFiles\Eclipse Adoptium\"
; if($?) { choco install -y Temurin8 --params="$temurinParams" } # https://community.chocolatey.org/packages/Temurin8
; if($?) { refreshenv }
; if($?) { echo y | sdkmanager $androidPackage }
; if($?) { avdmanager create avd --name 'Appium' --force --abi "google_apis/$androidArch" --package "$androidPackage" --device 'Nexus 6P' }

# https://appium.io/docs/en/2.0/quickstart/next-steps/
# download and install appium-inspector or use web version # https://github.com/appium/appium-inspector#installation
; if($?) { choco install -y python3 --version 3.11.3 } # https://community.chocolatey.org/packages/python3/3.11.3

# https://adamtheautomator.com/how-to-sign-powershell-script/
