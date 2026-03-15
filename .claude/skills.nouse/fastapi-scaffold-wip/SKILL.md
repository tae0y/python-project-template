---
name: fastapi-scaffold
description: Scaffold a new FastAPI project with standard structure, Pydantic models, dependency injection, and optional MCP/OAuth integration. Use when starting a new FastAPI service or adding a new API module to an existing project.
---

# FastAPI Scaffold

You are a FastAPI expert applying Python coding conventions and MCP server patterns. Your goal is to scaffold a production-ready FastAPI project structure that the user can extend immediately.

## Your Expertise

- **FastAPI**: Routing, dependency injection, lifespan, middleware, exception handlers
- **Pydantic v2**: Settings management, request/response models, validators
- **Python conventions**: PEP 8, type hints everywhere, PEP 257 docstrings, `uv` as package manager
- **MCP integration**: Mounting FastMCP as ASGI sub-application onto FastAPI
- **Auth**: OAuth2 Bearer token pattern with FastAPI `Security` / `Depends`
- **Async**: `async def` for all I/O-bound handlers, `httpx.AsyncClient` for outbound calls
- **Testing**: `pytest` + `httpx.AsyncClient` + `pytest-asyncio` for integration tests

---

## Step 0: Design Document First (MANDATORY)

**Before writing any code**, create `localdocs/plan.fastapi-<name>.md` with the following template. Do not proceed to Step 1 until this exists and the user has approved it.

```markdown
# Plan: FastAPI — <service name>

## Purpose
[One sentence: what does this service do?]

## Stage
[ ] SPIKE  [ ] MVP  [ ] PRODUCTION

## Endpoints (draft)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET    | /health | None | Health check |
| ...    | ...     | ...  | ...          |

## Data Models
- Request: ...
- Response: ...

## External Dependencies
- ...

## Open Questions
- [ ] ...
```

Ask the user to fill in or confirm each section before continuing.

---

## Step 1: Project Structure

Generate this layout (adjust if adding to an existing repo):

```
<project>/
├── src/
│   └── <package>/
│       ├── __init__.py
│       ├── main.py          # FastAPI app factory + lifespan
│       ├── config.py        # Pydantic BaseSettings
│       ├── dependencies.py  # Shared Depends() factories
│       ├── routers/
│       │   ├── __init__.py
│       │   └── <domain>.py  # One file per domain
│       ├── models/
│       │   ├── __init__.py
│       │   └── <domain>.py  # Pydantic request/response models
│       └── services/
│           ├── __init__.py
│           └── <domain>.py  # Business logic, no HTTP concerns
├── tests/
│   ├── conftest.py
│   └── test_<domain>.py
├── pyproject.toml
└── .env.example
```

---

## Step 2: Core Files

### `config.py` — Settings (always first)

```python
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "my-service"
    debug: bool = False
    # Add domain-specific settings here


settings = Settings()
```

### `main.py` — App factory + lifespan

```python
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI

from .config import settings
from .routers import health, <domain>


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Manage startup and shutdown resources."""
    # startup: initialise DB pools, HTTP clients, etc.
    yield
    # shutdown: close connections


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title=settings.app_name,
        debug=settings.debug,
        lifespan=lifespan,
    )

    app.include_router(health.router)
    app.include_router(<domain>.router, prefix="/api/v1")

    return app


app = create_app()
```

### `dependencies.py` — Shared dependencies

```python
from typing import Annotated

from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

security = HTTPBearer(auto_error=False)


async def require_auth(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None,
        Security(security),
    ],
) -> str:
    """Validate Bearer token and return the token string.

    Raises:
        HTTPException: 401 if token is missing or invalid.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
        )
    # TODO: validate credentials.credentials against your auth provider
    return credentials.credentials
```

### `routers/health.py` — Health check (always include)

```python
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """Health check response."""

    status: str


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Return service health status."""
    return HealthResponse(status="ok")
```

### `models/<domain>.py` — Request/response models

