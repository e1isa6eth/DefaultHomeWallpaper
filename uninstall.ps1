$ErrorActionPreference = "SilentlyContinue"

$TargetDir    = "C:\ProgramData\DefaultWallpaper"
$DesktopImage = "Background.jpg"
$LockImage    = "Lockscreen.jpg"

# Remove files
Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\$DesktopImage" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\$LockImage"    -Force -ErrorAction SilentlyContinue

# Remove Active Setup
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{DefaultUserBackgrounds}" -Recurse -Force -ErrorAction SilentlyContinue

# Remove Lock screen policy ONLY if it points to our file
$LockPolKey  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$LockPolName = "LockScreenImage"
$OurLockPath = "C:\ProgramData\DefaultWallpaper\Lockscreen.jpg"

try {
    $current = (Get-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue).$LockPolName
    if ($current -and ($current -ieq $OurLockPath)) {
        Remove-ItemProperty -Path $LockPolKey -Name $LockPolName -ErrorAction SilentlyContinue
    }

    # Rydd opp tom nøkkel
    if (Test-Path $LockPolKey) {
        $props = (Get-ItemProperty -Path $LockPolKey -ErrorAction SilentlyContinue).PSObject.Properties |
                 Where-Object { $_.Name -notlike "PS*" }
        if (-not $props) { Remove-Item -Path $LockPolKey -Force -ErrorAction SilentlyContinue }
    }
} catch { }

exit 0
