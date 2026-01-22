$ErrorActionPreference = "Stop"

# Config
$TargetDir = "C:\ProgramData\DefaultWallpaper"

$DesktopImage = "Background.jpg"
$LockImage    = "Lockscreen.jpg"
$ScriptName   = "SetUserBackgrounds.ps1"
$UninstallName = "uninstall.ps1"

$DestDesktop = Join-Path $TargetDir $DesktopImage
$DestLock    = Join-Path $TargetDir $LockImage
$ScriptPath  = Join-Path $TargetDir $ScriptName
$UninstallDst = Join-Path $TargetDir $UninstallName

# Create target dir + copy files
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot $DesktopImage) -Destination $DestDesktop -Force
Copy-Item -Path (Join-Path $PSScriptRoot $LockImage)    -Destination $DestLock    -Force
Copy-Item -Path (Join-Path $PSScriptRoot $ScriptName)   -Destination $ScriptPath  -Force
Copy-Item -Path (Join-Path $PSScriptRoot $UninstallName) -Destination $UninstallDst -Force

# Optional: Public visibility (kun for enkel tilgang/lesbarhet)
Copy-Item -Path $DestDesktop -Destination "C:\Users\Public\Pictures\$DesktopImage" -Force
Copy-Item -Path $DestLock    -Destination "C:\Users\Public\Pictures\$LockImage"    -Force

# Active Setup for new user sessions (kjører ved første logon per profil)
# Viktig: hold samme nøkkelnavn + Version stabil hvis du IKKE vil trigge på nytt for eksisterende profiler
$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultUserBackgrounds}"
New-Item -Path $ActiveSetupKey -Force | Out-Null

Set-ItemProperty -Path $ActiveSetupKey -Name "StubPath"    -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`"" -Type String
Set-ItemProperty -Path $ActiveSetupKey -Name "Version"     -Value "1,0" -Type String
Set-ItemProperty -Path $ActiveSetupKey -Name "IsInstalled" -Value 1 -Type DWord
Set-ItemProperty -Path $ActiveSetupKey -Name "Locale"      -Value "EN" -Type String
Set-ItemProperty -Path $ActiveSetupKey -Name "ComponentID" -Value "DefaultUserBackgrounds" -Type String

# Lock screen (device-wide policy)
$LockPolKey  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$LockPolName = "LockScreenImage"

New-Item -Path $LockPolKey -Force | Out-Null

# Skånsomt: sett kun hvis det mangler/er ugyldig (overstyrer ikke andre policies)
$existing = (Get-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue).$LockPolName
if ([string]::IsNullOrWhiteSpace($existing) -or !(Test-Path $existing)) {
    Set-ItemProperty -Path $LockPolKey -Name $LockPolName -Value $DestLock -Type String
}

# Log
$LogPath = Join-Path $TargetDir "install.log"
"Wallpaper + LockScreen install completed at $(Get-Date)" | Out-File -FilePath $LogPath -Append -Encoding utf8

exit 0

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& 'C:\ProgramData\DefaultWallpaper\uninstall.ps1'"
