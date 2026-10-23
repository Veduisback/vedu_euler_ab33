$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Starting NeuralHats..." -ForegroundColor Cyan

# Check venv exists before attempting to start
if (-not (Test-Path "$ScriptDir\backend\.venv\Scripts\python.exe")) {
    Write-Host "[ERROR] Python virtual environment not found. Run .\setup.ps1 first." -ForegroundColor Red
    exit 1
}

# Check all 6 hat models are present in Ollama
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Ollama not found. Install it from https://ollama.com first." -ForegroundColor Red
    exit 1
}
$OllamaList = ollama list 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Ollama is not running. Start Ollama and try again." -ForegroundColor Red
    exit 1
}
$Hats = @("white","black","green","red","yellow","blue","facilitator")
$MissingModels = $Hats | Where-Object { -not ($OllamaList | Select-String -Quiet "neuralhats-$_") }
if ($MissingModels) {
    Write-Host "[ERROR] Missing Ollama models: $($MissingModels -join ', '). Run .\setup.ps1 first." -ForegroundColor Red
    exit 1
}

# Start backend
$BackendJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location "$dir\backend"
    & ".venv\Scripts\python.exe" -m uvicorn main:app --host 0.0.0.0 --port 8000
} -ArgumentList $ScriptDir
Start-Sleep -Seconds 1
if ($BackendJob.State -ne 'Running') {
    Write-Host "[ERROR] Backend failed to start:" -ForegroundColor Red
    Receive-Job $BackendJob
    Remove-Job $BackendJob
    exit 1
}
Write-Host "[OK] Backend started" -ForegroundColor Green

# Start frontend
$FrontendJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location "$dir\frontend"
    npm run dev
} -ArgumentList $ScriptDir
Start-Sleep -Seconds 1
if ($FrontendJob.State -ne 'Running') {
    Write-Host "[ERROR] Frontend failed to start:" -ForegroundColor Red
    Receive-Job $FrontendJob
    Stop-Job $BackendJob
    Remove-Job $BackendJob, $FrontendJob
    exit 1
}
Write-Host "[OK] Frontend started" -ForegroundColor Green

# Open browser after short delay
Start-Sleep -Seconds 2
Start-Process "http://localhost:5173"

Write-Host "`nNeuralHats is running at http://localhost:5173" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop." -ForegroundColor Gray

try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    Stop-Job $BackendJob, $FrontendJob
    Remove-Job $BackendJob, $FrontendJob
    Write-Host "NeuralHats stopped." -ForegroundColor Yellow
}
