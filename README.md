# NeuralHats

<div align="center">
  <img src="frontend/public/cover.jpg" alt="NeuralHats" width="100%" />

  <p align="center">
  <strong>Six AI personas. One structured debate. Every perspective covered</strong>
</p>

<br />

  ![Version](https://img.shields.io/badge/version-0.1.0-blue)
  ![License](https://img.shields.io/badge/license-MIT-green)
  ![Python](https://img.shields.io/badge/python-3.11+-yellow)
  ![React](https://img.shields.io/badge/react-19-61dafb)
  ![Ollama](https://img.shields.io/badge/powered%20by-Ollama-black)

  **[🎥 Demo Video](#)** · **[📖 Article](#)** · **[🐛 Report a Bug](https://github.com/georgekobaidze/neuralhats/issues)**

</div>

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Security](#security)
- [How to Contribute](#how-to-contribute)
- [What's Next](#whats-next)
- [License](#license)
- [Acknowledgements](#acknowledgements)
- [Author](#author)

---

## About

**NeuralHats** brings Edward de Bono's legendary [Six Thinking Hats](https://en.wikipedia.org/wiki/Six_Thinking_Hats) framework to life through AI. Instead of reading about the method, you experience it. Six distinct AI personas debate any topic you choose, each embodying a different mode of thinking.

Each hat is a fully independent AI model persona powered by **Gemma 4** via **Ollama**, with its own system prompt, voice, and reasoning style:

| Hat | Role | Focus |
|-----|------|-------|
| ⚪ **White** | The Analyst | Pure facts, data, and objective information |
| ⚫ **Black** | The Critic | Risks, flaws, and devil's advocacy |
| 🟢 **Green** | The Creative | Bold ideas, lateral thinking, alternatives |
| 🔴 **Red** | The Feeler | Emotions, gut instinct, raw reaction |
| 🟡 **Yellow** | The Optimist | Value, benefits, and opportunity |
| 🔵 **Blue** | The Facilitator | Manages the process, decides when to stop |

Debates run for up to **5 rounds**, with the Blue Hat deciding after each round whether the discussion should continue or conclude. At the end, a dedicated **Facilitator AI** synthesises the entire debate into a structured report with a final recommendation.

You can observe as a neutral party, or **play one of the hats yourself**, injecting your own perspective into the debate alongside the AI personas.

Three debate contexts are available: **Boardroom**, **Workshop**, and **Research Lab**, each shifting the tone and vocabulary of all six personas to match the setting.

---

## Features

### Structured AI Debate Engine
- **Six independent AI personas:** each hat is a custom-prompted Gemma 4 model with its own reasoning style and voice
- **Fixed debate order:** White → Black → Green → Red → Yellow → Blue, ensuring every perspective is heard every round
- **Dynamic rounds:** the Blue Hat (Facilitator) evaluates progress after each round and issues a `CONTINUE` or `STOP` decision, capping at 5 rounds
- **Context-aware personas:** all six hats adapt their tone to the selected context (Boardroom, Workshop, Research Lab)

### AI-Generated Report
- After every debate, a dedicated **Facilitator AI** synthesises the full conversation into a structured report
- Includes a **final recommendation**, key arguments from each hat, and a summary of the discussion
- **PDF export:** download the full report as a styled PDF with one click

### Interactive Participation
- **Play a hat:** choose any hat before the debate starts; your turn is prompted mid-round alongside the AI personas
- **Observer mode:** sit back and watch all six AI personas debate without intervening

### Real-Time Streaming
- Debate progress is delivered via **Server-Sent Events (SSE)** as each hat completes its turn — follow the discussion live without waiting for the entire debate to finish
- Thinking indicator and live typewriter effect present each completed hat turn in real time

### Debate Persistence
- Every debate is stored in a local **SQLite** database
- Resume a debate from the **History** panel, all previous turns restored in full
- Delete individual debates or clear history entirely

### Cinematic UI
- Animated **Hat Carousel** on the landing page with per-hat typewriter descriptions
- Neon-accented dark theme with per-hat colour identity throughout the UI
- Desktop-first interface with a minimum supported width of 768px
- Hat Guide, About, and What's Next modals

---

## Tech Stack

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| [React](https://react.dev) | 19 | UI framework |
| [TypeScript](https://www.typescriptlang.org) | 6 | Type safety |
| [Vite](https://vite.dev) | 8 | Build tool & dev server |
| [Tailwind CSS](https://tailwindcss.com) | v4 | Utility-first styling |
| [React Router](https://reactrouter.com) | 7 | Client-side routing |
| [react-markdown](https://github.com/remarkjs/react-markdown) | 10 | Markdown rendering in reports |
| [jsPDF](https://github.com/parallax/jsPDF) + [html2canvas](https://html2canvas.hertzen.com) | latest | PDF export |

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| [FastAPI](https://fastapi.tiangolo.com) | 0.115+ | REST API & SSE streaming |
| [Uvicorn](https://www.uvicorn.org) | 0.30+ | ASGI server |
| [httpx](https://www.python-httpx.org) | 0.27+ | Async HTTP client for Ollama |
| [aiosqlite](https://github.com/omnilib/aiosqlite) | 0.20+ | Async SQLite access |
| [python-dotenv](https://github.com/theskumar/python-dotenv) | 1.0+ | Environment configuration |

### AI & Infrastructure
| Technology | Purpose |
|------------|---------|
| [Gemma 4](https://ai.google.dev/gemma) | LLM powering all six hat personas |
| [Ollama](https://ollama.com) | Local model runtime |
| 7 custom Modelfiles | 6 Per-hat system prompts + 1 dedicated Facilitator for report synthesis |
| SQLite | Local debate history storage |
| Server-Sent Events (SSE) | Real-time token streaming to the frontend |

---

## Architecture

![Architecture Diagram](frontend/public/neuralhats-diagram.png)

NeuralHats is split into three layers: a React frontend, a FastAPI backend, and a local Ollama model runtime.

### Request Flow

1. **Debate creation:** The frontend sends a `POST /debates` request with the topic, context, and optional user hat selection. The backend creates a debate record in SQLite and returns the debate ID.

2. **Streaming:** The frontend opens an SSE connection to `GET /debates/{id}/stream`. The Orchestrator begins the debate loop, calling each hat persona in order via the Ollama client.

3. **Debate loop:** Each round runs White → Black → Green → Red → Yellow → Blue. Each hat generates its full response via Ollama (non-streaming), then the completed turn is emitted as an SSE event to the frontend and persisted to SQLite.

4. **Blue Hat decision:** After each round, the Orchestrator parses the Blue Hat's response for a `CONTINUE` or `STOP` token. If `STOP` is issued or 5 rounds have elapsed, the debate ends.

5. **Report synthesis:** Once the debate concludes, the dedicated Facilitator model receives the full conversation history and produces a structured report with a final recommendation. The report is stored in SQLite and rendered on the Report page.

6. **PDF export:** The frontend captures the rendered report via `html2canvas` and generates a downloadable PDF with `jsPDF`.

### Key Design Decisions

- **One model per hat:** each hat is a separate Ollama model with its own Modelfile, giving complete isolation of persona and system prompt with no cross-contamination between hats.
- **SSE over WebSockets:** one-directional streaming from server to client is sufficient; SSE is simpler, HTTP-native, and reconnects automatically.
- **Local-first:** all inference runs on the user's machine via Ollama. No API keys, no cloud dependencies, no data leaving the device.

---

## Project Structure

```
neuralhats/
├── backend/
│   ├── modelfiles/
│   │   └── prompts/          # System prompt .txt files for each hat + facilitator
│   ├── main.py               # FastAPI app, all HTTP endpoints, SSE route
│   ├── orchestrator.py       # Debate loop, round management, queue handling
│   ├── ollama_client.py      # Async HTTP client for Ollama
│   ├── database.py           # SQLite schema, init, and shared query/write helpers
│   ├── models.py             # Enums: HatColor, DebateMode, DebateStatus
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/
│   ├── public/               # Static assets (cover, favicons, hat icons, diagram)
│   └── src/
│       ├── api/
│       │   └── client.ts     # All backend API calls
│       ├── components/
│       │   ├── debate/       # Debate page components
│       │   ├── landing/      # Landing page components (ParticleNetwork)
│       │   ├── layout/       # Navbar, HatCarousel
│       │   ├── modals/       # All modal dialogs
│       │   └── shared/       # HatIcon, UnsupportedScreen
│       ├── hooks/
│       │   └── useDebateStream.ts  # SSE consumer, full debate state
│       ├── pages/            # Landing, Debate, Report
│       ├── types/            # TypeScript interfaces
│       └── constants.ts      # Hat colours, labels, shared constants
│
├── setup.ps1 / setup.sh      # Creates Ollama models from Modelfiles
├── start.ps1 / start.sh      # Starts backend + frontend together
└── README.md
```

---

## Getting Started

### Prerequisites

Before you begin, make sure you have the following installed:

| Tool | Version | Download |
|------|---------|---------|
| [Ollama](https://ollama.com) | Latest | https://ollama.com |
| [Python](https://python.org) | 3.11+ | https://python.org |
| [Node.js](https://nodejs.org) | 20.19+ or 22.12+ | https://nodejs.org |
| [Git](https://git-scm.com) | Any | https://git-scm.com |

You will also need approximately **10 GB of free disk space** for the default model (`gemma4:e4b`).

**GPU recommended:** Gemma 4 runs on CPU but will be significantly slower. An NVIDIA or Apple Silicon GPU will give a much better experience.

---

### 1. Clone the repository

```bash
git clone https://github.com/georgekobaidze/neuralhats.git
cd neuralhats
```

---

### 2. Start Ollama

Make sure Ollama is running before you proceed. If it isn't already running:

**Windows / macOS**: open the Ollama app from your Applications or system tray.

**Linux:**
```bash
ollama serve
```

You can verify it's running by visiting http://localhost:11434 in your browser, you should see `Ollama is running`.

---

### 3. Configure (optional)

By default, NeuralHats uses `gemma4:e4b` as the base model. If you want to use a different Gemma 4 variant, copy the example env file and edit it:

**Windows:**
```powershell
Copy-Item backend\.env.example backend\.env
notepad backend\.env
```

**macOS / Linux:**
```bash
cp backend/.env.example backend/.env
nano backend/.env  # or your preferred editor
```

Available settings in `.env`:

```env
NEURALHATS_BASE_MODEL=gemma4:e4b   # Change to e.g. gemma4:26b
OLLAMA_URL=http://localhost:11434  # Change if Ollama runs on a different port
FRONTEND_URL=http://localhost:5173 # Change if you run the frontend elsewhere
DB_PATH=neuralhats.db              # Path to the SQLite database file
```

> If you skip this step, all settings fall back to their defaults and `.env` is not required to run NeuralHats.

---

### 4. Run the setup script

The setup script will:
- Check all prerequisites
- Download the base model from Ollama (you will be prompted to confirm)
- Create all **7 custom Ollama models** (6 hats + 1 facilitator)
- Create a Python virtual environment and install dependencies
- Install frontend Node.js dependencies

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

> **Note:** If you get a script execution error, run this first to allow local scripts:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

**macOS / Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

The model download may take a while depending on your internet speed:

| Model | 4-bit | 16-bit | Comfortable GPU |
|-------|-------|--------|----------------|
| `gemma4:e2b` | 3.2 GB | 9.6 GB | Anything |
| `gemma4:e4b` ✅ default | 5 GB | 15 GB | 8–12 GB GPUs |
| `gemma4:26b` (26B MoE) | 15.6 GB | 48 GB | 24 GB GPU |
| `gemma4:31b` (31B Dense) | 17.4 GB | 58.3 GB | 32 GB+ GPU |

> Ollama runs models in 4-bit quantization by default. CPU-only machines can run any variant but expect slower responses.

When prompted, type `y` to confirm the download.

Once setup completes you should see:
```
[OK] Setup complete! Run .\start.ps1 to launch NeuralHats.
```

---

### 5. Launch NeuralHats

**Windows:**
```powershell
.\start.ps1
```

**macOS / Linux:**
```bash
chmod +x start.sh
./start.sh
```

The start script will:
1. Verify Ollama is running and all hat models are present
2. Start the FastAPI backend on **port 8000**
3. Start the Vite dev server on **port 5173**
4. Automatically open http://localhost:5173 in your browser

Press `Ctrl+C` at any time to stop both servers.

---

### Manual Setup (advanced)

If you prefer to run things individually:

**Backend:**
```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

**Frontend** (in a separate terminal):
```bash
cd frontend
npm install
npm run dev
```

**Ollama models** (if not run setup script):
```bash
./setup.sh   # or .\setup.ps1 on Windows
```

---

### Troubleshooting

**`Ollama is not running`:** Make sure Ollama is open and running before starting. Check http://localhost:11434.

**`Missing Ollama models`:** Re-run `.\setup.ps1` / `./setup.sh`. The models may not have been created on a previous attempt.

**`Python not found` on Windows:** Make sure Python is added to your PATH during installation. Re-install Python and check "Add to PATH".

**Slow responses:** This is normal on CPU-only machines. Consider using a smaller model variant (`gemma4:e4b`) or a machine with a dedicated GPU.

**Port already in use:** If port 8000 or 5173 is taken, stop the conflicting process or edit the start script to use different ports.

---

## Configuration

### Environment Variables

All configuration lives in `backend/.env`. Copy the example file to get started:

```bash
cp backend/.env.example backend/.env   # macOS / Linux
Copy-Item backend\.env.example backend\.env  # Windows
```

| Variable | Default | Description |
|----------|---------|-------------|
| `NEURALHATS_BASE_MODEL` | `gemma4:e4b` | Gemma 4 variant to use for all hat models. Changed at setup time, re-run `setup.ps1` / `setup.sh` after changing. |
| `OLLAMA_URL` | `http://localhost:11434` | URL of the Ollama server. Change if Ollama runs on a different host or port. |
| `FRONTEND_URL` | `http://localhost:5173` | Frontend origin allowed by CORS. Change if you serve the frontend from a different URL. |
| `DB_PATH` | `neuralhats.db` | Path to the SQLite database file, relative to the `backend/` directory. |

> All variables have hardcoded fallback defaults — `backend/.env` is optional.

---

### Per-Hat Model Parameters

Each hat model is created with its own temperature and `top_p`, tuned to match its thinking style. These are set in the setup scripts and baked into the Ollama Modelfiles at creation time:

| Hat | Temperature | top_p | Rationale |
|-----|------------|-------|-----------|
| ⚪ White | 0.3 | 0.90 | Factual, low variance |
| ⚫ Black | 0.4 | 0.90 | Critical but consistent |
| 🟢 Green | 0.9 | 0.95 | Creative, high variance |
| 🔴 Red | 0.85 | 0.95 | Emotional, spontaneous |
| 🟡 Yellow | 0.6 | 0.90 | Optimistic, balanced |
| 🔵 Blue | 0.3 | 0.90 | Structured, deterministic |
| 🎩 Facilitator | 0.2 | 0.90 | Analytical, highly consistent |

All models share a context window of **8192 tokens** (`num_ctx`).

To change these values, edit `setup.ps1` / `setup.sh` and re-run the setup script to recreate the models.

---

### Customising Hat Prompts

Each hat's system prompt lives in `backend/modelfiles/prompts/<hat>.txt`. You can edit any prompt to change a hat's persona, tone, or behaviour.

After editing a prompt, re-run the setup script to recreate the affected models with the updated prompt baked in:

**macOS / Linux:**
```bash
./setup.sh
```

**Windows:**
```powershell
.\setup.ps1
```

---

## Security

NeuralHats is a **local-only, single-user tool** and should not be deployed to any server or exposed beyond your own machine. It has no authentication, no rate limiting, and no multi-user isolation — it was never designed for that.

### What's safe by default

- **No external API calls:** all inference runs locally through Ollama. Your debate topics and content never leave your machine.
- **No credentials required:** there are no API keys, tokens, or user accounts. Nothing sensitive to leak.
- **Local SQLite only:** all debate history is stored in a file on your machine. No external database, no cloud sync.
- **CORS restricted:** the backend only accepts requests from the configured `FRONTEND_URL` (default: `http://localhost:5173`).
- **Input validation:** all API inputs are validated via Pydantic. Text fields have length limits enforced server-side.

### What this tool does NOT provide

- ❌ Authentication or authorisation
- ❌ Rate limiting
- ❌ HTTPS (runs plain HTTP locally)
- ❌ Multi-user isolation

---

## What's Next

The foundation is live. Here's where the thinking goes from here.

| Feature | Tag | Description |
|---------|-----|-------------|
| 🎙️ **Voice Mode** | Experience | Each hat speaks in a distinct AI voice. Hear the debate unfold, not just read it. |
| 👥 **Multiplayer Debates** | Collaboration | Invite others to take a hat. Humans and AI thinking together in the same session. |
| 🎭 **Custom Hat Personas** | Customization | Fine-tune each hat's personality, tone, and reasoning style to match your domain. |
| 📋 **Debate Templates** | Productivity | Start faster with curated topic packs: business strategy, ethics, product design, and more. |
| 📄 **Export Formats** | Productivity | Download any debate as a formatted PDF, Markdown file, or structured JSON. |
| 📊 **Insight Analytics** | Intelligence | Track which hats dominate your debates. Spot blind spots in your thinking patterns over time. |
| 🔌 **API Access** | Developer | Trigger debates programmatically. Embed structured AI reasoning into your own products. |
| 📱 **Mobile App** | Platform | A native mobile experience. Debate on the go, with the same depth and polish. |

Have an idea? [Open an issue](https://github.com/georgekobaidze/neuralhats/issues) on GitHub.

---

## How to Contribute

Contributions are welcome! Here's how to get involved.

### Reporting bugs

Open an issue on [GitHub](https://github.com/georgekobaidze/neuralhats/issues) with:
- A clear description of the bug
- Steps to reproduce it
- Your OS, Python version, Node.js version, and Ollama version
- Any relevant error messages or screenshots

### Suggesting features

Open a [GitHub issue](https://github.com/georgekobaidze/neuralhats/issues) with the `enhancement` label. Check the [What's Next](#whats-next) section first, it may already be planned.

### Submitting a pull request

1. **Fork** the repository and create a branch from `develop`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes.** Keep commits focused and atomic.

3. **Test manually** - start the app with `./start.sh` / `.\start.ps1` and verify your changes work end to end.

4. **Open a pull request** against `develop` with a clear description of what you changed and why.

### Code style

- **Backend** - standard Python, type hints encouraged, no formatter enforced
- **Frontend** - TypeScript strict mode, ESLint configured (`npm run lint`), Tailwind utility classes only (no custom CSS unless necessary)
- Keep components small and focused; reuse existing constants from `constants.ts`

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for full details.

Copyright © 2026 Giorgi Kobaidze

---

## Acknowledgements

- **[Edward de Bono](https://en.wikipedia.org/wiki/Edward_de_Bono)** — for inventing the Six Thinking Hats framework that this entire project is built around. The method is 40 years old and still sharper than most modern thinking tools.

- **[Google DeepMind](https://deepmind.google)** — for Gemma 4, the open model that powers every hat and the facilitator.

- **[Ollama](https://ollama.com)** — for making local LLM inference as simple as `ollama run`. Without it, NeuralHats wouldn't exist in its current form.

- **[DEV Community](https://dev.to)** and **[Major League Hacking (MLH)](https://mlh.io)** — for running the [Gemma 4 Challenge](https://dev.to/devteam/join-the-gemma-4-challenge-3000-prize-pool-for-ten-winners-23in) that sparked this project.

- **[FastAPI](https://fastapi.tiangolo.com)**, **[React](https://react.dev)**, **[Vite](https://vite.dev)**, **[Tailwind CSS](https://tailwindcss.com)** — the open-source stack that made building this fast and enjoyable.

---

## Author

<div align="center">
  <img src="frontend/public/giorgi.jpg" alt="Giorgi Kobaidze" width="120" style="border-radius: 50%" />

  ### Giorgi Kobaidze
  *The Builder*

  Software developer and product builder from Georgia, with a passion for tools that amplify human thinking.
  Two-time hackathon winner chasing a third with six hats and a lot of coffee.

  [![GitHub](https://img.shields.io/badge/GitHub-neuralhats-181717?logo=github)](https://github.com/georgekobaidze/neuralhats)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-giorgikobaidze-0A66C2?logo=linkedin)](https://www.linkedin.com/in/giorgikobaidze/)
  [![X](https://img.shields.io/badge/X-georgekobaidze-000000?logo=x)](https://x.com/georgekobaidze)
  [![DEV.TO](https://img.shields.io/badge/DEV.TO-georgekobaidze-0A0A0A?logo=devdotto)](https://dev.to/georgekobaidze)
  [![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord)](https://discord.gg/sjUuC8McVn)
</div>