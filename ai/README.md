# AI agents & skills (tool-agnostic)

Source of truth for shared agent config across machines and tools.

```text
~/.dotfiles/ai/
├── README.md          ← this file
├── setup.sh           ← install / link into live tool paths
├── skills/            ← Agent Skills (Cursor, Claude Code, …)
│   └── mattermost/
├── agents/            ← shared agent personas (tool-agnostic markdown)
└── opencode/          ← OpenCode-specific config (already existed)
```

## Concepts

| Path | What lives here | Consumed by |
|------|-----------------|-------------|
| `skills/` | Portable Agent Skills (`SKILL.md` + refs) | Cursor (`~/.cursor/skills`), Claude Code (`~/.claude/skills`) if present |
| `agents/` | Shared personas / role prompts | Symlinked or copied into tool-specific agent dirs |
| `opencode/` | OpenCode `opencode.jsonc`, instructions, agents | `~/.config/opencode` |

Skills are **not** Cursor-only. They are markdown playbooks. Cursor just happens to load them from `~/.cursor/skills/<name>/SKILL.md`. Same files can feed Claude Code or be referenced by OpenCode instructions.

## Per-machine install

After cloning/pulling `~/.dotfiles`:

```bash
sre_tools -A
# or:
source ~/.dotfiles/ai/setup.sh && setup_ai_tools
```

That:

1. Migrates any existing `~/.cursor/skills/*` into `~/.dotfiles/ai/skills/` (once)
2. Symlinks/junctions each managed skill back into Cursor (and Claude Code if `~/.claude` exists)
3. Optionally links OpenCode config from `ai/opencode` → `~/.config/opencode`

## Multi-PC workflow

1. Edit skills in `~/.dotfiles/ai/skills/...` on any machine
2. `git commit && git push` from `~/.dotfiles`
3. On the other PC: `git pull` then `sre_tools -A` (or just pull if links already point at the repo)

Do **not** edit skills only under `~/.cursor/skills` after linking — that directory should be a link into the repo.

## Windows notes

Directory junctions (`mklink /J`) are used when available so no admin/Developer Mode is required. On macOS/Linux, `ln -sfn` is used.
