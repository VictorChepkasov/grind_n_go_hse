$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lan-common.ps1"

$lanIp = Get-LanIp
Show-LanBanner -Title 'Grind & Go - zapusk API' -LanIp $lanIp

$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location (Join-Path $projectRoot "GrindGoHSE")

Write-Host 'PostgreSQL dolzhen byt zapushchen na etom PK.' -ForegroundColor DarkGray
Write-Host "Swagger: http://${lanIp}:5000/swagger" -ForegroundColor Green
Write-Host ""

dotnet run --urls 'http://0.0.0.0:5000'
