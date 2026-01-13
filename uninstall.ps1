# uninstall.ps1
$ErrorActionPreference = "SilentlyContinue"

$TargetDir   = "C:\ProgramData\DefaultWallpaper"
$ImageName   = "Background.jpg"
$CompanyKey  = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"

# Remove default user values if possible
if (Test-Path $DefaultHive) {
    reg.exe load $TempHive $DefaultHive | Out-Null
    try {
        $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
        Remove-ItemProperty -Path $DesktopKey -Name "Wallpaper" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name "WallpaperStyle" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name "TileWallpaper" -ErrorAction SilentlyContinue
    } finally {
        reg.exe unload $TempHive | Out-Null
    }
}

# Delete image and script
Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\$ImageName" -Force -ErrorAction SilentlyContinue

# Remove registry keys
Remove-Item -Path $CompanyKey -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}" -Recurse -Force -ErrorAction SilentlyContinue

exit 0
