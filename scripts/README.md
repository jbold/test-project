# Legal AI Toolkit - Development Scripts

This directory contains development scripts that make it easy to work with both the web portal and desktop application in a unified devcontainer environment.

## Quick Start

```bash
# Interactive development menu
./scripts/dev-quick.sh
```

## Available Scripts

### 🚀 dev-quick.sh
**Interactive development menu** - Best for new developers or quick switching between modes.

Features:
- Menu-driven interface
- Real-time status checking
- One-click start/stop for any combination
- Built-in cleanup and management

Usage:
```bash
./scripts/dev-quick.sh
```

### 🖥️ dev-desktop.sh
**Desktop application only** - Pure Tauri + Svelte development.

What it starts:
- Tauri development server (Rust + Svelte)
- Hot reload for frontend changes
- Rust compilation on save
- Desktop application window

Usage:
```bash
./scripts/dev-desktop.sh
```

Ports:
- `5173` - Svelte dev server
- `1420` - Tauri dev tools

### 🌐 dev-web.sh
**Web portal only** - FastAPI backend + Svelte frontend for registration/billing.

What it starts:
- FastAPI backend with hot reload
- Svelte frontend for web portal
- Python virtual environment management
- Database connection (if services running)

Usage:
```bash
./scripts/dev-web.sh
```

Ports:
- `8000` - FastAPI backend
- `3001` - Svelte web frontend

### 🚀 dev-all.sh
**Full environment** - Everything running simultaneously for integration testing.

What it starts:
- All Docker backing services
- Web portal (backend + frontend)
- Desktop application
- AI services (IPFS, Vector DB)

Usage:
```bash
./scripts/dev-all.sh
```

Perfect for:
- Integration testing
- End-to-end development
- Demo preparation
- Full feature development

### 🐳 dev-services.sh
**Backing services management** - Docker services without development servers.

What it manages:
- PostgreSQL database
- Redis cache
- IPFS storage
- Vector database (Qdrant)
- MinIO object storage

Usage:
```bash
./scripts/dev-services.sh [command]
```

Commands:
- `start` - Start all services (default)
- `stop` - Stop all services
- `status` - Show current status
- `logs` - Show all logs
- `logs [service]` - Show specific service logs
- `restart` - Restart all services
- `cleanup` - Complete cleanup (removes data)

## Development Workflow Examples

### Frontend-Only Development
```bash
# Start just the desktop app for UI work
./scripts/dev-desktop.sh
```

### Backend Integration Testing
```bash
# Start services first
./scripts/dev-services.sh start

# Then start web portal
./scripts/dev-web.sh
```

### Full-Stack Development
```bash
# Everything at once
./scripts/dev-all.sh
```

### Quick Switching
```bash
# Interactive menu for easy switching
./scripts/dev-quick.sh
```

## Service Ports Reference

| Service | Port | Description |
|---------|------|-------------|
| Desktop App | 5173 | Svelte dev server |
| Desktop App | 1420 | Tauri dev tools |
| Web Backend | 8000 | FastAPI API |
| Web Frontend | 3001 | Svelte web portal |
| PostgreSQL | 5432 | User database |
| Redis | 6379 | Cache and sessions |
| IPFS API | 5001 | IPFS node API |
| IPFS Gateway | 8080 | IPFS content access |
| Vector DB | 6333 | Qdrant API |
| MinIO | 9000 | S3-compatible storage |
| MinIO Console | 9001 | MinIO web interface |

## Environment Variables

The scripts automatically set appropriate environment variables:

### Desktop Development
- `RUST_LOG=debug`
- `TAURI_DEBUG=true`
- `NODE_ENV=development`

### Web Development
- `PYTHON_ENV=development`
- `NODE_ENV=development`
- `DATABASE_URL=postgresql://...`
- `JWT_SECRET_KEY=development-secret-key`

### Service Configuration
- All services configured for development
- No persistence between container restarts (unless specified)
- Development-optimized settings

## Troubleshooting

### Scripts Not Executable
```bash
chmod +x scripts/*.sh
```

### Port Conflicts
- Stop conflicting services: `./scripts/dev-services.sh stop`
- Check what's using ports: `lsof -i :8000`

### Service Dependencies
- Always start services before web development
- Desktop app can run independently
- Check service status: `./scripts/dev-services.sh status`

### Docker Issues
```bash
# Cleanup everything
./scripts/dev-services.sh cleanup

# Restart Docker daemon
sudo systemctl restart docker
```

## Ultra-Rapid Development Tips

1. **Use dev-quick.sh** for menu-driven development
2. **Start services first** for any web portal development
3. **Desktop-only mode** for pure UI development
4. **Full environment** for integration testing
5. **Status checking** to see what's currently running

The scripts are designed to eliminate context switching and maximize development velocity in the superintelligent development workflow.