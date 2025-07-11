#!/bin/bash
set -e

echo "🚀 Legal AI Toolkit - Superintelligent Development Environment Setup"
echo "=================================================="

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install essential system dependencies
echo "🔧 Installing system dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libwebkit2gtk-4.0-dev \
    libasound2-dev \
    libxdo-dev \
    libxrandr-dev \
    libxss-dev \
    libgconf-2-4 \
    libxcomposite-dev \
    libxdamage-dev \
    libxfixes-dev \
    libnss3-dev \
    libgtk-3-dev \
    libdrm-dev \
    libxkbcommon-dev \
    libgbm-dev \
    xvfb \
    python3 \
    python3-pip \
    python3-venv \
    sqlite3 \
    jq \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    postgresql-client \
    postgresql-client-common \
    redis-tools

# Install Rust
echo "🦀 Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source /home/vscode/.cargo/env
    rustup component add rustfmt clippy
    rustup target add wasm32-unknown-unknown
fi

# Install Node.js and npm
echo "📦 Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install WASM tools
echo "🌐 Installing WebAssembly tools..."
if ! command -v wasm-pack &> /dev/null; then
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi

# Install WasmEdge
echo "⚡ Installing WasmEdge..."
if ! command -v wasmedge &> /dev/null; then
    curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --version=0.13.5
    source /home/vscode/.bashrc
fi

# Install LlamaEdge
echo "🦙 Installing LlamaEdge..."
if ! command -v llama-api-server &> /dev/null; then
    curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm
    curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-chat.wasm
    sudo mkdir -p /usr/local/bin/llamaedge
    sudo mv llama-api-server.wasm /usr/local/bin/llamaedge/
    sudo mv llama-chat.wasm /usr/local/bin/llamaedge/
    
    # Create wrapper scripts
    sudo tee /usr/local/bin/llama-api-server > /dev/null <<EOF
#!/bin/bash
wasmedge --dir .:. /usr/local/bin/llamaedge/llama-api-server.wasm "\$@"
EOF
    sudo chmod +x /usr/local/bin/llama-api-server
fi

# Install Go (for IPFS tools)
echo "🐹 Installing Go..."
if ! command -v go &> /dev/null; then
    GO_VERSION="1.21.5"
    curl -LO "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vscode/.bashrc
fi

# Install IPFS CLI
echo "🌐 Installing IPFS CLI..."
if ! command -v ipfs &> /dev/null; then
    IPFS_VERSION="v0.24.0"
    curl -LO "https://github.com/ipfs/kubo/releases/download/${IPFS_VERSION}/kubo_${IPFS_VERSION}_linux-amd64.tar.gz"
    tar -xzf "kubo_${IPFS_VERSION}_linux-amd64.tar.gz"
    sudo ./kubo/install.sh
    rm -rf kubo "kubo_${IPFS_VERSION}_linux-amd64.tar.gz"
fi

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip3 install --user \
    fastapi \
    uvicorn \
    sqlalchemy \
    psycopg2-binary \
    redis \
    stripe \
    python-jose \
    passlib \
    python-multipart \
    requests \
    aiofiles \
    pytest \
    black \
    flake8

# Install global npm packages
echo "📦 Installing global npm packages..."
sudo npm install -g \
    @tauri-apps/cli \
    @sveltejs/kit \
    typescript \
    prettier \
    eslint \
    vite

# Set up environment variables
echo "🔧 Setting up environment..."
cat >> /home/vscode/.bashrc << 'EOF'

# Legal AI Toolkit Environment
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export RUST_LOG=debug
export TAURI_DEBUG=true
export NODE_ENV=development
export PYTHON_ENV=development

# WasmEdge
export PATH="$HOME/.wasmedge/bin:$PATH"

# Legal Toolkit Aliases
alias ltdev="cd /workspace && cargo tauri dev"
alias ltbuild="cd /workspace && cargo tauri build"
alias webdev="cd /workspace/web-portal && ./start.sh"
alias ipfsstart="ipfs daemon &"
alias vectorstart="docker-compose up vector-db -d"

echo "🚀 Legal AI Toolkit Development Environment Ready!"
echo "📂 Workspace: /workspace"
echo "⚡ Quick commands: ltdev, ltbuild, webdev"
EOF

# Install project dependencies
echo "📦 Installing project dependencies..."
cd /workspace

# Install Rust dependencies
if [ -f "Cargo.toml" ]; then
    echo "Installing Rust dependencies..."
    cargo fetch
fi

# Install Node.js dependencies
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
fi

# Install web portal dependencies
if [ -f "web-portal/backend/requirements.txt" ]; then
    echo "Installing Python dependencies..."
    cd web-portal/backend
    pip3 install --user -r requirements.txt
    cd ../..
fi

if [ -f "web-portal/frontend/package.json" ]; then
    echo "Installing web portal frontend dependencies..."
    cd web-portal/frontend
    npm install
    cd ../..
fi

# Set proper permissions
sudo chown -R vscode:vscode /workspace
sudo chown -R vscode:vscode /home/vscode/.cargo
sudo chown -R vscode:vscode /home/vscode/.cache

echo "✅ Post-create setup completed successfully!"
echo "🎯 Ready for superintelligent development!"