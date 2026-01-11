#!/usr/bin/env python3
"""
Environment Bootstrap CLI

Usage:
    env-bootstrap           # Run full bootstrap
    env-bootstrap phase1    # Run only Phase 1 (base tools)
    env-bootstrap phase2    # Run only Phase 2 (private config)
"""
import subprocess
import sys
import os
from pathlib import Path


def run(cmd: str, check: bool = True) -> int:
    """Run a shell command."""
    result = subprocess.run(cmd, shell=True)
    if check and result.returncode != 0:
        print(f"ERROR: Command failed: {cmd}")
        sys.exit(result.returncode)
    return result.returncode


def check_command(cmd: str) -> bool:
    """Check if a command exists."""
    return subprocess.run(f"command -v {cmd}", shell=True, capture_output=True).returncode == 0


def phase1():
    """Install base tools and authenticate."""
    print("=" * 50)
    print("  Environment Bootstrap - Phase 1")
    print("=" * 50)
    print()

    # Check OS
    if not Path("/etc/os-release").exists():
        print("ERROR: Cannot detect OS")
        sys.exit(1)

    print("[1/6] Installing base packages...")
    run("sudo apt-get update -qq && sudo apt-get install -y -qq git curl wget build-essential age")

    print("[2/6] Installing GitHub CLI...")
    if not check_command("gh"):
        run("""
            (type -p wget >/dev/null || sudo apt-get install wget -y) && \
            sudo mkdir -p -m 755 /etc/apt/keyrings && \
            wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
            sudo apt update -qq && sudo apt install gh -y -qq
        """)
    else:
        print("      GitHub CLI already installed")

    print("[3/6] Installing uv (Python package manager)...")
    if not check_command("uv") and not Path.home().joinpath(".local/bin/uv").exists():
        run("curl -LsSf https://astral.sh/uv/install.sh | sh")
    else:
        print("      uv already installed")

    print("[4/6] Installing Node.js (if missing)...")
    if not check_command("node"):
        run("curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs")
    else:
        print(f"      Node.js already installed")

    print("[5/6] Installing Claude Code...")
    if not check_command("claude"):
        run("npm install -g @anthropic-ai/claude-code")
    else:
        print("      Claude Code already installed")

    print("[6/6] GitHub Authentication...")
    if run("gh auth status", check=False) != 0:
        print()
        print("You need to authenticate with GitHub.")
        print("Run: gh auth login")
        print()
        return False

    print("      Already authenticated")
    return True


def phase2():
    """Clone private repo and run bootstrap."""
    print()
    print("=" * 50)
    print("  Environment Bootstrap - Phase 2")
    print("=" * 50)
    print()

    age_key = Path.home() / ".age" / "key.txt"
    if not age_key.exists():
        print("ERROR: Age key not found at ~/.age/key.txt")
        print()
        print("Restore your age key from LastPass:")
        print("  mkdir -p ~/.age")
        print("  nano ~/.age/key.txt  # paste key from LastPass 'age-bootstrap-key'")
        print("  chmod 600 ~/.age/key.txt")
        return False

    bootstrap_dir = Path.home() / "env-bootstrap"
    if not bootstrap_dir.exists():
        print("[1/2] Cloning private configuration...")
        run("gh repo clone leonbreukelman/env-bootstrap-secure ~/env-bootstrap")
    else:
        print("[1/2] Private config already cloned, pulling latest...")
        run("cd ~/env-bootstrap && git pull")

    print("[2/2] Running private bootstrap...")
    run("cd ~/env-bootstrap && ./bootstrap.sh")
    return True


def main():
    """Main entry point."""
    args = sys.argv[1:]

    if not args or args[0] == "full":
        if phase1():
            phase2()
    elif args[0] == "phase1":
        phase1()
    elif args[0] == "phase2":
        phase2()
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
