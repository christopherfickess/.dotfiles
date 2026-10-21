---
name: mattermost
description: Comprehensive reference for working with Mattermost — defaults to Mattermost Operator + Enterprise Edition unless the user explicitly asks otherwise. Covers REST API, plugin development, Agents plugin (mattermost-ai) config/MCP/debug, Operator CRD / mattermostEnv, Gateway API HTTPRoute, MM_* env vars (including SAML/OIDC), mmctl, integrations, database schema, and monorepo contribution. Use when the user mentions Mattermost, mmctl, Mattermost Operator, Enterprise Edition, Mattermost plugins, Agents, Copilot, mattermost-ai, MCP tools, LLM Trace, webhooks, CRD, HTTPRoute, Cilium Gateway, EKS RDS S3, MM_ env vars, SAML, OpenID, Entra ID, or the Mattermost server/APIs/database/codebase.
---

# Mattermost

Umbrella skill for anything Mattermost-related. The main `SKILL.md` is a router — pick the topic file for the task at hand instead of loading everything.

## When to use

Trigger on any of:

- Posting messages, managing channels/users/teams via the Mattermost REST API
- Writing or debugging Mattermost plugins (Go server + React/TS webapp)
- Configuring or debugging the **Agents** plugin (`mattermost-ai`) — services, agents, MCP, LLM Trace, Inactive badges
- Deploying or operating Mattermost (Helm, Terraform, Ansible, upgrades, scaling, HA)
- Setting `MM_*` environment variables or Mattermost Operator CRD `spec.mattermostEnv`
- Configuring SAML / OIDC / Entra / Google / GitLab SSO via env vars
- Deploying Mattermost on EKS with RDS and S3 via the Operator CR
- Admin tasks via `mmctl`
- Building bots, slash commands, incoming/outgoing webhooks, or interactive dialogs
- Querying the Mattermost database (Postgres preferred, MySQL legacy) for reporting or debugging
- Contributing to the Mattermost monorepo (conventions, PR workflow, i18n, tests)

If the task is Mattermost-adjacent reporting against Salesforce data (ARR, pipeline, NDR, etc.), use the `salesforce-semantics` skill instead — this one is about the Mattermost product.

## Routing — read the matching file(s) only

| User task | Read |
|-----------|------|
| REST API calls, auth tokens, posting messages, managing resources | [api.md](api.md) |
| Writing a plugin, plugin manifest, server/webapp hooks, bundling | [plugins.md](plugins.md) |
| Agents plugin (`mattermost-ai`): services, agent CRUD, MCP, license limits, debug playbook | [agents.md](agents.md) |
| Helm charts, Terraform modules, Ansible, HA, upgrades, backups | [deploy.md](deploy.md) |
| `MM_*` env vars, Operator CRD `mattermostEnv`, Secrets wiring | [env.md](env.md) |
| Full SAML / OIDC / OAuth / Entra `MM_*` lists, SSO cert mounts | [auth-env.md](auth-env.md) |
| EKS + RDS + S3 Mattermost CR sample (HTTPRoute + Cilium Gateway, IRSA) | [examples/eks-rds-s3-mattermost.yaml](examples/eks-rds-s3-mattermost.yaml) |
| `mmctl` commands, admin automation | [mmctl.md](mmctl.md) |
| Webhooks, slash commands, bot accounts, interactive dialogs | [integrations.md](integrations.md) |
| Database schema, common SQL for debugging/reporting | [database.md](database.md) |
| Working inside `mattermost/mattermost` monorepo (conventions, tests, i18n, PRs) | [contributing.md](contributing.md) |

Do **not** load all topic files at once. Pick the smallest set needed.

## Defaults (override only if the user explicitly asks)

Unless the user says otherwise, **always** assume and recommend:

| Concern | Default |
|---------|---------|
| Deployment method | **Mattermost Operator** (`installation.mattermost.com/v1beta1` `Mattermost` CR) |
| Image / edition | **`mattermost/mattermost-enterprise-edition`** + `licenseSecret` |
| Edge routing | **Gateway API HTTPRoute** → shared Cilium Gateway (`ingress.enabled: false`) |
| Database | External **Postgres** (e.g. RDS), not Operator-managed MySQL/MinIO for prod |
| File store | External **S3** (IRSA / `useServiceAccount: true` preferred) |

