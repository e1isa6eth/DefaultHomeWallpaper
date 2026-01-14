$ExpectedVersion = "1.0.0"
$LogPath = "C:\ProgramData\DefaultWallpaper\install.log"

if (Test-Path $LogPath) {
    $LogContent = Get-Content $LogPath -Raw
    if ($LogContent -like "*$ExpectedVersion*") {
        Write-Host "Found correct version"
        exit 0
    }
}

exit 1
