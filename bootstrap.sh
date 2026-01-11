#!/bin/bash
# Public Environment Bootstrap - Phase 1
# Run with: curl -fsSL https://raw.githubusercontent.com/leonbreukelman/env-bootstrap-public/main/bootstrap.sh | bash
set -e

echo "========================================"
echo "  Environment Bootstrap - Phase 1"
echo "========================================"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "ERROR: Cannot detect OS"
    exit 1
fi

echo "[1/6] Installing base packages..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq git curl wget build-essential age
else
    echo "WARNING: Unsupported OS ($OS). You may need to install packages manually."
fi

echo "[2/6] Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        (type -p wget >/dev/null || sudo apt-get install wget -y) && \
        sudo mkdir -p -m 755 /etc/apt/keyrings && \
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
        sudo apt update -qq && sudo apt install gh -y -qq
    fi
else
    echo "      GitHub CLI already installed"
fi

echo "[3/6] Installing uv (Python package manager)..."
if ! command -v uv &> /dev/null && [ ! -f "$HOME/.local/bin/uv" ]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "      uv already installed"
fi

# Ensure PATH includes local bin
export PATH="$HOME/.local/bin:$PATH"

echo "[4/6] Installing Node.js (if missing)..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "      Node.js already installed: $(node --version)"
fi

echo "[5/6] Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
else
    echo "      Claude Code already installed"
fi

echo "[6/6] GitHub Authentication..."
if ! gh auth status &> /dev/null; then
    echo ""
    echo "You need to authenticate with GitHub."
    echo "Run: gh auth login"
    echo ""
    echo "After authenticating, continue with Phase 2:"
    echo "  1. Restore your age key from LastPass to ~/.age/key.txt"
    echo "  2. Clone your private config:"
    echo "     gh repo clone leonbreukelman/env-bootstrap-secure ~/env-bootstrap"
    echo "  3. Run: ~/env-bootstrap/bootstrap.sh"
else
    echo "      Already authenticated as: $(gh api user --jq '.login')"
    echo ""
    echo "========================================"
    echo "  Phase 1 Complete!"
    echo "========================================"
    echo ""
    echo "Next steps (Phase 2):"
    echo ""
    echo "1. Restore your age key from LastPass:"
    echo "   mkdir -p ~/.age"
    echo "   nano ~/.age/key.txt  # paste key from LastPass"
    echo "   chmod 600 ~/.age/key.txt"
    echo ""
    echo "2. Clone and run private bootstrap:"
    echo "   gh repo clone leonbreukelman/env-bootstrap-secure ~/env-bootstrap"
    echo "   cd ~/env-bootstrap && ./bootstrap.sh"
fi
