# Mattermost Agents plugin

Plugin ID: **`mattermost-ai`** (UI name: **Agents**; formerly Copilot / Mattermost AI).

Repo: [`mattermost/mattermost-plugin-agents`](https://github.com/mattermost/mattermost-plugin-agents)  
Docs: [Admin guide](https://docs.mattermost.com/administration-guide/configure/agents-admin-guide), in-repo `docs/admin_guide.md`, `docs/features/managing_agents.md`, `docs/upgrading_to_2.0.md`, `docs/providers.md`.

Assume **Operator + Enterprise Edition** (this skill’s default). Agents features unlock by license — Enterprise is required for many production capabilities (multiple services, remote MCP, state-changing tools, semantic search, etc.).

## Mental model (v2)

| Piece | Where it lives | What it is |
|-------|----------------|------------|
| Plugin enable / services / MCP servers / web search / embeddings | `PluginSettings.Plugins["mattermost-ai"]` (`config` key) + System Console → **Plugins → Agents** | Shared LLM **services**, plugin-wide toggles |
| Agents (bots) | DB table **`Agents_UserAgents`** + linked Mattermost bot user | Per-agent identity, instructions, access, MCP grants |
| Conversations | `LLM_Conversations` / `LLM_Turns` | Chat history (v2); not in `config.bots` |
| Default agent | `config.defaultBotName` (System Console) | Fallback when user has no explicit selection |

**Do not** expect agents to live only in `config.json`. Backups must include plugin config **and** `Agents_*` / `LLM_*` tables.

Legacy v1 `config.bots` migrate into `Agents_UserAgents` on first v2 start, then are cleared from config.

## Prerequisites checklist

- Mattermost Server **v12.0+** for current plugin builds (`plugin.json` `min_server_version`)
- PostgreSQL (required)
- For semantic search: Postgres **`pgvector`**
- Outbound network to LLM provider (or set `HTTP_PROXY` / `HTTPS_PROXY` on the Mattermost **server process / pods**)
- Enterprise license uploaded (or Entry auto-applied on EE without a paid license — behaves as Enterprise for many features)

## Quick start (happy path)

1. Confirm plugin enabled: System Console → Plugin Management → **Agents** (`mattermost-ai`), or `mmctl plugin list`.
2. System Console → **Plugins → Agents**:
   - Enable plugin
   - **Add a Service** (OpenAI / Anthropic / Azure / Bedrock / …) with API key + default model
   - Set **default bot** after you create an agent
3. Open product switcher → **Agents** (or `/plug/mattermost-ai/agents`):
   - **Create agent** → bind Service → custom instructions → Access → MCPs
4. DM the agent `@username` or use the Agents RHS / AI actions.

Operator note: enable via `MM_PLUGINSETTINGS_PLUGINSTATES` JSON including `"mattermost-ai":{"Enable":true}`. Service API keys are usually set in System Console (custom `Config` setting is secret) — avoid stuffing secrets into git-managed CR env unless using sealed secrets.

## Where to configure what

| Goal | UI |
|------|-----|
| LLM providers (services), fallbacks, token logging, debug, LLM Trace, hostname allowlist | System Console → Plugins → Agents |
| Web search (Brave / Google built-in) | Plugins → Agents → Web Search |
| Embedding / semantic search + reindex | Plugins → Agents → Embedding Search |
| MCP remote servers, Tools approval policies | Plugins → Agents → MCP / Tools tabs |
| Create/edit/delete agents, instructions, vision/tools, MCP grants | **Agents product page** (not System Console AI Bots editor) |
| Default agent | System Console (AI Bots section still holds default bot picker) |

Agent editor tabs:

1. **Configuration** — name, username (immutable after create), service, model override, instructions, vision, tools, native tools (web search/fetch/code), reasoning, max tool turns
2. **Access** — channel / user / team allow|block; agent admins; ABAC (Enterprise Advanced)
3. **MCPs** — only if Enable Tools is on; dynamic loading + auto-enable all vs tool allowlist; service-account MCP mode

## Services (LLM providers)

Supported types: `openai`, `anthropic`, `azure`, `openaicompatible`, `asage`, `cohere`, `north`, `mistral`, `scale` (+ Bedrock via AWS settings).

Common fields: name, type, apiKey, defaultModel, fallbackServiceID (Enterprise Advanced), input/output token limits, streaming timeout, `structuredOutputPolicy` (`auto` | `native` | `prompt_fallback`).

Provider gotchas:

- **OpenAI (direct)** always uses Responses API
- **OpenAI Compatible / Azure**: optional “Use Responses API” for native tools / reasoning
- **Bedrock**: IAM role preferred on EKS; Claude models need AWS FTU + Bedrock IAM; see `docs/aws_bedrock_setup.md`
- Multiple services: **Enterprise+**. Free/Professional only the **first** service in the list is active — agents bound to other services show **Inactive**

Inspect live config (admin):

```bash
# After auth as system admin — pick up rewritten 26-char service IDs after upgrades
curl -sH "Authorization: Bearer ${MM_TOKEN}" \
  "${MM_URL}/plugins/mattermost-ai/admin/config" | jq .
```

Do not hard-code old UUID service IDs in automation after upgrades.

## License / agent limits (debug “can’t create”)

| License | Active agents (approx) | Notable unlocks |
|---------|------------------------|-----------------|
| Free | 1 | Embedded MCP read-only tools |
| Professional | 3 | Multiplayer channel tools, access lists, native web search, summaries |
| Enterprise / Entry | Unlimited | Multiple services, remote MCP, state-changing tools, semantic search, tool approval, MCP service accounts |
| Enterprise Advanced | Unlimited | Fallback service chains, channel auto-reply, ABAC |

Permissions:

| Permission | Effect |
|------------|--------|
| `manage_own_agent` | Create + manage agents you admin |
| `manage_others_agent` | Manage any agent |
| `manage_system` | Sysadmin; required for migrated legacy bots (no creator) |

## MCP (tools)

- Embedded Mattermost MCP + MCP client: **always on** (no master disable toggle)
- Remote MCP: **Enterprise+**
- System Console MCP: add remote servers (URL, headers, OAuth client, service-account headers)
- **Tools** tab: enable/disable tools + approval policy (auto / require approval)
- Per-agent **MCPs** tab: allowlist / auto-enable all; **dynamic tool loading** (default on) loads schemas on demand

Auth modes:

- **Per-user OAuth** — user must Connect before tools appear
- **Service account** — shared headers on the MCP server; Mattermost/plugin tools still run as the requesting user; restrict who can use the agent

Empty tools list:

1. Enable Tools on the agent
2. OAuth: user not connected
3. Service account: missing/bad headers → “No service account credentials” / “Couldn't connect”
4. Tool disabled in System Console Tools tab
5. ABAC denied MCP server (tools silently missing)

Tool failure behavior: agent may retry; **3 consecutive tool failures** then stop and ask the user. Use LLM Trace to see errors.

## Debugging playbook

### 1. Confirm plugin health

```bash
mmctl plugin list | grep -i mattermost-ai
# or
curl -sH "Authorization: Bearer ${MM_TOKEN}" "${MM_URL}/api/v4/plugins" | jq '.active[] | select(.id=="mattermost-ai")'
```

- Plugin disabled → enable `mattermost-ai`
- Wrong server version → check `min_server_version` / release notes

### 2. Turn on temporary diagnostics

System Console → Plugins → Agents:

- **Debug logging** — extra diagnostics (off in prod after)
- **LLM Trace** — full LLM request/response (sensitive; off after)
- **Token usage logging** → `logs/agents/token_usage.log` (JSONL)

Server logs: filter structured field **`plugin_ai=mattermost-ai`**.

```bash
# Example: pods via Operator
kubectl -n mattermost logs -l app=mattermost --tail=500 | grep -i 'plugin_ai\|mattermost-ai\|agents'
```

### 3. Symptom → check

| Symptom | Check |
|---------|--------|
| No Agents UI / panel asks to configure LLM | No services configured, or plugin disabled |
| Create agent disabled + upgrade hint | License agent cap hit (Free=1, Pro=3) |
| Create agent button hidden | Missing `manage_own_agent` / not sysadmin |
| Agent **Inactive** badge | Hover tooltip: bad/missing service, service not on plan (non-first service on Free/Pro), or agent limit |
| Agent missing for non-admin | Access rules or **service ABAC** hides it (not shown as Inactive) |
| DMs work, @mention in channel doesn’t use tools | Enable Channel Mention Tool Calling (experimental); native web search in channels is a separate toggle |
| Streaming hangs / timeouts | Service streaming timeout; proxy; provider outage; fallback chain |
| Tools never run / approval stuck | Tools tab approval policy; initiator-only approval in channels; Enable Tools off |
| MCP tools empty | See MCP section above |
| Semantic search empty / 503 | pgvector; embedding config; reindex job; deferred reindex leaves search down until rebuild |
| Works on one HA node only | Cluster event for `agent_update`; reload plugin on stale node; check cluster logs |
| Avatar didn’t change | Second request failed; max 10MB; re-upload |
| Username taken | Bot username immutable; delete unused agent or pick new name |

### 4. Metrics / traces

- Prometheus: Mattermost metrics listen address (default `:8067`) + path **`/plugins/mattermost-ai/metrics`**
  - `agents_llm_requests_total`, `agents_http_errors_total`, `agents_api_time_seconds`, …
- OpenTelemetry: tool + MCP spans when tracing enabled (see admin guide OpenTelemetry section; local Tempo compose in plugin repo for dev)

### 5. Config / DB inspection

```sql
-- Agents (names vary slightly by migration; confirm with \dt Agents*
SELECT id, username, displayname, serviceid, botuserid, creatorid, enablevision, disabletools
FROM agents_useragents;  -- actual casing: Agents_UserAgents on Postgres often quoted

-- System migration flags
SELECT * FROM agents_system;
```

Prefer admin HTTP API over hand-editing DB.

Useful plugin routes (auth required; admin for config):

- `GET /plugins/mattermost-ai/admin/config`
- Agent CRUD under `/plugins/mattermost-ai/...` (see managing_agents.md — `POST/PUT/DELETE` agents)
- Channel auto-reply: `GET|PUT /plugins/mattermost-ai/channel/{channelId}/autoreply` (Enterprise Advanced UI; REST on older servers)

### 6. Network / proxy

Outbound LLM calls use the Mattermost process environment:

```yaml
# Mattermost CR mattermostEnv example
- name: HTTP_PROXY
  value: "http://proxy.example.com:8080"
- name: HTTPS_PROXY
  value: "http://proxy.example.com:8080"
- name: NO_PROXY
  value: "kubernetes.default,.svc,.cluster.local"
```

Also set **Allowed upstream hostnames** in plugin settings when tools fetch URLs.

### 7. After fixing — turn diagnostics off

Disable Debug + LLM Trace in production to cut log volume and avoid leaking prompts/PII.

## Operator / Enterprise deploy notes

```yaml
# Enable plugin (example fragment — merge into existing PLUGINSTATES JSON)
mattermostEnv:
  - name: MM_PLUGINSETTINGS_ENABLEUPLOADS
    value: "false"   # still fine if plugin is prebundled / marketplace
  - name: MM_PLUGINSETTINGS_PLUGINSTATES
    value: '{"mattermost-ai":{"Enable":true}}'
```

- Image: `mattermost/mattermost-enterprise-edition` + `licenseSecret`
- Ensure pods can reach provider endpoints (NetworkPolicy / proxy)
- For Bedrock: IRSA on the Mattermost ServiceAccount with `bedrock:InvokeModel*`
- pgvector: enable on RDS/Aurora or Postgres operator before turning on embedding search
- Backup: Postgres dump must include `Agents_*` and `LLM_*` tables, not only `config.json`

## Embedding search (Enterprise+) — short ops

1. Enable pgvector on Postgres  
2. Configure embedding provider/model/dimensions  
3. Run **Full Reindex** (required after model/dimension/precision change — not Resume)  
4. Large corpora: set **Reindex Index Strategy = defer**, expect search **503** until rebuild finishes  
5. Catch Up widens window without full re-embed of existing rows  

## v1 → v2 upgrade (if relevant)

- Backup DB + `config.json` first (`LLM_PostMeta` dropped; titles not migrated)
- Prefer Mattermost path documented in `docs/upgrading_to_2.0.md` (e.g. latest 11.6.x then 11.7+ with Agents v2)
- Legacy bots migrate to DB; managed by sysadmin afterward
- MCP client / embedded server toggles removed (always on)

## Related skill files

- Plugin packaging / hooks generally → [plugins.md](plugins.md)
- `MM_PLUGINSETTINGS_*` → [env.md](env.md)
- Operator CR / HTTPRoute → [deploy.md](deploy.md), [examples/eks-rds-s3-mattermost.yaml](examples/eks-rds-s3-mattermost.yaml)