Do **not** default to:

- Team Edition image (`mattermost/mattermost-team-edition`)
- Community Helm chart `mattermost-team-edition` as the primary install path
- nginx Ingress / `awsLoadBalancerController` for new work
- Bare `Deployment`/`StatefulSet` without the Operator

Team Edition, the community Helm chart, or non-Operator installs are **opt-in only** — use them when the user explicitly requests Team Edition, TE Helm, or a non-Operator layout.

## Core facts the agent should always keep in mind

- **Monorepo**: As of 2023, server, webapp, mobile, and plugins live in [`mattermost/mattermost`](https://github.com/mattermost/mattermost). Older docs/snippets may reference the split repos (`mattermost-server`, `mattermost-webapp`) — treat those as deprecated paths.
- **API base**: `https://<host>/api/v4` for the server REST API. v3 is dead.
- **Auth**: Personal access tokens or session tokens via `Authorization: Bearer <token>`. Personal access tokens must be enabled in System Console → Integrations → Integration Management.
- **Database**: Postgres is the only supported DB for new deployments. MySQL support has been deprecated — flag any MySQL-specific work as legacy.
- **i18n**: Per workspace rule, **only edit `en.json`** translation files. Never touch other locale files, even derivatives like `en-au.json`.
- **Edition**: Default **Enterprise**. Enterprise unlocks HA/cluster, advanced SSO, compliance, and most production ops features. Always include `spec.licenseSecret` (or `MM_LICENSE`) in Operator examples. Mention Team Edition only if the user opts in or asks about TE limits.
- **Self-hosted vs Cloud**: APIs are mostly identical; Cloud restricts some admin endpoints (file store config, cluster settings, SMTP). Flag Cloud-only limits when relevant.

## Writing style for Mattermost output

When generating code, config, or docs for the user:

- Match existing codebase patterns before inventing new ones (check neighbor files first)
- Go code: follow the server's existing style — `plugin.MattermostPlugin` embedding, `model.AppError` for errors, structured logging via `p.API.LogX`
- TypeScript/React (webapp or plugins): functional components, hooks, Redux Toolkit patterns already in use
- Config examples: show both `config.json` snippets and the equivalent `MM_*` environment variable, since ops teams prefer env vars
- Terraform/Helm/Ansible: follow the user's workspace rules in those languages (modular, tag maps in `locals{}`, `depends_on` at top of resource blocks, requests/limits always set, roles/tasks structure, quoted bash vars, secrets in Vault)

## Quick reference — always-useful snippets

### Get your user via API (auth smoke test)

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  "${MM_URL}/api/v4/users/me"
```

### Post a message to a channel

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/posts" \
  -d '{"channel_id": "'"${CHANNEL_ID}"'", "message": "hello"}'
```

### mmctl auth + ping

```bash
mmctl auth login "${MM_URL}" --name local --access-token "${MM_TOKEN}"
mmctl system status
```

For anything beyond these smoke tests, open the matching topic file above.

## Gotchas to flag proactively

- **Rate limits**: Default 10 req/s per user, 10 req/s per IP (configurable). Bulk operations should batch and backoff.
- **Websocket**: Separate endpoint at `/api/v4/websocket`. Required for real-time events; polling is not a substitute.
- **File uploads**: Multipart POST to `/api/v4/files` first, then attach the returned `file_id` to a `/posts` call. Two-step, not one.
- **Channel IDs vs names**: Most API endpoints take the 26-char ID, not the human-readable name. Use `/channels/name/{team_id}/{name}` to resolve.
- **Timestamps**: Milliseconds since epoch, not seconds. Easy miss.
- **Plugin IDs** must match the directory name and `plugin.json` `id` field exactly, or the server rejects the bundle silently in some versions.
- **CSRF**: Browser-based session auth requires `X-CSRF-Token`. Token-based auth does not.

## Follow-ups the user might not have asked

- Want a working `mmctl` wrapper script in bash with login + common ops?
- Need a Terraform module for a Mattermost deployment on EKS or EC2?
- Want a starter plugin scaffold (Go server + React webapp)?
- Need SQL dashboards against the Mattermost DB for user/channel/post analytics?

Ask the user if any of these would be useful before expanding scope.
