# System Architecture Overview

High-level service topology of the LAPAN Survey Platform.

```mermaid
flowchart LR
    subgraph Flutter Apps
        SP[survey-patient<br/>:8081]
        SF[survey-frontend<br/>:8080]
        CN[clinical-narrative<br/>:8082]
        SB[survey-builder<br/>:8083]
    end

    subgraph API Gateway
        TR[Traefik<br/>Reverse Proxy]
    end

    subgraph Python Services
        BE[survey-backend<br/>FastAPI]
        WK[survey-worker<br/>Background Processor]
        CW[clinical-writer-api<br/>LangGraph]
    end

    subgraph Data
        DB[(MongoDB)]
        CFG[config.private.json]
    end

    subgraph External
        ML[AI Providers<br/>GLM / Gemini]
        EM[Email<br/>FastMail]
    end

    SP --> TR
    SF --> TR
    CN --> TR
    SB --> TR

    TR --> BE
    BE <--> DB
    BE --> WK
    BE --> CW
    WK --> CW
    CW --> ML

    BE --> EM
    WK --> DB
    CW --> DB

    CFG -.->|render_runtime_config.py| BE
    CFG -.->|render_runtime_config.py| WK
    CFG -.->|render_runtime_config.py| CW

    style TR fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b
    style DB fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    style CFG fill:#fef3c7,stroke:#d97706,color:#78350f
    style ML fill:#fce7f3,stroke:#db2777,color:#831843
```

## UV Workspace

All Python services share a single `uv.lock` at the repository root:

```mermaid
flowchart TD
    ROOT[pyproject.toml<br/>uv workspace root]
    ROOT --> BE_PKG[survey-backend<br/>pyproject.toml]
    ROOT --> WK_PKG[survey-worker<br/>pyproject.toml]
    ROOT --> CW_PKG[clinical-writer-api<br/>pyproject.toml]
    ROOT --> LC[lapan-core<br/>packages/python/lapan-core]
```

## Shared Packages

- `lapan-core` — cross-service security utilities (`security_boundaries.py`)
- `design_system_flutter` — shared Flutter theming and widgets
- `contracts` — OpenAPI spec with generated Dart/Python SDKs
