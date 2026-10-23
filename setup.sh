#!/bin/bash
set -e

echo "NeuralHats Setup"
echo "================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELFILES_DIR="$SCRIPT_DIR/backend/modelfiles"
PROMPTS_DIR="$MODELFILES_DIR/prompts"
TEMPLATE="$MODELFILES_DIR/Modelfile.template"

# Read base model from backend/.env (default: gemma4:e4b)
BASE_MODEL="gemma4:e4b"
ENV_FILE="$SCRIPT_DIR/backend/.env"
if [ -f "$ENV_FILE" ]; then
    PARSED=$(grep "^NEURALHATS_BASE_MODEL=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
    [ -n "$PARSED" ] && BASE_MODEL="$PARSED"
fi
echo "Using base model: $BASE_MODEL"

# Per-hat parameters are handled inside the Python substitution below

# Check prerequisites
echo ""
echo "Checking prerequisites..."

if ! command -v ollama &> /dev/null; then
    echo "[ERROR] Ollama not found. Install it from https://ollama.com and re-run this script."
    exit 1
fi
echo "[OK] Ollama found"

if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js not found. Install it from https://nodejs.org and re-run this script."
    exit 1
fi
echo "[OK] Node.js found"

if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 not found. Install it from https://python.org and re-run this script."
    exit 1
fi
echo "[OK] Python found"

# Pull base model
echo ""
echo "Checking base model: $BASE_MODEL..."
if ollama list 2>/dev/null | grep -qE "^${BASE_MODEL}[[:space:]]"; then
    echo "[OK] Model '$BASE_MODEL' is already downloaded, skipping pull."
else
    echo "[WARNING] Model '$BASE_MODEL' is not downloaded yet."
    echo "   This can be very large (e.g. gemma4:e4b is ~9.6GB) and may take a long time depending on your internet speed."
    read -rp "Do you want to download '$BASE_MODEL' now? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy](es)?$ ]]; then
        echo "Skipped model download. Re-run setup when ready."
        exit 0
    fi
    if ! ollama pull "$BASE_MODEL"; then
        echo "[ERROR] Failed to pull base model '$BASE_MODEL'. Check your internet connection and try again."
        exit 1
    fi
fi

# Validate prompt files exist before creating models
for HAT in white black green red yellow blue facilitator; do
    if [ ! -f "$PROMPTS_DIR/$HAT.txt" ]; then
        echo "[ERROR] Missing prompt file: $PROMPTS_DIR/$HAT.txt"
        exit 1
    fi
done

# Create hat models from template + parameters
echo ""
echo "Creating NeuralHats models..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

for HAT in white black green red yellow blue facilitator; do
    python3 - <<PYEOF > "$TEMP_DIR/Modelfile.$HAT"
import sys
params = {
    "white":       {"temp": "0.3",  "top_p": "0.9"},
    "black":       {"temp": "0.4",  "top_p": "0.9"},
    "green":       {"temp": "0.9",  "top_p": "0.95"},
    "red":         {"temp": "0.85", "top_p": "0.95"},
    "yellow":      {"temp": "0.6",  "top_p": "0.9"},
    "blue":        {"temp": "0.3",  "top_p": "0.9"},
    "facilitator": {"temp": "0.2",  "top_p": "0.9"},
}
hat = "$HAT"
template = open("$TEMPLATE").read()
result = (template
    .replace("{{BASE_MODEL}}", "$BASE_MODEL")
    .replace("{{TEMPERATURE}}", params[hat]["temp"])
    .replace("{{TOP_P}}", params[hat]["top_p"]))
sys.stdout.write(result)
PYEOF
    if ! ollama create "neuralhats-$HAT" -f "$TEMP_DIR/Modelfile.$HAT"; then
        rm -rf "$TEMP_DIR"
        echo "[ERROR] Failed to create model for $HAT hat."
        exit 1
    fi
done

rm -rf "$TEMP_DIR"
echo "[OK] All 6 hat models and facilitator model created"

# Python venv + dependencies
echo ""
echo "Setting up Python environment..."
cd "$SCRIPT_DIR/backend"
python3 -m venv .venv
source .venv/bin/activate
pip install --quiet -r requirements.txt
echo "[OK] Python dependencies installed"

# Frontend dependencies
echo ""
echo "Installing frontend dependencies..."
cd "$SCRIPT_DIR/frontend"
npm install --silent
echo "[OK] Frontend dependencies installed"

echo ""
echo "Setup complete! Run ./start.sh to launch NeuralHats."
