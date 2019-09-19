
function Critical-Error($msg) {
    Write-Error $msg
    pause
    exit
}

Write-Warning "IMPORTANT! This Powershell script is for practice purposes only! "
Write-Warning "IMPORTANT! Please limit the usage of this script to yourself only. "
Write-Output "`n"

Write-Output "$(Get-Date) Begin: Building Visual Studio 2017 Offline ISO..."

Write-Output "`n"
Write-Output "$(Get-Date) Step 1: Checking prerequisites..."

$cdpacker = "$PSScriptRoot\cdimage.exe"
$vsInstaller = "$PSScriptRoot\vs_Professional.exe"
$autorunInf = "$PSScriptRoot\autorun.inf"

if (-Not ((Test-Path $cdpacker) -and (Test-Path $vsInstaller))) {    
    Critical-Error "Visual Studio 2017 offline installer not exist or CDIMAGE.exe not exist, building cannot continue! "    
} else {
    Write-Output "Visual Studio 2017 offline installer and CDIMAGE.exe check complete. "
}

if (-Not (Test-Path $autorunInf)) {
    Write-Warning "$autorunInf not found, the Visual Studio 2017 iso will have no autorun information (say icon etc). "
} else {
    Write-Output "AutoRun information check complete."
}

Write-Output "`n"
Write-Output "$(Get-Date) Step 2: A little bit clean-up..."

$isoFile = "$PSScriptRoot\vs2017pro.iso"
$isoFolder = "$PSScriptRoot\vs2017offline"

if (test-path $isoFile) {
    remove-item $isoFile
    Write-Output "Previous $isoFile removed. "
} 
else {
    Write-Output "$isoFile does not exist, skipped. "
}

if (test-path $isoFolder) {
	# remove-item $isoFolder -Recurse
    # Write-Output "Previous $isoFolder removed. "
}
else {
    Write-Output "$isoFolder does not exist, skipped. "
}

Write-Output "`n"
Write-Output "$(Get-Date) Step 3: Downloading Visual Studio 2017 offline files..."
Write-Output "Please wait, this process will take some time. "

& $vsInstaller --quiet --layout $isoFolder --lang en-US --add Microsoft.VisualStudio.Workload.ManagedDesktop -add Microsoft.VisualStudio.Workload.NetCoreTools -add Microsoft.VisualStudio.Workload.NetWeb -add Component.GitHub.VisualStudio -add Microsoft.VisualStudio.Component.Git --includeRecommended | Out-Null
Write-Output "Download complete! "

if (Test-Path $isoFolder) {
    Copy-Item $autorunInf -Destination $isoFolder
} else {
    Critical-Error "Visual Studio files download failed. "
}

Write-Output "`n"
Write-Output "$(Get-Date) Step 4: Building Visual Studio 2017 installation iso..."

# https://stackoverflow.com/questions/2095088/error-when-calling-3rd-party-executable-from-powershell-when-using-an-ide
& $cdpacker -n -m -d -lVS2017Pro $isoFolder $isoFile 2>&1 | %{ "$_" }

Write-Output "`n"
Write-Output "$(Get-Date) Done: Building complete! "
Start-Sleep -s 30
