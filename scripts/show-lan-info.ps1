$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lan-common.ps1"

$lanIp = Get-LanIp
Show-LanBanner -Title 'Grind & Go - adresy v LAN' -LanIp $lanIp

Write-Host '1. Zapustit API + PostgreSQL na etom PK:' -ForegroundColor White
Write-Host '   .\scripts\start-api-lan.ps1' -ForegroundColor Gray
Write-Host ""
Write-Host '2. Web (bystryy test, ssylka srazu):' -ForegroundColor White
Write-Host '   .\scripts\run-web-lan.ps1' -ForegroundColor Gray
Write-Host "   -> http://${lanIp}:8080" -ForegroundColor Green
Write-Host ""
Write-Host '3. Web (sborka dlya razdachi):' -ForegroundColor White
Write-Host '   .\scripts\build-web-lan.ps1' -ForegroundColor Gray
Write-Host ""
Write-Host '4. Android APK:' -ForegroundColor White
Write-Host '   .\scripts\build-android-lan.ps1' -ForegroundColor Gray
Write-Host ""
