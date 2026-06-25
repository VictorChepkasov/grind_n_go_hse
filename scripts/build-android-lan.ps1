$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lan-common.ps1"

$lanIp = Get-LanIp
$inputIp = Read-Host "IP etogo PK v lokalnoy seti [Enter = $lanIp]"
if ($inputIp) {
    $lanIp = $inputIp.Trim()
}

$apiUrl = "http://${lanIp}:5000"

Show-LanBanner -Title 'Grind & Go - sborka Android APK' -LanIp $lanIp

$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location (Join-Path $projectRoot "grind_go_mobile")

Write-Host "Sborka APK s API: $apiUrl" -ForegroundColor Green
flutter build apk --dart-define=API_BASE_URL=$apiUrl

$apkPath = Join-Path (Get-Location) "build\app\outputs\flutter-apk\app-release.apk"
Write-Host ""
Write-Host "APK gotov:" -ForegroundColor Green
Write-Host "  $apkPath" -ForegroundColor White
Write-Host ""
Write-Host "Ustanovite APK na Android-telefon v toy zhe seti." -ForegroundColor Yellow
Write-Host 'API dolzhen byt zapushchen: .\scripts\start-api-lan.ps1' -ForegroundColor DarkGray
