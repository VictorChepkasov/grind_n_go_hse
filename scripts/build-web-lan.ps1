$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lan-common.ps1"

$lanIp = Get-LanIp
$inputIp = Read-Host "IP etogo PK v lokalnoy seti [Enter = $lanIp]"
if ($inputIp) {
    $lanIp = $inputIp.Trim()
}

$apiUrl = "http://${lanIp}:5000"

Show-LanBanner -Title 'Grind & Go - sborka Web' -LanIp $lanIp

$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location (Join-Path $projectRoot "grind_go_mobile")

Write-Host "Sborka web s API: $apiUrl" -ForegroundColor Green
flutter build web --dart-define=API_BASE_URL=$apiUrl

$webDir = Join-Path (Get-Location) "build\web"
Write-Host ""
Write-Host "Gotovo. Fayly: $webDir" -ForegroundColor Green
Write-Host ""
Write-Host "Zapusk servera dlya lokalnoy seti:" -ForegroundColor Yellow
Write-Host "  cd `"$webDir`"" -ForegroundColor White
Write-Host "  python -m http.server 8080 --bind 0.0.0.0" -ForegroundColor White
Write-Host ""
Write-Host "Ssylka dlya telefona/drugogo PK:" -ForegroundColor Yellow
Write-Host "  http://${lanIp}:8080" -ForegroundColor Green
Write-Host ""
Write-Host 'API dolzhen byt zapushchen: .\scripts\start-api-lan.ps1' -ForegroundColor DarkGray
