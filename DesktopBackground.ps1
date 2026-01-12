# DesktopBackground.ps1
# Setter wallpaper for innlogget bruker (HKCU) - ingen policy-lock.

$WallpaperPath = "C:\Users\Public\Pictures\Background.jpg"
$RegPath = "HKCU:\Control Panel\Desktop"

if (!(Test-Path $WallpaperPath)) { exit 0 }

# Path + stil
Set-ItemProperty -Path $RegPath -Name "Wallpaper"       -Value $WallpaperPath -Force
Set-ItemProperty -Path $RegPath -Name "WallpaperStyle"  -Value "10" -Force   # 10=Fill, 6=Fit, 2=Stretch
Set-ItemProperty -Path $RegPath -Name "TileWallpaper"   -Value "0"  -Force

# Refresh (SystemParametersInfo)
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
    # hvis typen allerede finnes, ignorer
}

[NativeMethods]::SystemParametersInfo(20, 0, $WallpaperPath, 3) | Out-Null
exit 0
