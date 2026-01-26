$ErrorActionPreference = "SilentlyContinue"

# DesktopBackground.ps1
# Applies wallpaper for the current (logged-in) user via HKCU
# NOT enforced — user can change it

$WallpaperPath = "C:\Users\Public\Pictures\Background.jpg"
$RegPath = "HKCU:\Control Panel\Desktop"

if (!(Test-Path $WallpaperPath)) { exit 0 }

# Set registry keys for current user
Set-ItemProperty -Path $RegPath -Name "Wallpaper"       -Value $WallpaperPath -Force
Set-ItemProperty -Path $RegPath -Name "WallpaperStyle"  -Value "10" -Force  # 10 = Fill
Set-ItemProperty -Path $RegPath -Name "TileWallpaper"   -Value "0"  -Force

# Refresh desktop wallpaper (SystemParametersInfo)
try {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class NativeMethods {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@ -ErrorAction Stop
} catch {
    # If already defined, ignore
}

[NativeMethods]::SystemParametersInfo(20, 0, $WallpaperPath, 3) | Out-Null

exit 0
