# Provider Vault AI Service (Phase 2A)

Python AI service for medical provider intelligence using OpenAI API.

## Features

**5 AI Functions:**
1. **Generate Specialty Descriptions** - Patient-friendly explanations of medical specialties
2. **Suggest Related Specialties** - Referral network recommendations
3. **Analyze Provider Distribution** - Pattern analysis and gap identification
4. **Recommend by Symptoms** - Medical triage with urgency assessment
5. **Semantic Search** - Natural language provider search

## Quick Start

### Setup
```bash
# Activate virtual environment
source .venv/bin/activate

# Install dependencies (if needed)
uv pip install openai psycopg2-binary python-dotenv pytest pytest-cov fastapi uvicorn
```

### Configuration
Create `.env` file:
```bash
DATABASE_URL=postgresql://postgres@localhost:5432/provider_vault_cli_repo
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o-mini
```

## Usage

### REST API (Phase 2B)
Start the FastAPI server:
```bash
uvicorn api:app --reload --port 8000
```

**Interactive API Documentation:**
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

**API Endpoints:**
```bash
# Health check
GET http://localhost:8000/health

# Specialty description
POST http://localhost:8000/api/specialty/describe
{"specialty": "Cardiology"}

# Related specialties
POST http://localhost:8000/api/specialty/related
{"specialty": "Cardiology", "count": 3}

# Provider analysis
POST http://localhost:8000/api/providers/analyze
{"specialty": "Cardiology", "limit": 20}

# Symptom recommendations
POST http://localhost:8000/api/symptoms/recommend
{"symptoms": "chest pain, shortness of breath", "location_state": "TX"}

# Semantic search
POST http://localhost:8000/api/search
{"query": "doctor for memory problems", "limit": 10}

# List specialties
GET http://localhost:8000/api/specialties

# Database stats
GET http://localhost:8000/api/stats
```

### Interactive Demo
```bash
python interactive_demo.py -i
```

**Available Commands:**
- `describe <specialty>` - Generate specialty description
- `related <specialty>` - Find related specialties  
- `analyze <specialty>` - Analyze provider distribution
- `symptoms <description>` - Get provider recommendations based on symptoms
- `search <query>` - Natural language provider search
- `list` - Show all available specialties
- `stats` - Show database statistics
- `quit` - Exit

### Testing
```bash
pytest -v                 # All tests
pytest -m unit            # Fast unit tests (mocked)
pytest -m integration     # Integration tests (real API)
pytest --cov              # With coverage report
```

### Direct Demo
```bash
python ai_engine.py       # Demo all 5 functions
python db_client.py       # Test database connection
```

## Project Structure
```
provider_vault_ai/
├── ai_engine.py              # Core AI functions
├── db_client.py              # Database client
├── api.py                    # FastAPI HTTP wrapper (Phase 2B)
├── interactive_demo.py       # CLI interface
├── pytest.ini                # Test configuration
├── README.md                 # This file
├── .env                      # Configuration (not in git)
├── .gitignore               # Git ignore rules
└── tests/
    ├── test_ai_engine.py     # AI function tests
    └── test_db_client.py     # Database tests
```

## Testing Strategy

### Unit Tests (Fast, Mocked)
- Test structure and parsing logic
- No real API calls
- Run frequently during development

### Integration Tests (Slow, Real API)
- Validate actual AI behavior
- Test with real OpenAI API
- Run before commits

### Testing Non-Deterministic AI
We use 5 strategies:
1. **Structure Testing** - Validate response format
2. **Semantic Testing** - Check for relevant keywords
3. **Business Logic** - Test urgency levels, specialty matching
4. **Mocking** - Test parsing without API calls
5. **Consistency** - Validate expected patterns

## Database

Reads from PostgreSQL database with provider data:
- 60 providers across 16 specialties in 15 states
- Read-only access (Elixir CLI manages data)

## API Integration

The FastAPI service is ready for Phoenix web integration:
- RESTful endpoints with OpenAPI documentation
- Pydantic models for request/response validation
- Health checks and database connectivity monitoring
- CORS support (configure as needed)

**Example Phoenix Integration:**
```elixir
# Phoenix controller calling Python AI service
def show_provider(conn, %{"npi" => npi}) do
  provider = Repo.get_by(Provider, npi: npi)
  
  {:ok, %{body: body}} = HTTPoison.post(
    "http://localhost:8000/api/specialty/describe",
    Jason.encode!(%{specialty: provider.specialty}),
    [{"Content-Type", "application/json"}]
  )
  
  ai_data = Jason.decode!(body)
  render(conn, "show.html", provider: provider, description: ai_data["description"])
end
```

## Development Status

- ✅ **Phase 2A:** Complete - Core AI functions with testing
- ✅ **Phase 2B:** Complete - FastAPI HTTP wrapper
- 📋 **Phase 3:** Planned - Phoenix web integration and monorepo

## License

Educational project - Provider Vault
