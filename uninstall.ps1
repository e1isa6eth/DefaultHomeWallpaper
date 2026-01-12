# Uninstall.ps1
$Guid      = "{F2B6A1D9-7C2A-4B6E-9C2A-5B3B2B2D0A11}"
$TargetDir = "C:\ProgramData\Scripts"

$PathsToRemove = @(
  "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\$Guid",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Active Setup\Installed Components\$Guid"
)

foreach ($p in $PathsToRemove) {
  Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Public\Pictures\Background.jpg" -Force -ErrorAction SilentlyContinue

exit 0
