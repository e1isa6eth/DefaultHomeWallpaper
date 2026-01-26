$ErrorActionPreference = "SilentlyContinue"

$TargetDir    = "C:\ProgramData\DefaultWallpaper"
$ImageName    = "Background.jpg"
$ScriptName   = "DesktopBackground.ps1"
$CompanyKey   = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"

$PublicImage  = "C:\Users\Public\Pictures\$ImageName"

$DefaultHive  = "C:\Users\Default\NTUSER.DAT"
$TempHive     = "HKU\TEMP_DEFAULT"

$ActiveSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}"

# 0) Remove install.log early so detection can flip
Remove-Item -Path (Join-Path $TargetDir "install.log") -Force -ErrorAction SilentlyContinue

# 1) Clean Default User hive wallpaper values (if present)
if (Test-Path $DefaultHive) {
    reg.exe load $TempHive $DefaultHive | Out-Null
    try {
        $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
        Remove-ItemProperty -Path $DesktopKey -Name "Wallpaper"      -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name "WallpaperStyle" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name "TileWallpaper"  -ErrorAction SilentlyContinue
    } finally {
        reg.exe unload $TempHive | Out-Null
    }
}

# 2) Remove Active Setup
Remove-Item -Path $ActiveSetupKey -Recurse -Force -ErrorAction SilentlyContinue

# 3) Remove public copy
Remove-Item -Path $PublicImage -Force -ErrorAction SilentlyContinue

# 4) Remove files in ProgramData (DO NOT delete uninstall.ps1 while running)
Remove-Item -Path (Join-Path $TargetDir $ImageName)  -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $TargetDir $ScriptName) -Force -ErrorAction SilentlyContinue

# 5) Remove company key
Remove-Item -Path $CompanyKey -Recurse -Force -ErrorAction SilentlyContinue

# 6) Try to remove folder last (may fail if uninstall.ps1 is in use — OK)
Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue

exit 0
