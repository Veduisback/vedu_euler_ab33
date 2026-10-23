Write-Host "NeuralHats Setup" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModelfilesDir = Join-Path $ScriptDir "backend\modelfiles"
$PromptsDir = Join-Path $ModelfilesDir "prompts"
$Template = Get-Content (Join-Path $ModelfilesDir "Modelfile.template") -Raw

# Read base model from backend/.env (default: gemma4:e4b)
$EnvFile = Join-Path $ScriptDir "backend\.env"
$BaseModel = "gemma4:e4b"
if (Test-Path $EnvFile) {
    $Parsed = Get-Content $EnvFile |
        Where-Object { $_ -match "^NEURALHATS_BASE_MODEL=" } |
        ForEach-Object { $_.Split("=", 2)[1].Trim() } |
        Select-Object -First 1
    if ($Parsed) { $BaseModel = $Parsed }
}
Write-Host "Using base model: $BaseModel" -ForegroundColor Gray

# Per-hat parameters
$HatParams = @{
    white       = @{ temp = "0.3";  top_p = "0.9"  }
    black       = @{ temp = "0.4";  top_p = "0.9"  }
    green       = @{ temp = "0.9";  top_p = "0.95" }
    red         = @{ temp = "0.85"; top_p = "0.95" }
    yellow      = @{ temp = "0.6";  top_p = "0.9"  }
    blue        = @{ temp = "0.3";  top_p = "0.9"  }
    facilitator = @{ temp = "0.2";  top_p = "0.9"  }
}

Write-Host ""
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "Ollama not found. Install it from https://ollama.com and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Ollama found" -ForegroundColor Green

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found. Install it from https://nodejs.org and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Node.js found" -ForegroundColor Green

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Install it from https://python.org and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Python found" -ForegroundColor Green

# Pull base model
Write-Host "`nChecking base model: $BaseModel..." -ForegroundColor Cyan
$AlreadyHave = ollama list 2>$null | Select-String -Pattern "^$([regex]::Escape($BaseModel))\s"
if ($AlreadyHave) {
    Write-Host "[OK] Model '$BaseModel' is already downloaded, skipping pull." -ForegroundColor Green
} else {
    Write-Host "[WARNING] Model '$BaseModel' is not downloaded yet." -ForegroundColor Yellow
    Write-Host "   This can be very large (e.g. gemma4:26b is ~17GB) and may take a long time depending on your internet speed." -ForegroundColor Yellow
    $Confirm = (Read-Host "Do you want to download '$BaseModel' now? (y/n)").Trim().ToLowerInvariant()
    if ($Confirm -notmatch "^(y|yes)$") {
        Write-Host "Skipped model download. Re-run setup when ready." -ForegroundColor Yellow
        exit 0
    }
    ollama pull $BaseModel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to pull base model '$BaseModel'. Check your internet connection and try again." -ForegroundColor Red
        exit 1
    }
}

# Validate prompt files exist before creating models
foreach ($Hat in $HatParams.Keys) {
    $PromptFile = Join-Path $PromptsDir "$Hat.txt"
    if (-not (Test-Path $PromptFile)) {
        Write-Host "[ERROR] Missing prompt file: $PromptFile" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] All prompt files found" -ForegroundColor Green

# Create hat models from template + parameters
Write-Host "`nCreating NeuralHats models..." -ForegroundColor Cyan
$TempDir = Join-Path $env:TEMP "neuralhats_setup_$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

foreach ($Hat in $HatParams.Keys) {
    $Modelfile = $Template
    $Modelfile = $Modelfile.Replace("{{BASE_MODEL}}", $BaseModel)
    $Modelfile = $Modelfile.Replace("{{TEMPERATURE}}", $HatParams[$Hat].temp)
    $Modelfile = $Modelfile.Replace("{{TOP_P}}", $HatParams[$Hat].top_p)
    $TempFile = Join-Path $TempDir "Modelfile.$Hat"
    Set-Content -Path $TempFile -Value $Modelfile -NoNewline -Encoding UTF8
    ollama create "neuralhats-$Hat" -f $TempFile
    if ($LASTEXITCODE -ne 0) {
        Remove-Item -Recurse -Force $TempDir
        Write-Host "Failed to create model for $Hat hat." -ForegroundColor Red
        exit 1
    }
}

Remove-Item -Recurse -Force $TempDir
Write-Host "[OK] All 6 hat models and facilitator model created" -ForegroundColor Green

# Python venv + dependencies
Write-Host "`nSetting up Python environment..." -ForegroundColor Cyan
Set-Location "$ScriptDir\backend"
python -m venv .venv
& ".venv\Scripts\Activate.ps1"
pip install --quiet -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to install Python dependencies." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Python dependencies installed" -ForegroundColor Green

# Frontend dependencies
Write-Host "`nInstalling frontend dependencies..." -ForegroundColor Cyan
Set-Location "$ScriptDir\frontend"
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to install frontend dependencies." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Frontend dependencies installed" -ForegroundColor Green

Set-Location $ScriptDir
Write-Host "`n[OK] Setup complete! Run .\start.ps1 to launch NeuralHats." -ForegroundColor Green
