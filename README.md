# env-bootstrap-public

AI-first environment bootstrapping for fresh WSL/Ubuntu installations.

## Quick Start

### Option 1: curl | bash (Fastest)

```bash
curl -fsSL https://raw.githubusercontent.com/leonbreukelman/env-bootstrap-public/main/bootstrap.sh | bash
```

### Option 2: uv tool install

```bash
# Requires uv to be installed first
uv tool install env-bootstrap --from git+https://github.com/leonbreukelman/env-bootstrap-public.git

# Then run
env-bootstrap
```

### Option 3: Manual

```bash
git clone https://github.com/leonbreukelman/env-bootstrap-public.git
cd env-bootstrap-public
bash bootstrap.sh
```

## What This Does

### Phase 1 (Public Bootstrap)

Installs:
- git, curl, wget, build-essential, unzip
- age (encryption)
- GitHub CLI (gh)
- uv (Python package manager)
- Node.js
- Claude Code
- AWS CLI v2
- kubectl (Kubernetes CLI)
- AWS CDK

Then guides you to:
1. Authenticate with GitHub (`gh auth login`)
2. Restore your age key from password manager
3. Run Phase 2

### Phase 2 (Private Config)

After Phase 1, you run your private bootstrap which:
- Decrypts and restores API keys to `~/.secrets`
- Decrypts and restores SSH private keys
- Restores AWS SSO configuration (`~/.aws/config`)
- Restores dotfiles (.gitconfig, .bashrc)

## Architecture

```
┌─────────────────────────────────────────────────┐
│           PUBLIC REPO (this one)                │
│  - Base tool installation                       │
│  - No secrets, safe to share                    │
└─────────────────────┬───────────────────────────┘
                      │
                      │ gh auth login
                      │ + age key from LastPass
                      ▼
┌─────────────────────────────────────────────────┐
│           PRIVATE REPO                          │
│  - Encrypted secrets (age)                      │
│  - SSH keys (encrypted)                         │
│  - AWS SSO configuration                        │
│  - Personal dotfiles                            │
└─────────────────────────────────────────────────┘
```

## Recovery Procedure

On a fresh machine:

1. **Have Python?** Use `uv tool install` method
2. **No Python?** Use `curl | bash` method
3. **No internet?** Copy bootstrap.sh to USB drive

Key requirement: You need your **age key** from LastPass to decrypt secrets.

## Customization

Fork this repo and edit:
- `bootstrap.sh` - Shell script version
- `src/env_bootstrap/cli.py` - Python CLI version

Change `leonbreukelman` to your username for the private repo reference.

## License

MIT
