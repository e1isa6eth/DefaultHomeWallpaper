# SetUserBackgrounds.ps1
# Setter desktop for gjeldende bruker kun én gang (per profil),
# slik at bruker kan endre senere uten at reinstall overskriver.

$ErrorActionPreference = "SilentlyContinue"

$DesktopImagePath = "C:\Users\Public\Pictures\Background.jpg"
if (!(Test-Path $DesktopImagePath)) { exit 0 }

# Marker for "har kjørt før" (hindrer overskriving ved reinstall / re-run)
$MarkerKey  = "HKCU:\Software\Custom\DefaultUserBackgrounds"
$MarkerName = "Applied"

try {
    $applied = (Get-ItemProperty -Path $MarkerKey -Name $MarkerName -ErrorAction SilentlyContinue).$MarkerName
    if ($applied -eq 1) { exit 0 }
} catch { }

# Set desktop wallpaper (HKCU)
$DesktopKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $DesktopKey -Name "Wallpaper"      -Value $DesktopImagePath -Force
Set-ItemProperty -Path $DesktopKey -Name "WallpaperStyle" -Value "10" -Force   # 10 = Fill
Set-ItemProperty -Path $DesktopKey -Name "TileWallpaper"  -Value "0"  -Force

# Refresh desktop (SystemParametersInfo)
try {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction Stop

    [NativeMethods]::SystemParametersInfo(20, 0, $DesktopImagePath, 3) | Out-Null
} catch { }

# Sett marker til slutt
New-Item -Path $MarkerKey -Force | Out-Null
New-ItemProperty -Path $MarkerKey -Name $MarkerName -Value 1 -PropertyType DWord -Force | Out-Null

exit 0