```python
from pydantic import BaseModel, Field


class <Domain>Request(BaseModel):
    """Request body for <domain> operations."""

    field_name: str = Field(..., description="Description of the field")


class <Domain>Response(BaseModel):
    """Response schema for <domain> operations."""

    id: str
    field_name: str
```

### `routers/<domain>.py` — Domain router

```python
from typing import Annotated

from fastapi import APIRouter, Depends

from ..dependencies import require_auth
from ..models.<domain> import <Domain>Request, <Domain>Response
from ..services.<domain> import <Domain>Service

router = APIRouter(prefix="/<domain>", tags=["<domain>"])


@router.post("/", response_model=<Domain>Response)
async def create_<domain>(
    body: <Domain>Request,
    token: Annotated[str, Depends(require_auth)],
    service: Annotated[<Domain>Service, Depends()],
) -> <Domain>Response:
    """Create a new <domain> resource.

    Args:
        body: Validated request body.
        token: Authenticated Bearer token.
        service: Injected domain service.

    Returns:
        Created <domain> resource.
    """
    return await service.create(body)
```

---

## Step 3: MCP Integration (optional, ask first)

Only add if the user confirms they need MCP alongside the REST API.

```python
# main.py addition
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-service")


@mcp.tool()
async def my_tool(param: str) -> str:
    """Tool description — becomes the MCP tool description.

    Args:
        param: Description of parameter.

    Returns:
        Result description.
    """
    return f"result: {param}"


def create_app() -> FastAPI:
    app = FastAPI(title=settings.app_name, lifespan=lifespan)
    # ... routers ...
    app.mount("/mcp", mcp.streamable_http_app())
    return app
```

---

## Step 4: Tests

### `tests/conftest.py`

```python
import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

from <package>.main import app


@pytest_asyncio.fixture
async def client() -> AsyncClient:
    """Async test client for the FastAPI app."""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac
```

### `tests/test_health.py`

```python
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient) -> None:
    """Health endpoint returns 200 with status ok."""
    response = await client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
```

---

## Step 5: `pyproject.toml` (uv)

```toml
[project]
name = "<project>"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.32",
    "pydantic>=2.9",
    "pydantic-settings>=2.6",
]

[project.optional-dependencies]
mcp = ["mcp>=1.6"]
auth = ["python-jose[cryptography]>=3.3"]

[tool.uv]
dev-dependencies = [
    "pytest>=8",
    "pytest-asyncio>=0.24",
    "httpx>=0.27",
    "ruff>=0.8",
    "pyright>=1.1",
]

[tool.pytest.ini_options]
asyncio_mode = "auto"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]
```

---

## Python Convention Reminders

Apply `python-conventions` throughout:

- **Type hints on every function** — parameters and return types, no exceptions
- **Docstrings on every public function** — PEP 257 format, include `Args:` and `Returns:` sections
- **Line length ≤ 88** (ruff default; matches Black)
- **Imports**: stdlib → third-party → local, sorted by `ruff --select I`
- **No bare `except:`** — always catch specific exception types
- **No mutable default arguments** — use `None` + body assignment

---

## Checklist Before Handing Off

- [ ] `localdocs/plan.fastapi-<name>.md` created and approved
- [ ] All endpoints documented in plan before implementation
- [ ] `config.py` uses `pydantic-settings` (no raw `os.environ`)
- [ ] Every handler has full type hints and docstring
- [ ] `GET /health` exists and returns `{"status": "ok"}`
- [ ] `tests/conftest.py` uses `ASGITransport`, not a live server
- [ ] `uv run pytest` passes before handing off
- [ ] `uv run ruff check .` passes
- [ ] MCP integration only if explicitly requested

---

## Anti-Patterns to Avoid

- ❌ Implementing endpoints before the plan doc exists
- ❌ Putting business logic inside router handlers (use services layer)
- ❌ Using `os.environ` directly instead of `Settings`
- ❌ `async def` on CPU-bound handlers (use `def` + `run_in_executor`)
- ❌ Skipping type hints "for speed" — they drive Pydantic schema generation
- ❌ Adding MCP without confirming the user needs it
