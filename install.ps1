$ErrorActionPreference = "Stop"

# Config
$CompanyKey   = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"
$TargetDir    = "C:\ProgramData\DefaultWallpaper"
$ImageName    = "Background.jpg"
$ScriptName   = "DesktopBackground.ps1"
$UninstallDst = Join-Path $TargetDir "uninstall.ps1"

$DestImage    = Join-Path $TargetDir $ImageName
$ScriptPath   = Join-Path $TargetDir $ScriptName

$PublicPics   = "C:\Users\Public\Pictures"
$PublicImage  = Join-Path $PublicPics $ImageName

# Create target dir + copy files
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
New-Item -Path $PublicPics -ItemType Directory -Force | Out-Null

Copy-Item -Path (Join-Path $PSScriptRoot $ImageName)  -Destination $DestImage  -Force
Copy-Item -Path (Join-Path $PSScriptRoot $ScriptName) -Destination $ScriptPath -Force
Copy-Item -Path (Join-Path $PSScriptRoot "uninstall.ps1") -Destination $UninstallDst -Force

# Public visibility (script uses this path)
Copy-Item -Path $DestImage -Destination $PublicImage -Force

# Set defaults in Default User hive (first wallpaper for NEW profiles)
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"

if (!(Test-Path $DefaultHive)) { throw "Default hive not found at $DefaultHive" }

reg.exe load $TempHive $DefaultHive | Out-Null
try {
    $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
    New-Item -Path $DesktopKey -Force | Out-Null
    Set-ItemProperty -Path $DesktopKey -Name Wallpaper      -Value $PublicImage -Type String
    Set-ItemProperty -Path $DesktopKey -Name WallpaperStyle -Value "10"         -Type String
    Set-ItemProperty -Path $DesktopKey -Name TileWallpaper  -Value "0"          -Type String
} finally {
    reg.exe unload $TempHive | Out-Null
}

# Active Setup (runs once per user at first logon)
$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}"
New-Item -Path $ActiveSetupKey -Force | Out-Null

New-ItemProperty -Path $ActiveSetupKey -Name "StubPath"    -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`"" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "Version"     -Value "1,0" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "IsInstalled" -Value 1     -PropertyType DWord  -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "Locale"      -Value "EN"  -PropertyType String -Force | Out-Null
New-ItemProperty -Path $ActiveSetupKey -Name "ComponentID" -Value "DefaultWallpaper" -PropertyType String -Force | Out-Null

# Optional: Company key for tracking
New-Item -Path $CompanyKey -Force | Out-Null
New-ItemProperty -Path $CompanyKey -Name "Installed" -Value 1 -PropertyType DWord -Force | Out-Null

# Log (for detection)
$LogPath = Join-Path $TargetDir "install.log"
"Wallpaper install completed at $(Get-Date)" | Out-File -FilePath $LogPath -Append -Encoding utf8

exit 0
