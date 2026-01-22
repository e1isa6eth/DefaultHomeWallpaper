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

# Hvis brukeren allerede har en wallpaper satt (valgfritt ekstra vern):
# Kommenter inn hvis du vil være enda mer konservativ.
# $current = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -ErrorAction SilentlyContinue).Wallpaper
# if ($current -and (Test-Path $current)) { exit 0 }

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
} catch { }

[NativeMethods]::SystemParametersInfo(20, 0, $DesktopImagePath, 3) | Out-Null

# Sett marker til slutt (kun hvis alt over er kjørt)
New-Item -Path $MarkerKey -Force | Out-Null
Set-ItemProperty -Path $MarkerKey -Name $MarkerName -Value 1 -Type DWord -Force

exit 0
