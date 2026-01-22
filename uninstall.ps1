$ErrorActionPreference = "SilentlyContinue"

$TargetDir   = "C:\ProgramData\DefaultWallpaper"
$DesktopImg  = "Background.jpg"
$LockImg     = "Lockscreen.jpg"
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
$TempHive    = "HKU\TEMP_DEFAULT"

$LockPolKey  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$LockPolName = "LockScreenImage"
$LockPolPath = "$TargetDir\$LockImg"

# Fjern install.log først (så detection kan flippe fort)
Remove-Item -Path "$TargetDir\install.log" -Force -ErrorAction SilentlyContinue

# Rydd DefaultUser-hive
if (Test-Path $DefaultHive) {
    reg.exe load $TempHive $DefaultHive | Out-Null
    try {
        $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"
        Remove-ItemProperty -Path $DesktopKey -Name Wallpaper      -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name WallpaperStyle -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $DesktopKey -Name TileWallpaper  -ErrorAction SilentlyContinue
    } finally {
        reg.exe unload $TempHive | Out-Null
    }
}

# Fjern lockscreen policy kun hvis den peker på vår fil
try {
    $existing = (Get-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue).$LockPolName
    if ($existing -and ($existing -eq $LockPolPath)) {
        Remove-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue
    }

    # Slett policy-nøkkel hvis tom
    if (Test-Path $LockPolKey) {
        $props = (Get-ItemProperty -Path $LockPolKey -ErrorAction SilentlyContinue).PSObject.Properties |
                 Where-Object { $_.Name -notlike "PS*" }
        if (-not $props) { Remove-Item -Path $LockPolKey -Force -ErrorAction SilentlyContinue }
    }
} catch {}

# Fjern Active Setup
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultUserBackgrounds}" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultWallpaper-2026}" -Recurse -Force -ErrorAction SilentlyContinue

# Fjern filer
Remove-Item -Path "$TargetDir\$DesktopImg" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TargetDir\$LockImg"    -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TargetDir\SetUserBackgrounds.ps1" -Force -ErrorAction SilentlyContinue

Remove-Item -Path "C:\Users\Public\Pictures\$DesktopImg" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\$LockImg"    -Force -ErrorAction SilentlyContinue

# Fjern mappa til slutt (men la uninstall.ps1 være i fred mens den kjører)
Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue

exit 0
