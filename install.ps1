# install.ps1
# Setter default wallpaper for NEW user profiles (C:\Users\Default) - men låser ikke.
# Krever admin/SYSTEM (Win32 app i Intune kjører normalt som SYSTEM).

$ErrorActionPreference = "Stop"

$CompanyKey = "HKLM:\SOFTWARE\BackITUp\Wallpaper"
$Version    = "1.0.0.0"

$TargetDir  = "C:\ProgramData\BackITUp\Wallpaper"
$ImageName  = "Background.jpg"
$DestImage  = Join-Path $TargetDir $ImageName

# Opprett mappe + kopier bilde
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot $ImageName) -Destination $DestImage -Force

# (Valgfritt) også til Public Pictures, for enkel manuell testing/tilgang
New-Item -Path "C:\Users\Public\Pictures" -ItemType Directory -Force | Out-Null
Copy-Item -Path $DestImage -Destination "C:\Users\Public\Pictures\$ImageName" -Force

# Last inn Default User-hive
$DefaultHive = "C:\Users\Default\NTUSER.DAT"
if (!(Test-Path $DefaultHive)) { throw "Fant ikke $DefaultHive" }

# Bruk en midlertidig HKU hive
$TempHive = "HKU\TEMP_DEFAULT"
& reg.exe load $TempHive $DefaultHive | Out-Null

try {
    $DesktopKey = "Registry::$TempHive\Control Panel\Desktop"

    # Wallpaper = path til filen vi kopierte (stabilt)
    New-Item -Path $DesktopKey -Force | Out-Null
    Set-ItemProperty -Path $DesktopKey -Name "Wallpaper"       -Value $DestImage -Type String
    Set-ItemProperty -Path $DesktopKey -Name "WallpaperStyle"  -Value "10"       -Type String  # 10 = Fill
    Set-ItemProperty -Path $DesktopKey -Name "TileWallpaper"   -Value "0"        -Type String

} finally {
    & reg.exe unload $TempHive | Out-Null
}

# Skriv "installed/version" til HKLM for detection
New-Item -Path $CompanyKey -Force | Out-Null
Set-ItemProperty -Path $CompanyKey -Name "Version" -Value $Version -Type String

exit 0
