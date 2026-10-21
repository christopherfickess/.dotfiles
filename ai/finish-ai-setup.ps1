# Complete AI skills/agents setup.
# Run:
#   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.dotfiles\ai\finish-ai-setup.ps1"
#
# Does:
#   1. Migrate ~/.cursor/skills/mattermost -> ~/.dotfiles/ai/skills/mattermost (if still a real dir)
#   2. Junction ~/.cursor/skills/mattermost -> ~/.dotfiles/ai/skills/mattermost
#   3. Seed ~/.dotfiles/ai/agents from ~/.dotfiles/ai/opencode/agent (if no *.md yet)

$ErrorActionPreference = "Stop"

$dotfilesAi = Join-Path $env:USERPROFILE ".dotfiles\ai"
$skillsSrc = Join-Path $dotfilesAi "skills"
$mattermostSrc = Join-Path $skillsSrc "mattermost"
$cursorSkills = Join-Path $env:USERPROFILE ".cursor\skills"
$mattermostDest = Join-Path $cursorSkills "mattermost"
$agentsSrc = Join-Path $dotfilesAi "agents"
$opencodeAgent = Join-Path $dotfilesAi "opencode\agent"

function Test-ReparsePoint([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force
    return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

Write-Host "=== 1) Seed agents from opencode ==="
New-Item -ItemType Directory -Force -Path $agentsSrc | Out-Null
$existingAgents = @(Get-ChildItem -LiteralPath $agentsSrc -Filter "*.md" -ErrorAction SilentlyContinue)
if ($existingAgents.Count -eq 0) {
    if (Test-Path -LiteralPath $opencodeAgent) {
        Copy-Item -Path (Join-Path $opencodeAgent "*") -Destination $agentsSrc -Recurse -Force
        Write-Host "Seeded agents from opencode/agent"
    } else {
        Write-Warning "No opencode/agent source found"
    }
} else {
    Write-Host "Agents already present ($($existingAgents.Count) md files) - skip seed"
}

Write-Host "=== 2) Migrate mattermost skill into dotfiles ==="
New-Item -ItemType Directory -Force -Path $skillsSrc | Out-Null

if ((Test-Path -LiteralPath $mattermostDest) -and -not (Test-ReparsePoint $mattermostDest)) {
    New-Item -ItemType Directory -Force -Path $mattermostSrc | Out-Null
    Write-Host "Copying $mattermostDest -> $mattermostSrc"
    Copy-Item -Path (Join-Path $mattermostDest "*") -Destination $mattermostSrc -Recurse -Force
} elseif (-not (Test-Path -LiteralPath $mattermostSrc)) {
    Write-Error "Neither a real cursor skill nor dotfiles skill exists for mattermost"
} else {
    Write-Host "Dotfiles skill already present: $mattermostSrc"
}

if (-not (Test-Path -LiteralPath (Join-Path $mattermostSrc "SKILL.md"))) {
    Write-Error "Missing SKILL.md under $mattermostSrc"
}

Write-Host "=== 3) Junction cursor skills/mattermost -> dotfiles ==="
New-Item -ItemType Directory -Force -Path $cursorSkills | Out-Null

if (Test-Path -LiteralPath $mattermostDest) {
    if (Test-ReparsePoint $mattermostDest) {
        Write-Host "Already a reparse point: $mattermostDest"
    } else {
        $bak = "$mattermostDest.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Write-Host "Backing up real directory -> $bak"
        Move-Item -LiteralPath $mattermostDest -Destination $bak
        Write-Host "Creating junction: $mattermostDest -> $mattermostSrc"
        New-Item -ItemType Junction -Path $mattermostDest -Target $mattermostSrc | Out-Null
    }
} else {
    Write-Host "Creating junction: $mattermostDest -> $mattermostSrc"
    New-Item -ItemType Junction -Path $mattermostDest -Target $mattermostSrc | Out-Null
}

Write-Host "=== VERIFY ==="
Write-Host "DOTFILES SKILLS:"
Get-ChildItem -LiteralPath $skillsSrc | Format-Table Name, Mode, LastWriteTime
Get-ChildItem -LiteralPath $mattermostSrc | Select-Object -First 25 | Format-Table Name, Mode, Length
Write-Host "CURSOR SKILLS:"
Get-ChildItem -LiteralPath $cursorSkills | Format-Table Name, Mode, LastWriteTime
cmd /c "dir `"$cursorSkills`""
Write-Host "AGENTS:"
Get-ChildItem -LiteralPath $agentsSrc | Select-Object -First 20 | Format-Table Name, Mode, Length
Write-Host "SKILL.md check:"
if (Test-Path (Join-Path $mattermostSrc "SKILL.md")) { "dotfiles: OK" } else { "dotfiles: MISSING" }
if (Test-Path (Join-Path $mattermostDest "SKILL.md")) { "cursor: OK" } else { "cursor: MISSING" }
Write-Host "Reparse point query:"
cmd /c "fsutil reparsepoint query `"$mattermostDest`"" 2>&1 | Select-Object -First 20
Write-Host "DONE."
