# opencode AI Configuration

This directory mirrors the global opencode setup from `~/.config/opencode`.

## Live Config

The active opencode config lives at:

```text
~/.config/opencode/opencode.jsonc
```

This dotfiles copy lives at:

```text
~/.dotfiles/ai/opencode/opencode.jsonc
```

The dotfiles copy is a mirror. It does not control opencode unless you copy it into `~/.config/opencode` or replace the live files with symlinks.

## Global Instructions

The current config loads these instruction files for every agent and model:

```jsonc
"instructions": [
  "instructions/style.md",
  "instructions/coding-standards.md",
  "instructions/infra-security.md"
]
```

That means `/default`, `/infra`, `/reviewer`, and `/planner` all receive these files.

Instruction files:

- `instructions/style.md`: response style, tone, challenge format, follow-up format, and writing rules.
- `instructions/coding-standards.md`: coding behavior for Bash, Python, Terraform, Helm, Ansible, and general engineering.
- `instructions/infra-security.md`: version verification, Mattermost deployment rules, Helm chart selection, CVE awareness, and security-sensitive environment checks.

## Agents

Agents live in:

```text
~/.config/opencode/agent/*.md
```

The dotfiles mirror lives in:

```text
~/.dotfiles/ai/opencode/agent/*.md
```

Configured agents:

- `default`: normal coding, debugging, documentation, explanations, and day-to-day technical work.
- `infra`: Terraform, Helm, Kubernetes, Docker, CI/CD, Mattermost deployment, RBAC, TLS, secrets, image tags, and other security-sensitive infrastructure work.
- `reviewer`: review-only mode. Edits are denied. Findings come first, ordered by severity.
- `planner`: planning-only mode. Edits are denied. It researches first, writes a plan, and asks for approval before implementation.

The default agent is:

```jsonc
"default_agent": "default"
```

## Model Behavior

The agent files currently do not pin a `model` field.

That means each agent uses the current opencode model selection. If the selected model is OpenAI, `/default`, `/infra`, `/reviewer`, and `/planner` all use OpenAI. If the selected model is Claude, they all use Claude.

To pin a model for one agent, add `model:` to that agent's frontmatter:

```yaml
---
description: Researches codebases and writes implementation plans before code changes.
mode: primary
model: openai/gpt-5.1
permission:
  edit: deny
---
```

To create provider-specific variants, add separate files such as:

```text
agent/planner-openai.md
agent/planner-claude.md
agent/reviewer-openai.md
agent/reviewer-claude.md
```

## What Each Agent Receives

Current behavior:

```text
/default
  receives style.md
  receives coding-standards.md
  receives infra-security.md
  receives agent/default.md

/infra
  receives style.md
  receives coding-standards.md
  receives infra-security.md
  receives agent/infra.md

/reviewer
  receives style.md
  receives coding-standards.md
  receives infra-security.md
  receives agent/reviewer.md
  edit is denied

/planner
  receives style.md
  receives coding-standards.md
  receives infra-security.md
  receives agent/planner.md
  edit is denied
```

## Important Caveat

`infra-security.md` currently loads globally. That keeps security rules visible everywhere, but it can make non-infra agents more cautious than necessary.

If that gets noisy, remove `instructions/infra-security.md` from global `instructions` and keep the security behavior in `agent/infra.md` instead.

## Applying Changes

opencode loads config at startup. After editing any config, instruction, or agent file, quit and restart opencode.

## Suggested Source Of Truth

Use one of these approaches:

- Manual mirror: edit `~/.config/opencode`, then copy changes into this dotfiles directory.
- Dotfiles source of truth: edit `~/.dotfiles/ai/opencode`, then copy or symlink files into `~/.config/opencode`.

Symlinking avoids drift, but only do it after confirming the dotfiles layout is the version you want to keep.
