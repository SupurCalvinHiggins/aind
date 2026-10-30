Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force -Path encrypted-volume | Out-Null
Write-Output "Open: http://127.0.0.1:6080/vnc.html?autoconnect=true&resize=scale"
docker compose -f compose.web.yaml run --rm anki
