
$ErrorActionPreference = "Stop"

# Config
$CompanyKey   = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"
$Version      = "1.0.0"
$TargetDir    = "C:\ProgramData\DefaultWallpaper"
$ImageName    = "Background.jpg"
$DestImage    = Join-Path $TargetDir $ImageName
$ScriptPath   = "$TargetDir\DesktopBackground.ps1"
$UninstallSrc = "$PSScriptRoot\uninstall.ps1"
$UninstallDst = "$TargetDir\uninstall.ps1"

# Create target dir and copy files
New-Item -Path $TargetDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path "$PSScriptRoot\$ImageName" -Destination $DestImage -Force
Copy-Item -Path "$PSScriptRoot\DesktopBackground.ps1" -Destination $ScriptPath -Force
Copy-Item -Path $UninstallSrc -Destination $UninstallDst -Force  
# Optional: Public visibility
Copy-Item -Path $DestImage -Destination "C:\Users\Public\Pictures\$ImageName" -Force

# Set registry defaults in Default User hive
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"

if (!(Test-Path $DefaultHive)) { throw "Default hive not found at $DefaultHive" }

reg.exe load $TempHive $DefaultHive | Out-Null

try {
    $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
    New-Item -Path $DesktopKey -Force | Out-Null
    Set-ItemProperty -Path $DesktopKey -Name Wallpaper -Value $DestImage -Type String
    Set-ItemProperty -Path $DesktopKey -Name WallpaperStyle -Value "10" -Type String
    Set-ItemProperty -Path $DesktopKey -Name TileWallpaper -Value "0" -Type String
} finally {
    reg.exe unload $TempHive | Out-Null
}

# Register Active Setup for new user sessions
$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}"
New-Item -Path $ActiveSetupKey -Force | Out-Null
Set-ItemProperty -Path $ActiveSetupKey -Name "StubPath" -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""
Set-ItemProperty -Path $ActiveSetupKey -Name "Version" -Value "1.0"
Set-ItemProperty -Path $ActiveSetupKey -Name "IsInstalled" -Value 1 -Type DWord
Set-ItemProperty -Path $ActiveSetupKey -Name "Locale" -Value "EN"
Set-ItemProperty -Path $ActiveSetupKey -Name "ComponentID" -Value "DefaultWallpaper"

# Detection key (used by Intune)
New-Item -Path $CompanyKey -Force | Out-Null
Set-ItemProperty -Path $CompanyKey -Name "Version" -Value $Version -Type String


$LogPath = "$TargetDir\install.log"
"Wallpaper install completed at $(Get-Date)" | Out-File -FilePath $LogPath -Append -Encoding utf8

exit 0

