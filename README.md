# NeuralHats
<img width="3178" height="1344" alt="image" src="https://github.com/user-attachments/assets/fbeb463c-cf67-4407-8834-622c450c3965" />

<div align="center">
  

  <p align="center">
  <strong>Six AI personas. One structured debate. Every perspective covered.</strong>
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

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Security Notice](#security-notice)
- [Contribution Guide](#contribution-guide)
- [Roadmap](#roadmap)
- [License](#license)
- [Acknowledgements](#acknowledgements)
- [Author](#author)

---

## Overview

**NeuralHats** digitizes Edward de Bono's acclaimed [Six Thinking Hats](https://en.wikipedia.org/wiki/Six_Thinking_Hats) methodology through an interactive AI platform. Rather than reviewing theoretical concepts, users experience dynamic debates where six distinct AI personas deliberate on any given topic, with each persona embodying a specific cognitive mindset.

Every hat operates as an independent AI model persona running **Gemma 4** through **Ollama**, featuring dedicated system prompts, distinct communication styles, and specialized reasoning approaches:

| Hat | Role | Cognitive Focus |
|-----|------|-----------------|
| ⚪ **White** | The Analyst | Objective data, facts, and empirical information |
| ⚫ **Black** | The Critic | Risk analysis, flaw identification, and critical evaluation |
| 🟢 **Green** | The Creative | Innovative ideas, alternative approaches, and lateral thinking |
| 🔴 **Red** | The Feeler | Emotional perspectives, gut reactions, and intuitive responses |
| 🟡 **Yellow** | The Optimist | Strategic value, potential benefits, and opportunistic outcomes |
| 🔵 **Blue** | The Facilitator | Process management and termination criteria evaluation |

Debate sessions proceed for a maximum of **5 rounds**. Following each round, the Blue Hat assesses discussion progress to determine whether to continue or conclude. Upon completion, an independent **Facilitator AI** aggregates the entire exchange into a structured report complete with actionable recommendations.

Users can participate as neutral observers or **assume the role of any hat**, contributing human input directly into the round sequence alongside the AI personas.

The system supports three thematic environments: **Boardroom**, **Workshop**, and **Research Lab**, each tailoring the persona vocabularies and interaction styles to suit the designated setting.

---

## Key Features

### Structured AI Debate Engine
- **Six Independent AI Personas:** Custom-prompted Gemma 4 models running distinct reasoning workflows and dialogue traits.
- **Ordered Execution Sequence:** Standardized iteration order (White → Black → Green → Red → Yellow → Blue) ensuring comprehensive round participation.
- **Adaptive Duration Control:** Continuous evaluation by the Blue Hat (Facilitator) issuing `CONTINUE` or `STOP` directives, bounded by a 5-round limit.
- **Contextual Adaptation:** Real-time alignment of persona vocabularies to the chosen domain context (Boardroom, Workshop, or Research Lab).

### Automated Synthesis & Reporting
- Comprehensive post-debate analysis executed by a dedicated **Facilitator AI** model.
- Generation of structured summaries containing **final recommendations**, individual hat argument summaries, and full discussion breakdowns.
- **One-Click PDF Export:** Instant conversion of rendered reports into formatted PDF documents.

### Interactive User Engagement
- **Direct Persona Roleplay:** Manual assignment of user control to any hat prior to initiation, prompting human input mid-round.
- **Passive Observation Mode:** Real-time monitoring of autonomous AI multi-agent deliberations.

### Real-Time Event Streaming
- Live distribution of round progression using **Server-Sent Events (SSE)**.
- Real-time visual formatting featuring thinking indicators and live typewriter output rendering each hat's turn upon completion.

### Local Data Persistence
- Automatic recording of all debate instances into a local **SQLite** database.
- Full session recovery via the **History** interface with complete turn restoration.
- Session management capabilities allowing individual item deletion or full history erasure.

### Responsive Interface
- Interactive **Hat Carousel** on the primary interface featuring typewriter-driven persona breakdowns.
- Neon-accented dark interface incorporating color-coded visual cues mapped to individual hats.
- Optimized layout targeted at desktop displays (minimum supported width: 768px).
- Embedded Modal windows providing access to the Hat Guide, Project Background, and Roadmap.

---

## Tech Stack

### Frontend Components
| Technology | Version | Application |
|------------|---------|-------------|
| [React](https://react.dev) | 19 | Primary UI Framework |
| [TypeScript](https://www.typescriptlang.org) | 6 | Type Checking & Code Quality |
| [Vite](https://vite.dev) | 8 | Build Pipeline & Local Server |
| [Tailwind CSS](https://tailwindcss.com) | v4 | Utility Styling Framework |
| [React Router](https://reactrouter.com) | 7 | Navigation Handling |
| [react-markdown](https://github.com/remarkjs/react-markdown) | 10 | Report Document Formatting |
| [jsPDF](https://github.com/parallax/jsPDF) + [html2canvas](https://html2canvas.hertzen.com) | Latest | Client-side PDF Generation |

### Backend Infrastructure
| Technology | Version | Application |
|------------|---------|-------------|
| [FastAPI](https://fastapi.tiangolo.com) | 0.115+ | API Gateway & Event Streaming |
| [Uvicorn](https://www.uvicorn.org) | 0.30+ | ASGI Application Server |
| [httpx](https://www.python-httpx.org) | 0.27+ | Asynchronous Ollama Integration |
| [aiosqlite](https://github.com/omnilib/aiosqlite) | 0.20+ | Asynchronous SQLite Driver |
| [python-dotenv](https://github.com/theskumar/python-dotenv) | 1.0+ | Configuration Loading |

### AI Model Runtime & Data Layer
| Component | Function |
|-----------|----------|
| [Gemma 4](https://ai.google.dev/gemma) | Base LLM driving persona interactions |
| [Ollama](https://ollama.com) | Local Model Execution Engine |
| 7 Custom Modelfiles | 6 Persona-specific System Prompts + 1 Synthesis Engine |
| SQLite Database | Local Storage Engine for Debate Records |
| Server-Sent Events (SSE) | Event Channel for Streaming Backend Responses |

---

## System Architecture

<img width="1203" height="673" alt="image" src="https://github.com/user-attachments/assets/089b9aa2-5111-4540-b835-d36ecb85bf9b" />


NeuralHats utilizes a three-tier architecture comprising a React client, a FastAPI web application, and a local Ollama model runtime.

### Execution Workflow

1. **Session Initialization:** The client issues a `POST /debates` payload supplying the target topic, domain context, and optional human hat assignment. The server instantiates a SQLite entry and returns the generated debate identifier.

2. **Stream Establishment:** The client connects to the event stream at `GET /debates/{id}/stream`. The backend Orchestrator triggers the main execution loop, querying persona endpoints in designated order through the internal Ollama client.

3. **Round Execution:** Rounds process sequentially across White → Black → Green → Red → Yellow → Blue. Every persona outputs its turn via Ollama, following which the backend broadcasts the turn payload via SSE and writes the result to SQLite.

4. **Termination Processing:** Concluding each round, the Orchestrator checks the Blue Hat output for a `CONTINUE` or `STOP` directive. Meeting a `STOP` instruction or reaching 5 completed rounds initiates session termination.

5. **Report Generation:** Following termination, the dedicated Facilitator model processes the accumulated conversation transcript to generate a structured evaluation document containing strategic recommendations, which is stored in SQLite and transmitted to the client.

6. **Document Export:** The client converts rendered document elements into an offline PDF document using `html2canvas` combined with `jsPDF`.

### Architectural Principles

- **Isolated Persona Enclaves:** Individual personas leverage dedicated Modelfiles inside Ollama, maintaining isolation between instructions and preventing prompt contamination.
- **Unidirectional Event Streaming:** Utilizes HTTP-native SSE rather than bi-directional WebSockets to minimize overhead, simplify client state, and provide automatic reconnects.
- **Private Hardware Runtime:** All model inference executes locally using Ollama. No external API keys or remote cloud transmissions are required.

---

## Repository Structure

```
neuralhats/
├── backend/
│   ├── modelfiles/
│   │   └── prompts/          # System prompt text configurations for hats and facilitator
│   ├── main.py               # Application entry point, HTTP routing, SSE handlers
│   ├── orchestrator.py       # Loop execution, round state control, queue handling
│   ├── ollama_client.py      # Async client abstraction for Ollama interaction
│   ├── database.py           # Database schemas, initialization, and query utilities
│   ├── models.py             # Domain Enums (HatColor, DebateMode, DebateStatus)
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/
│   ├── public/               # Static web assets (branding, icons, system diagrams)
│   └── src/
│       ├── api/
│       │   └── client.ts     # Backend client communication module
│       ├── components/
│       │   ├── debate/       # Debate session components
│       │   ├── landing/      # Landing page elements (ParticleNetwork)
│       │   ├── layout/       # Navigation bar, HatCarousel
│       │   ├── modals/       # Dialog views
│       │   └── shared/       # Shared assets (HatIcon, UnsupportedScreen)
│       ├── hooks/
│       │   └── useDebateStream.ts  # Custom SSE hook managing session state
│       ├── pages/            # View pages (Landing, Debate, Report)
│       ├── types/            # TypeScript interface definitions
│       └── constants.ts      # Visual themes, labels, global constants
│
├── setup.ps1 / setup.sh      # Model setup scripts for Ollama Modelfile build
├── start.ps1 / start.sh      # Dual-process startup scripts
└── README.md
```

---

## Getting Started

### System Requirements

Verify the following tools are installed before proceeding:

| Dependency | Minimum Version | Download Source |
|------------|-----------------|-----------------|
| [Ollama](https://ollama.com) | Latest | https://ollama.com |
| [Python](https://python.org) | 3.11+ | https://python.org |
| [Node.js](https://nodejs.org) | 20.19+ or 22.12+ | https://nodejs.org |
| [Git](https://git-scm.com) | Any | https://git-scm.com |

**Storage Requirement:** Ensure at least **10 GB of available disk space** for downloading the default model image (`gemma4:e4b`).

**Hardware Note:** Hardware acceleration via an NVIDIA or Apple Silicon GPU is recommended for optimal inference speed, though CPU execution remains fully functional.

---

### 1. Repository Cloning

```bash
git clone https://github.com/georgekobaidze/neuralhats.git
cd neuralhats
```

---

### 2. Runtime Initialization

Ensure the local Ollama daemon is active prior to system launch:

**Windows / macOS**: Run the Ollama application through your system interface.

**Linux:**
```bash
ollama serve
```

Confirm service readiness by navigating to `http://localhost:11434` in a browser. An active service returns `Ollama is running`.

---

### 3. Environment Setup (Optional)

By default, the platform runs using `gemma4:e4b`. To select an alternative model architecture, establish a customized configuration file:

**Windows:**
```powershell
Copy-Item backend\.env.example backend\.env
notepad backend\.env
```

**macOS / Linux:**
```bash
cp backend/.env.example backend/.env
nano backend/.env  # or alternative text editor
```

Configurable parameters in `.env`:

```env
NEURALHATS_BASE_MODEL=gemma4:e4b   # Target base model variant (e.g., gemma4:26b)
OLLAMA_URL=http://localhost:11434  # Ollama server connection URL
FRONTEND_URL=http://localhost:5173 # Allowed CORS client origin
DB_PATH=neuralhats.db              # Relative path for SQLite storage
```

> If no custom environment file is created, default values are applied automatically.

---

### 4. System Setup Execution

Run the setup utility to execute the following tasks:
- Validate local development dependencies.
- Pull the required base model from Ollama (confirmation prompt required).
- Construct the **7 custom Ollama instances** (6 persona hats + 1 facilitator engine).
- Initialize the Python virtual environment and install backend packages.
- Download and link Node.js client packages.

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

> **Script Execution Policy Note:** If execution is restricted on Windows, apply the following command first:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

**macOS / Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

Model downloads depend on local connection performance:

| Variant | 4-bit Quantized | 16-bit Unquantized | Recommended VRAM |
|---------|-----------------|--------------------|------------------|
| `gemma4:e2b` | 3.2 GB | 9.6 GB | General Systems |
| `gemma4:e4b` ✅ (Default) | 5.0 GB | 15.0 GB | 8–12 GB VRAM |
| `gemma4:26b` (26B MoE) | 15.6 GB | 48.0 GB | 24 GB VRAM |
| `gemma4:31b` (31B Dense) | 17.4 GB | 58.3 GB | 32 GB+ VRAM |

> Ollama applies 4-bit quantization by default. CPU execution works across all variants at lower token generation rates.

When prompted during script execution, enter `y` to approve downloading.

Successful execution outputs:
```
[OK] Setup complete! Run .\start.ps1 to launch NeuralHats.
```

---

### 5. Application Launch

**Windows:**
```powershell
.\start.ps1
```

**macOS / Linux:**
```bash
chmod +x start.sh
./start.sh
```

The start script executes the following automated routines:
1. Verifies that the Ollama process and custom model images are ready.
2. Initializes the FastAPI server process on **port 8000**.
3. Launches the Vite development web server on **port 5173**.
4. Opens the default web browser to `http://localhost:5173`.

Use `Ctrl+C` to terminate active services simultaneously.

---

### Manual Installation Steps (Advanced)

To manually initialize application layers independently:

**Backend Service:**
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

**Frontend Application** (in a separate terminal process):
```bash
cd frontend
npm install
npm run dev
```

**Ollama Model Assembly** (if bypassing automated setup scripts):
```bash
./setup.sh   # or .\setup.ps1 on Windows
```

---

### Troubleshooting Common Issues

**`Ollama is not running`:** Verify that the background daemon is active by querying `http://localhost:11434`.

**`Missing Ollama models`:** Re-run `.\setup.ps1` or `./setup.sh` to complete build operations that failed previously.

**`Python not found` (Windows):** Verify that Python is added to system environment path variables during setup. Re-run the installation package and enable "Add to PATH".

**Reduced Output Generation Rates:** This behavior is expected when running models purely on CPU hardware. Select a lighter model configuration (`gemma4:e4b`) or deploy on dedicated graphics hardware.

**Network Port Conflicts:** If local ports 8000 or 5173 are unavailable, update port references within the application startup scripts.

---

## Configuration

### Global Parameters

Service settings are maintained inside `backend/.env`. Initialize configuration files using the provided template:

```bash
cp backend/.env.example backend/.env   # macOS / Linux
Copy-Item backend\.env.example backend\.env  # Windows
```

| Parameter Name | Default Value | Description |
|----------------|---------------|-------------|
| `NEURALHATS_BASE_MODEL` | `gemma4:e4b` | Base Gemma 4 model variant. Modifying requires re-running build scripts. |
| `OLLAMA_URL` | `http://localhost:11434` | Address location for the Ollama runtime. |
| `FRONTEND_URL` | `http://localhost:5173` | Approved origin for server CORS headers. |
| `DB_PATH` | `neuralhats.db` | Relative location path for SQLite database files. |

> Defaults are embedded directly within application logic; manual creation of `backend/.env` remains optional.

---

### Per-Hat Model Parameters

Every persona configuration utilizes specific temperature and `top_p` sampling settings to encourage appropriate reasoning styles. These settings are compiled directly into Ollama Modelfiles during installation:

| Hat | Temperature | top_p | Strategic Alignment |
|-----|-------------|-------|---------------------|
| ⚪ White | 0.3 | 0.90 | Low variance, analytical output |
| ⚫ Black | 0.4 | 0.90 | Predictable critical evaluation |
| 🟢 Green | 0.9 | 0.95 | High entropy, exploratory outputs |
| 🔴 Red | 0.85 | 0.95 | Expressive, intuitive responses |
| 🟡 Yellow | 0.6 | 0.90 | Balanced, opportunistic focus |
| 🔵 Blue | 0.3 | 0.90 | Deterministic control logic |
| 🎩 Facilitator | 0.2 | 0.90 | Highly consistent analytical aggregation |

All models operate using an expanded context threshold of **8192 tokens** (`num_ctx`).

To modify parameter values, alter `setup.ps1` or `setup.sh` and execute build scripts to recompile custom model profiles.

---

### Customizing System Prompts

Persona definition text files reside within `backend/modelfiles/prompts/<hat>.txt`. Editing these text files allows developers to modify persona attributes, dialogue styles, and analytical boundaries.

Recompile model builds after modifying prompt content:

**macOS / Linux:**
```bash
./setup.sh
```

**Windows:**
```powershell
.\setup.ps1
```

---

## Security Notice

NeuralHats is engineered explicitly as a **locally contained, single-user environment**. It is not designed for public deployment or multi-tenant hosting. The platform does not incorporate user authentication layers, access throttling, or tenant isolation boundaries.

### Embedded Security Controls

- **Private Execution Boundaries:** Operations execute locally through Ollama without sending debate data to external services.
- **Credential-Free Operation:** No secret API keys, authorization tokens, or user state databases are required.
- **Local Storage Isolation:** Data records remain strictly within local SQLite files.
- **CORS Source Enforcement:** Origin access is bounded by the configured `FRONTEND_URL` parameter (`http://localhost:5173`).
- **Schema Validation:** API inputs pass through Pydantic boundary checks featuring defined length constraints.

### Out-of-Scope Capabilities

- ❌ User identity authentication or permission authorization systems
- ❌ API request rate limiting
- ❌ Encrypted Transport Layer (HTTPS)
- ❌ Multi-tenant data segregation

---

## Roadmap

Planned functionality enhancements for upcoming releases:

| Feature | Category | Description |
|---------|----------|-------------|
| 🎙️ **Voice Mode** | Experience | Audio output synthesis generating distinct voice profiles for each active hat persona. |
| 👥 **Multiplayer Debates** | Collaboration | Shared multi-user sessions mixing human contributors and AI models within a single session. |
| 🎭 **Custom Hat Personas** | Customization | System features allowing fine-grained editing of persona logic, tone, and domain expertise. |
| 📋 **Debate Templates** | Productivity | Pre-configured debate environments designed for strategy, ethics, product design, and risk analysis. |
| 📄 **Export Formats** | Productivity | Multi-format compilation output including PDF, raw Markdown, and structured JSON structures. |
| 📊 **Insight Analytics** | Intelligence | Visual analytics identifying cognitive biases and persona participation balances across historical sessions. |
| 🔌 **API Access** | Developer | Direct programmatic access enabling integration of structured debate loops into third-party tools. |
| 📱 **Mobile App** | Platform | Dedicated mobile software client maintaining full platform styling and capability parity. |

Feature requests can be logged through the [GitHub Issue Tracker](https://github.com/georgekobaidze/neuralhats/issues).

---

## Contribution Guide

Community contributions are welcome. Use the guidelines below to participate in development.

### Reporting Bugs

Submit detailed reports to the [GitHub Issues](https://github.com/georgekobaidze/neuralhats/issues) page including:
- Clear issue summaries.
- Step-by-step reproduction instructions.
- System information (OS, Python, Node.js, and Ollama version metrics).
- Diagnostic logs and relevant user interface captures.

### Submitting Feature Requests

Open a proposal inside [GitHub Issues](https://github.com/georgekobaidze/neuralhats/issues) applying the `enhancement` tag. Verify that the suggestion does not duplicate existing entries in the [Roadmap](#roadmap).

### Code Submission Workflow

1. **Fork** the repository and create a working feature branch off `develop`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Develop changes.** Keep individual commit payloads focused and descriptive.

3. **Perform local testing.** Execute end-to-end operational checks using `./start.sh` or `.\start.ps1`.

4. **Submit a Pull Request** pointing to `develop`, detailing modified components and design rationale.

### Development Standards

- **Backend:** Modern Python implementation featuring standard typing structures.
- **Frontend:** Strict TypeScript validation, ESLint enforcement (`npm run lint`), and utility-first Tailwind CSS classes.
- **Modularity:** Maintain focused component boundaries and import global layout declarations from `constants.ts`.

---

## License

This source code is made available under the terms of the **MIT License**. Review the [LICENSE](LICENSE) file for complete text.

Copyright © 2026 Giorgi Kobaidze

---

## Acknowledgements

- **[Edward de Bono](https://en.wikipedia.org/wiki/Edward_de_Bono)** — Creator of the Six Thinking Hats framework that underpins the operational model of this platform.

- **[Google DeepMind](https://deepmind.google)** — Creators of Gemma 4, the foundation model driving persona interactions across the application.

- **[Ollama](https://ollama.com)** — Developers of the open-source local inference engine facilitating local multi-agent deployment.

- **[DEV Community](https://dev.to)** and **[Major League Hacking (MLH)](https://mlh.io)** — Organizers of the [Gemma 4 Challenge](https://dev.to/devteam/join-the-gemma-4-challenge-3000-prize-pool-for-ten-winners-23in), which inspired the creation of this project.

- **[FastAPI](https://fastapi.tiangolo.com)**, **[React](https://react.dev)**, **[Vite](https://vite.dev)**, **[Tailwind CSS](https://tailwindcss.com)** — Open-source frameworks utilized across the system stack.

---

## Author

<div align="center">
  <img src="frontend/public/giorgi.jpg" alt="Giorgi Kobaidze" width="120" style="border-radius: 50%" />

  ### Giorgi Kobaidze
  *The Builder*

  Software developer and product builder from Georgia, focused on building tools that amplify human reasoning.
  Two-time hackathon winner continuing the journey with six hats and plenty of coffee.

  [![GitHub](https://img.shields.io/badge/GitHub-neuralhats-181717?logo=github)](https://github.com/georgekobaidze/neuralhats)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-giorgikobaidze-0A66C2?logo=linkedin)](https://www.linkedin.com/in/giorgikobaidze/)
  [![X](https://img.shields.io/badge/X-georgekobaidze-000000?logo=x)](https://x.com/georgekobaidze)
  [![DEV.TO](https://img.shields.io/badge/DEV.TO-georgekobaidze-0A0A0A?logo=devdotto)](https://dev.to/georgekobaidze)
  [![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord)](https://discord.gg/sjUuC8McVn)
</div>
