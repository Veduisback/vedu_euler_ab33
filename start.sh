#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting NeuralHats..."

# Cleanup function — kills both processes on exit for any reason
cleanup() {
    [ -n "$BACKEND_PID" ] && kill "$BACKEND_PID" 2>/dev/null
    [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null
    [ -n "$BACKEND_PID" ] || [ -n "$FRONTEND_PID" ] && echo "NeuralHats stopped."
}
trap cleanup INT TERM EXIT

# Check venv exists before attempting to start
cd "$SCRIPT_DIR/backend"
if [ ! -f ".venv/bin/activate" ]; then
    echo "[ERROR] Python virtual environment not found. Run ./setup.sh first."
    exit 1
fi

# Check all 6 hat models are present in Ollama
if ! command -v ollama &> /dev/null; then
    echo "[ERROR] Ollama not found. Install it from https://ollama.com first."
    exit 1
fi
if ! OLLAMA_LIST=$(ollama list 2>/dev/null); then
    echo "[ERROR] Ollama is not running. Start Ollama and try again."
    exit 1
fi
MISSING_MODELS=""
for HAT in white black green red yellow blue facilitator; do
    if ! echo "$OLLAMA_LIST" | grep -qF "neuralhats-$HAT"; then
        MISSING_MODELS="$MISSING_MODELS neuralhats-$HAT"
    fi
done
if [ -n "$MISSING_MODELS" ]; then
    echo "[ERROR] Missing Ollama models:$MISSING_MODELS. Run ./setup.sh first."
    exit 1
fi

# Start backend
source .venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
sleep 1
if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "[ERROR] Backend failed to start. Check the error above."
    exit 1
fi
echo "[OK] Backend started (PID $BACKEND_PID)"

# Start frontend
cd "$SCRIPT_DIR/frontend"
npm run dev &
FRONTEND_PID=$!
sleep 1
if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
    echo "[ERROR] Frontend failed to start. Check the error above."
    exit 1
fi
echo "[OK] Frontend started (PID $FRONTEND_PID)"

# Open browser after a short delay
sleep 2
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:5173
elif command -v open &> /dev/null; then
    open http://localhost:5173
else
    echo "   Open your browser and go to http://localhost:5173"
fi

echo ""
echo "NeuralHats is running at http://localhost:5173"
echo "   Press Ctrl+C to stop."

wait
