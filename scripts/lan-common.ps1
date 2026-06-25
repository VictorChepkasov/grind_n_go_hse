function Get-LanIp {
    $candidates = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*' -and
        $_.PrefixOrigin -ne 'WellKnown'
    }

    $preferred = $candidates | Where-Object {
        $_.IPAddress -match '^(192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|10\.)'
    } | Sort-Object -Property InterfaceMetric | Select-Object -First 1

    if ($preferred) {
        return $preferred.IPAddress
    }

    return ($candidates | Select-Object -First 1).IPAddress
}

function Show-LanBanner {
    param(
        [string]$Title,
        [string]$LanIp
    )

    Write-Host ''
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host " IP PK v lokalnoy seti: $LanIp" -ForegroundColor Yellow
    Write-Host " API:  http://${LanIp}:5000" -ForegroundColor Green
    Write-Host ''
    Write-Host ' Telefon i PK dolzhny byt v odnoi Wi-Fi seti.' -ForegroundColor DarkGray
    Write-Host ' Esli ne rabotaet - razreshite porty 5000 i 8080 v brandmauere.' -ForegroundColor DarkGray
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
}

function Test-PortAvailable {
    param([int]$Port)

    $listener = $null
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
        $listener.Start()
        return $true
    } catch {
        return $false
    } finally {
        if ($null -ne $listener) {
            $listener.Stop()
        }
    }
}

function Get-FreePort {
    param(
        [int]$StartPort = 8080,
        [int]$MaxAttempts = 20
    )

    for ($port = $StartPort; $port -lt ($StartPort + $MaxAttempts); $port++) {
        if (Test-PortAvailable -Port $port) {
            return $port
        }
    }

    throw "Ne udalos nayti svobodnyy port nachinaya s $StartPort"
}
