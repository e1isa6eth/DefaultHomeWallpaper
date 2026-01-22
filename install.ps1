$ErrorActionPreference = "Stop"

# Config
$TargetDir      = "C:\ProgramData\DefaultWallpaper"
$DesktopImage   = "Background.jpg"
$LockImage      = "Lockscreen.jpg"
$ScriptName     = "SetUserBackgrounds.ps1"
$UninstallName  = "uninstall.ps1"

$DestDesktop   = Join-Path $TargetDir $DesktopImage
$DestLock      = Join-Path $TargetDir $LockImage
$ScriptPath    = Join-Path $TargetDir $ScriptName
$UninstallDst  = Join-Path $TargetDir $UninstallName

# Create target dir + copy files
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot $DesktopImage)  -Destination $DestDesktop  -Force
Copy-Item -Path (Join-Path $PSScriptRoot $LockImage)     -Destination $DestLock     -Force
Copy-Item -Path (Join-Path $PSScriptRoot $ScriptName)    -Destination $ScriptPath   -Force
Copy-Item -Path (Join-Path $PSScriptRoot $UninstallName) -Destination $UninstallDst -Force

# Optional: Public visibility
New-Item -Path "C:\Users\Public\Pictures" -ItemType Directory -Force | Out-Null
Copy-Item -Path $DestDesktop -Destination "C:\Users\Public\Pictures\$DesktopImage" -Force
Copy-Item -Path $DestLock    -Destination "C:\Users\Public\Pictures\$LockImage"    -Force

# Active Setup (runs at first logon per profile)
$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultUserBackgrounds}"
New-Item -Path $ActiveSetupKey -Force | Out-Null

# IMPORTANT: Use New-ItemProperty for typed values
New-ItemProperty -Path $ActiveSetupKey -Name "StubPath"    -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`"" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "Version"     -Value "1,0" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "IsInstalled" -Value 1     -PropertyType DWord  -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "Locale"      -Value "EN"  -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "ComponentID" -Value "DefaultUserBackgrounds" -PropertyType String -Force | Out-Null

# Lock screen (device-wide policy)  NB: Dette LÅSER lockscreen.
$LockPolKey  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$LockPolName = "LockScreenImage"
New-Item -Path $LockPolKey -Force | Out-Null

$existing = (Get-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue).$LockPolName
if ([string]::IsNullOrWhiteSpace($existing) -or !(Test-Path $existing)) {
    New-ItemProperty -Path $LockPolKey -Name $LockPolName -Value $DestLock -PropertyType String -Force | Out-Null
}

# Log (detection)
$LogPath = Join-Path $TargetDir "install.log"
"Wallpaper + LockScreen install completed at $(Get-Date)" | Out-File -FilePath $LogPath -Append -Encoding utf8

exit 0
