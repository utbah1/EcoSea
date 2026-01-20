$NGROK_EXE  = "ngrok"
$FLASK_PORT = 5000
$WEB_ADDR   = "127.0.0.1:4040"

Write-Host "Starting ngrok on port $FLASK_PORT ..."
$ngrok = Start-Process -FilePath $NGROK_EXE `
  -ArgumentList "http $FLASK_PORT --web-addr=$WEB_ADDR" `
  -PassThru -WindowStyle Minimized

$apiUrl = "http://$WEB_ADDR/api/tunnels"
$tunnels = $null

for ($i=1; $i -le 20; $i++) {
  if (-not (Get-Process -Id $ngrok.Id -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: ngrok berhenti. Coba jalankan manual: ngrok http $FLASK_PORT"
    exit 1
  }

  try {
    $tunnels = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 1
    break
  } catch {
    Start-Sleep -Milliseconds 500
  }
}

if (-not $tunnels) {
  Write-Host "ERROR: Cannot reach ngrok API at $apiUrl"
  Write-Host "Coba buka di browser: http://$WEB_ADDR"
  Stop-Process -Id $ngrok.Id -Force -ErrorAction SilentlyContinue
  exit 1
}

$https = ($tunnels.tunnels | Where-Object { $_.public_url -like "https://*" } | Select-Object -First 1).public_url
if (-not $https) { $https = $tunnels.tunnels[0].public_url }

Write-Host "NGROK URL: $https"
Write-Host "Running Flutter with API_BASE_URL=$https"

flutter run --dart-define=API_BASE_URL=$https

Write-Host "Stopping ngrok..."
Stop-Process -Id $ngrok.Id -Force -ErrorAction SilentlyContinue