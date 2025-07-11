# Legal AI Toolkit - DevContainer Environment

This devcontainer provides a complete, reproducible development environment for the Legal AI Toolkit project.

## Features

- **Ubuntu 22.04** base with all system dependencies
- **Rust toolchain** with WebAssembly support
- **Node.js 20** with modern JavaScript tools
- **Python 3** with FastAPI and ML libraries
- **WasmEdge & LlamaEdge** for local AI inference
- **IPFS** for decentralized storage
- **Multi-service architecture** with Docker Compose

## Quick Start

1. **Prerequisites**:
   - Docker Desktop or Docker Engine
   - VS Code with Dev Containers extension

2. **Launch Environment**:
   ```bash
   # Open in VS Code
   code .
   # Command Palette: "Dev Containers: Reopen in Container"
   ```

3. **Development Commands**:
   ```bash
   ltdev      # Start Tauri development server
   ltbuild    # Build Tauri application  
   webdev     # Start web portal development
   ipfsstart  # Start IPFS daemon
   ```

## Architecture

### Development Container
- **Base**: Ubuntu 22.04 with development tools
- **Languages**: Rust, Node.js, Python, Go
- **AI Stack**: WasmEdge, LlamaEdge, WASI-NN
- **Storage**: IPFS for documents, Vector DB for embeddings

### Supporting Services
- **PostgreSQL**: User authentication and metadata
- **Redis**: Session management and caching  
- **IPFS**: Distributed document storage
- **Qdrant**: Vector database for AI embeddings
- **MinIO**: S3-compatible object storage

## Port Mapping

| Service | Port | Description |
|---------|------|-------------|
| Tauri Dev | 3000 | Desktop app development |
| Svelte Dev | 5173 | Frontend development |
| FastAPI | 8000 | Backend API |
| IPFS API | 5001 | IPFS node API |
| IPFS Gateway | 8080 | IPFS content gateway |
| Vector DB | 6333 | Qdrant vector database |
| PostgreSQL | 5432 | User database |
| Redis | 6379 | Cache and sessions |

## AI Infrastructure

The devcontainer includes:
- **WasmEdge**: High-performance WebAssembly runtime
- **LlamaEdge**: Local language model inference
- **WASI-NN**: WebAssembly System Interface for Neural Networks
- **Vector Database**: Semantic search and RAG capabilities

## Security

- Privileged container for hardware access
- Secure volume mounts for development
- Environment isolation
- No secrets in container images

## Troubleshooting

### Common Issues

1. **GTK/Display Issues**:
   ```bash
   # Already configured with display forwarding
   echo $DISPLAY
   ```

2. **Permission Issues**:
   ```bash
   sudo chown -R vscode:vscode /workspace
   ```

3. **Service Dependencies**:
   ```bash
   docker-compose up -d  # Start all services
   ```

### Performance Optimization

- **Volume Caching**: Node modules and Cargo cache are persisted
- **Build Optimization**: Rust target directory is cached
- **Memory Limits**: Configured for development workloads

## Multi-Instance Development

The environment supports parallel Claude Code instances:

1. **Instance 1**: Web Portal (FastAPI + Stripe)
2. **Instance 2**: Desktop App (Tauri + JWT) 
3. **Instance 3**: AI Agents (Multi-agent system)
4. **Instance 4**: Storage (IPFS + Vector DB)
5. **Instance 5**: Legal Research (MCP + APIs)

Each instance can work independently while sharing the same environment and services.