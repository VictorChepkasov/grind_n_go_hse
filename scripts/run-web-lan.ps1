$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lan-common.ps1"

$lanIp = Get-LanIp
$apiUrl = "http://${lanIp}:5000"
$preferredPort = 8080
$webPort = Get-FreePort -StartPort $preferredPort

Show-LanBanner -Title 'Grind & Go - Web v LAN' -LanIp $lanIp

if ($webPort -ne $preferredPort) {
    Write-Host " Port $preferredPort zanyat. Ispolzuem port $webPort" -ForegroundColor Yellow
    Write-Host ' Zaversite staryy zapusk Flutter (Ctrl+C v tom terminale) ili:' -ForegroundColor DarkGray
    Write-Host '   Get-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess | Stop-Process' -ForegroundColor DarkGray
    Write-Host ''
}

Write-Host " Web-prilozhenie: http://${lanIp}:${webPort}" -ForegroundColor Green
Write-Host " API v prilozhenii: $apiUrl" -ForegroundColor Green
Write-Host ""
Write-Host ' Snachala zapustite API: .\scripts\start-api-lan.ps1' -ForegroundColor Yellow
Write-Host ""

$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location (Join-Path $projectRoot "grind_go_mobile")

flutter run -d web-server `
    --web-hostname 0.0.0.0 `
    --web-port $webPort `
    --dart-define=API_BASE_URL=$apiUrl
