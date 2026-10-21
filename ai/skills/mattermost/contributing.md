# Contributing to the Mattermost Monorepo

Repo: [`mattermost/mattermost`](https://github.com/mattermost/mattermost)

As of 2023, server, webapp, and related packages live in one monorepo. Older docs that reference `mattermost-server` or `mattermost-webapp` as separate repos are outdated.

## Layout (high level)

```
mattermost/
├── server/                 # Go server
│   ├── channels/           # Core channel/post/user app logic
│   ├── public/             # Public Go API (plugin.Hooks, model.*, etc.)
│   ├── cmd/                # mattermost + mmctl binaries
│   └── tests/
├── webapp/
│   ├── channels/           # Main React webapp
│   └── platform/           # Shared packages (@mattermost/client, types, etc.)
├── e2e-tests/              # Cypress + Playwright
└── api/                    # OpenAPI specs
```

## Local setup (minimum)

Prerequisites: Go (match `server/go.mod`), Node (match `.nvmrc`), Docker (Postgres + optional Elasticsearch).

```bash
# Start dependencies
cd server && docker compose up -d

# Server
make run-server          # or: make run

# Webapp (separate terminal)
cd webapp
npm i
npm run run
```

Default: `http://localhost:8065`. First visit creates the system admin.

## Conventions

### Go (server)

- Packages under `server/channels/app`, `store`, `api4` for core features
- Errors: prefer `*model.AppError` at API boundaries; wrap with context
- Logging: structured via `mlog` (`mlog.String`, `mlog.Err`, etc.) — not `fmt.Printf`
- Store layer owns SQL; don't put raw queries in `app/` handlers
- Feature flags: check existing `FeatureFlags` patterns before hardcoding toggles

### TypeScript / React (webapp)

- Functional components + hooks
- Redux Toolkit patterns already in the tree — match neighbors, don't invent a parallel store
- Prefer existing `@mattermost/client` / `@mattermost/types` over hand-rolled fetch
- CSS: prefer existing Sass modules / CSS variables already in the design system

### i18n (hard rule)

**Only edit `en.json` files.** Never write translation strings to other locale files (including `en-au.json` or similar). Translators / Crowdin own the rest.

### Tests

| Layer | Tool | Where |
|-------|------|-------|
| Server unit | `go test` | `*_test.go` next to code |
| Store / DB | `go test` with testcontainers / Docker Postgres | `server/channels/store/...` |
| Webapp unit | Jest + RTL | `webapp/channels/src/**/*.test.tsx` |
| E2E | Cypress / Playwright | `e2e-tests/` |

```bash
# Server
cd server && make test-go

# Webapp
cd webapp && npm test

# Focused
go test ./channels/app/... -run TestSomething
```

## PR workflow

1. Branch from `master` (or the target release branch if backports)
2. Keep PRs focused — one concern per PR
3. Fill out the PR template (summary, release note, test plan)
4. CI must be green: unit, lint, and relevant e2e
5. Request review from CODEOWNERS (auto-assigned)

### Commit / PR message style

Match recent history in the repo. Typical pattern:

```
[MM-12345] Short imperative summary of why

Optional body: context, risk, migration notes
```

Jira ticket in the subject when one exists. Don't invent ticket IDs.

### Backports

Security and critical fixes may need cherry-picks to ESR / release branches. Follow the team's backport process (labels + cherry-pick PRs) — don't force-push shared release branches.

## Useful make targets

```bash
make run-server          # Start server
make stop-server
make check-style         # Go lint/format
make test-go
make build-linux         # Cross-compile server binary
```

Webapp:

```bash
npm run check            # lint + types
npm run fix
npm run build
```

## Gotchas for contributors

- **Public API surface**: Anything under `server/public/` is a compatibility contract for plugins. Breaking changes need careful versioning / deprecation.
- **Migrations**: Schema changes go through numbered migrations in the store layer. Never hand-edit production schemas as "contribution."
- **Config defaults**: New settings need defaults in `config/default.json` (or equivalent), docs, and usually a System Console exposure plan.
- **Feature flags**: Prefer flags for risky rollouts; document the flag name and default.
- **Don't commit secrets**: No `.env` with real tokens, no license files that aren't meant for the repo.
- **Plugin vs core**: If the change is better as a plugin, say so — core should stay lean.

## When this file is enough vs when to dig

- Conventions, PR hygiene, i18n, test layout → stay here
- Plugin-specific APIs → [plugins.md](plugins.md)
- REST endpoint behavior → [api.md](api.md) + OpenAPI under `api/`
- Deploying a fork/self-built binary → [deploy.md](deploy.md)
