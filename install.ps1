# install.ps1
# Sets default wallpaper for NEW users (C:\Users\Default) + registers Active Setup
# Run as SYSTEM (e.g. via Intune Win32 App)

$ErrorActionPreference = "Stop"

$CompanyKey    = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"
$Version       = "1.0.0.0"

$TargetDir     = "C:\ProgramData\DefaultWallpaper"
$ImageName     = "Background.jpg"
$ScriptName    = "DesktopBackground.ps1"
$DestImage     = Join-Path $TargetDir $ImageName
$ScriptPath    = Join-Path $TargetDir $ScriptName

# Create target folder
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null

# Copy image and script from current script folder to target
Copy-Item -Path (Join-Path $PSScriptRoot $ImageName) -Destination $DestImage -Force
Copy-Item -Path (Join-Path $PSScriptRoot $ScriptName) -Destination $ScriptPath -Force

# Optional: Copy image to Public Pictures for visibility
New-Item -Path "C:\Users\Public\Pictures" -ItemType Directory -Force | Out-Null
Copy-Item -Path $DestImage -Destination "C:\Users\Public\Pictures\$ImageName" -Force

# Load Default user hive and set registry
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"

if (!(Test-Path $DefaultHive)) { throw "Default user hive not found at $DefaultHive" }

reg.exe load $TempHive $DefaultHive | Out-Null

try {
    $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"

    New-Item -Path $DesktopKey -Force | Out-Null
    Set-ItemProperty -Path $DesktopKey -Name Wallpaper       -Value $DestImage       -Type String
    Set-ItemProperty -Path $DesktopKey -Name WallpaperStyle  -Value "10"             -Type String  # Fill
    Set-ItemProperty -Path $DesktopKey -Name TileWallpaper   -Value "0"              -Type String  # No tiling
}
finally {
    reg.exe unload $TempHive | Out-Null
}

# Register Active Setup to apply wallpaper per-user at login (only once)
$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}"

New-Item -Path $ActiveSetupKey -Force | Out-Null
Set-ItemProperty -Path $ActiveSetupKey -Name "StubPath"    -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""
Set-ItemProperty -Path $ActiveSetupKey -Name "Version"     -Value "1,0"
Set-ItemProperty -Path $ActiveSetupKey -Name "IsInstalled" -Value 1 -Type DWord
Set-ItemProperty -Path $ActiveSetupKey -Name "Locale"      -Value "EN"
Set-ItemProperty -Path $ActiveSetupKey -Name "ComponentID" -Value "DefaultWallpaper"

# Optional: Write detection key
New-Item -Path $CompanyKey -Force | Out-Null
Set-ItemProperty -Path $CompanyKey -Name "Version" -Value $Version -Type String

exit 0
