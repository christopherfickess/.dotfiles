# Shared agent personas

Tool-agnostic agent prompts. Seeded from `../opencode/agent/` on first `setup_ai_tools` run.

Edit these files; OpenCode (and later other tools) should link here via `sre_tools -A`.

| File | Role |
|------|------|
| `default.md` | Day-to-day coding / debugging |
| `infra.md` | Terraform, Helm, K8s, Mattermost deploy |
| `reviewer.md` | Review-only |
| `planner.md` | Plan-only |

Cursor Agent Skills (playbooks with `SKILL.md`) live in `../skills/`, not here.
