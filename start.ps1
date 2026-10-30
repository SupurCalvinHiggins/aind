Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force -Path encrypted-volume | Out-Null

function Invoke-Quiet {
    param([ScriptBlock]$Script)
    if ($env:DEBUG -eq '1') {
        & $Script
    } else {
        & $Script *> $null
    }
}

try {
    Invoke-Quiet { docker compose -f compose.web.yaml create --build }
    Invoke-Quiet { docker compose -f compose.web.yaml start relay }
    $container = docker compose -f compose.web.yaml ps -a -q anki
    docker start -ai $container
} finally {
    Invoke-Quiet { docker compose -f compose.web.yaml down }
}
