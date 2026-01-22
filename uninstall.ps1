# uninstall.ps1
$ErrorActionPreference = "SilentlyContinue"

# Konfigurasjon
$TargetDir   = "C:\ProgramData\DefaultWallpaper"
$DesktopImg  = "Background.jpg"
$LockImg     = "Lockscreen.jpg"
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"
$CompanyKey  = "HKLM:\SOFTWARE\Custom\DefaultWallpaper"
$LockPolKey  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$LockPolName = "LockScreenImage"
$LockPolPath = "$TargetDir\$LockImg"

# Last DefaultUser-hive og fjern desktop-innstillinger
if (Test-Path $DefaultHive) {
    reg.exe load $TempHive $DefaultHive | Out-Null
    try {
        $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
        Remove-ItemProperty -Path $DesktopKey -Name Wallpaper       -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name WallpaperStyle  -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name TileWallpaper   -ErrorAction SilentlyContinue
    } finally {
        reg.exe unload $TempHive | Out-Null
    }
}

# Slett bilder og skriptfiler
Remove-Item -Path "$TargetDir\$DesktopImg" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TargetDir\$LockImg"    -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TargetDir\SetUserBackgrounds.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TargetDir\uninstall.ps1"          -Force -ErrorAction SilentlyContinue

# Fjern offentlige kopier
Remove-Item -Path "C:\Users\Public\Pictures\$DesktopImg" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\$LockImg"    -Force -ErrorAction SilentlyContinue

# Fjern Active Setup
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultUserBackgrounds}" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}" -Recurse -Force -ErrorAction SilentlyContinue

# Fjern firma-nøkkel
Remove-Item -Path $CompanyKey -Recurse -Force -ErrorAction SilentlyContinue

# Fjern lockscreen policy om den peker på vår fil
try {
    $existing = (Get-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue).$LockPolName
    if ($existing -and ($existing -eq $LockPolPath)) {
        Remove-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue
    }

    # Rydd opp policy-nøkkel hvis den er tom
    if (Test-Path $LockPolKey) {
        $props = (Get-ItemProperty -Path $LockPolKey -ErrorAction SilentlyContinue).PSObject.Properties |
                 Where-Object { $_.Name -notlike "PS*" }
        if (-not $props) {
            Remove-Item -Path $LockPolKey -Force -ErrorAction SilentlyContinue
        }
    }
} catch {}

# 💡 Viktig: Behold install.log til slutt – fjern det helt til slutt
Start-Sleep -Seconds 5
Remove-Item -Path "$TargetDir\install.log" -Force -ErrorAction SilentlyContinue

exit 0
