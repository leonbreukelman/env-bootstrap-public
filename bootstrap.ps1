#Requires -Version 5.1
<#
.SYNOPSIS
    Windows Bootstrap - Get Claude Code running ASAP

.DESCRIPTION
    Minimal bootstrap to get Claude Code installed.
    Once Claude is running, delegate Phase 2 to Claude.

.EXAMPLE
    irm https://raw.githubusercontent.com/leonbreukelman/env-bootstrap-public/main/bootstrap.ps1 | iex
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Test-Cmd { param([string]$c) $null -ne (Get-Command $c -ErrorAction SilentlyContinue) }

Write-Host "`n=== Windows Bootstrap - Phase 1 ===" -ForegroundColor Cyan
Write-Host "Goal: Get Claude Code running, then delegate to Claude`n" -ForegroundColor Gray

# 1. Verify winget
if (-not (Test-Cmd "winget")) {
    throw "winget required. Install 'App Installer' from Microsoft Store."
}
Write-Host "[OK] winget" -ForegroundColor Green

# 2. Git (needed for gh)
if (-not (Test-Cmd "git")) {
    Write-Host "[..] Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}
Write-Host "[OK] git" -ForegroundColor Green

# 3. GitHub CLI (needed for private repo)
if (-not (Test-Cmd "gh")) {
    Write-Host "[..] Installing GitHub CLI..." -ForegroundColor Yellow
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}
Write-Host "[OK] gh" -ForegroundColor Green

# 4. Node.js (needed for Claude)
if (-not (Test-Cmd "node")) {
    Write-Host "[..] Installing Node.js..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}
Write-Host "[OK] node" -ForegroundColor Green

# 5. Claude Code
if (-not (Test-Cmd "claude")) {
    Write-Host "[..] Installing Claude Code..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
    Refresh-Path
}
Write-Host "[OK] claude" -ForegroundColor Green

# 6. GitHub auth
Write-Host "`nChecking GitHub auth..." -ForegroundColor Cyan
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please authenticate with GitHub:" -ForegroundColor Yellow
    gh auth login
}
Write-Host "[OK] GitHub authenticated" -ForegroundColor Green

# Done - hand off to Claude
Write-Host "`n=== Phase 1 Complete ===" -ForegroundColor Green
Write-Host @"

Claude Code is ready. Now run:

  claude

Then tell Claude:

  "Run phase 2 from env-bootstrap-secure - restore my Windows dev environment"

Claude will:
  - Clone the private repo
  - Install remaining tools (age, pyenv-win, aws, kubectl, etc.)
  - Restore your configs (after you provide the age key)

"@ -ForegroundColor Cyan
