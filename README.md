# Provider Vault

A pedagogical polyglot microservices project demonstrating AI engineering, concurrent data fetching, and modern web development using medical provider data.

## 🏗️ Architecture

This project showcases a realistic microservices architecture using multiple programming languages, each chosen for its specific strengths:
```
┌─────────────────────────────────────┐
│  Phoenix Web App (Elixir)           │  Port 4000
│  - User interface                   │
│  - Database queries                 │
│  - HTTP client to AI service        │
└──────────────┬──────────────────────┘
               │ HTTP
               ↓
┌─────────────────────────────────────┐
│  AI Service (Python/FastAPI)        │  Port 8000
│  - OpenAI API integration           │
│  - Specialty descriptions           │
│  - Related specialty suggestions    │
└─────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│  PostgreSQL Database                │  Port 5432
│  - Provider data storage            │
└─────────────────────────────────────┘
```

## 📁 Project Structure
```
provider_vault/
├── apps/
│   ├── web/              # Phoenix web application (Elixir)
│   └── ai_service/       # AI service with FastAPI (Python)
├── prototypes/
│   └── cli_v1_7/         # Original CLI prototype (Phase 1)
├── docs/                 # Documentation
└── start.sh              # Startup script
```

## 🚀 Quick Start

### Prerequisites

- Elixir 1.19+
- Erlang/OTP 28+
- Python 3.11+
- PostgreSQL 15+
- uv (Python package manager)

### Setup

1. **Clone the repository**
```bash
   git clone https://github.com/YOUR_USERNAME/provider_vault.git
   cd provider_vault
```

2. **Set up AI Service**
```bash
   cd apps/ai_service
   uv venv
   source .venv/bin/activate
   uv pip install fastapi uvicorn openai python-dotenv psycopg2-binary
   
   # Create .env file with your OpenAI API key
   echo "OPENAI_API_KEY=your_key_here" > .env
```

3. **Set up Phoenix Web App**
```bash
   cd ../web
   mix deps.get
   mix ecto.create
```

4. **Start everything**
```bash
   cd ../..
   ./start.sh
```

5. **Visit the app**
   - Web Interface: http://localhost:4000
   - AI Service API: http://localhost:8000/docs

## 🎓 Learning Objectives

### Phase 1: CLI Prototype (Elixir)
- Concurrent data fetching with Task.async_stream
- Ecto database integration
- Command-line interface design

### Phase 2: AI Service (Python)
- OpenAI API integration
- FastAPI web service
- AI prompt engineering
- Testing non-deterministic responses

### Phase 3: Web Application (Phoenix)
- Phoenix web framework
- LiveView for real-time features
- HTTP client integration
- Search and filtering
- Pagination

## 🛠️ Tech Stack

- **Elixir/Phoenix**: Web framework, concurrency
- **Python/FastAPI**: AI/ML service wrapper
- **PostgreSQL**: Data persistence
- **OpenAI API**: LLM capabilities
- **Tailwind CSS + DaisyUI**: UI styling

## 📚 Documentation

- [Phase 1: CLI Development](docs/phase1-cli.md)
- [Phase 2: AI Service](docs/phase2-ai.md)
- [Phase 3: Web Application](docs/phase3-web.md)
- [Architecture Overview](docs/architecture.md)

## 🤝 Contributing

This is a teaching project. Feel free to explore, learn, and extend!

## 📄 License

MIT License - See LICENSE file for details
