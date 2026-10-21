# mmctl CLI

`mmctl` is the official admin CLI. Talks to the server over the REST API (remote mode) or directly to the DB via Unix socket (local mode). Replaces the deprecated `mattermost` subcommands for admin tasks.

## Install

- Linux: `wget https://github.com/mattermost/mmctl/releases/latest/download/linux_amd64.tar -O - | tar -x`
- macOS: `brew install mmctl`
- Container: already bundled in the official Mattermost image at `/mattermost/bin/mmctl`
- Windows: binary from the GitHub releases page

Match the mmctl version to the server version — minor-version skew is usually fine, major skew breaks.

## Two modes

### Remote mode (default) — uses REST API

```bash
mmctl auth login https://chat.example.com --name prod --username admin
# Prompts for password or MFA

# Or non-interactive with a PAT:
mmctl auth login https://chat.example.com --name prod \
  --access-token "${MM_TOKEN}"

mmctl auth list
mmctl auth current
mmctl auth set prod   # switch active context
```

Contexts live in `~/.config/mmctl/`. Multiple servers can be configured; switch with `mmctl auth set`.

### Local mode — uses Unix socket, no auth needed

```bash
# On the server host:
mmctl --local system status
```

Requires `MM_SERVICESETTINGS_ENABLELOCALMODE=true` and the socket path configured (`MM_SERVICESETTINGS_LOCALMODESOCKETLOCATION`, default `/var/tmp/mattermost_local.socket`).

**Use local mode for**: break-glass admin ops, bootstrap scripts, running from inside the container when auth is broken.

**Don't use local mode for**: anything on a workstation. Remote mode with a scoped PAT is safer and auditable.

## High-value commands

### User management

```bash
# Create user
mmctl user create --email alice@example.com --username alice --password 'temp-pw' --firstname Alice

# Set role
mmctl user roles system_admin alice

# Reset password
mmctl user reset-password alice

# Deactivate (keeps data, blocks login)
mmctl user deactivate alice

# Search
mmctl user search alice@example.com
mmctl user list --page 0 --per-page 100
```

### Team / channel ops

```bash
# Create team
mmctl team create --name eng --display-name "Engineering" --email admin@example.com

# Add users to team (bulk from stdin)
echo -e "alice\nbob\ncarol" | xargs -I{} mmctl team users add eng {}

# Create channel
mmctl channel create --team eng --name incidents --display-name "Incidents" --type O

# Archive channel
mmctl channel archive eng:old-project
```

Channel references use `team:channel` or the 26-char ID.

### Plugins

```bash
mmctl plugin add my-plugin-0.1.0.tar.gz
mmctl plugin enable com.example.my-plugin
mmctl plugin list
mmctl plugin disable com.example.my-plugin
mmctl plugin delete com.example.my-plugin

# Marketplace install
mmctl plugin marketplace install github 2.1.0
```

### Config

```bash
# Get a specific setting
mmctl config get ServiceSettings.SiteURL

# Set a setting (overrides config.json; may be rejected if read-only)
mmctl config set ServiceSettings.MaximumLoginAttempts 5

# Dump full config
mmctl config show > config-backup.json

# Validate a config file
mmctl config validate --local --config /path/to/config.json

# Patch config from a partial JSON
mmctl config patch patch.json
```

In HA with `ReadOnlyConfig=true`, `mmctl config set` fails. Edit the source (env vars, Helm values) instead.

### Export / import

```bash
# Export a team's full history to a JSONL bundle
mmctl export create --attachments team=eng
mmctl export list
mmctl export download <export-id> ./eng-export.zip

# Compliance export (Enterprise)
mmctl compliance-export list
```

### Jobs & health

```bash
mmctl system status
mmctl system version
mmctl system ping
mmctl logs --number 500        # tail server logs via API
mmctl permissions show         # inspect role/permission matrix
```

### Websocket debugging

```bash
mmctl websocket           # live-tail WS events from the server
```

Streams events as JSON. Useful for debugging plugin event delivery or seeing what a user "sees" in real time.

## Scripting pattern

Common wrapper for bash automation — per workspace rule, quote vars and use functions.

```bash
#!/usr/bin/env bash
set -euo pipefail

MM_URL="${MM_URL:?set MM_URL}"
MM_TOKEN="${MM_TOKEN:?set MM_TOKEN}"
MM_CONTEXT="${MM_CONTEXT:-prod-automation}"

mm_login() {
    mmctl auth login "${MM_URL}" \
        --name "${MM_CONTEXT}" \
        --access-token "${MM_TOKEN}" >/dev/null
    mmctl auth set "${MM_CONTEXT}" >/dev/null
}

mm_logout() {
    mmctl auth delete "${MM_CONTEXT}" >/dev/null || true
}

create_incident_channel() {
    local team="${1}"
    local name="${2}"
    mmctl channel create \
        --team "${team}" \
        --name "${name}" \
        --display-name "Incident ${name}" \
        --type O
}

main() {
    trap mm_logout EXIT
    mm_login
    create_incident_channel "ops" "inc-$(date -u +%Y%m%d-%H%M)"
}

main "$@"
```

## Gotchas

- **Version skew**: Server rejects some commands silently if mmctl is too old. Check `mmctl version` and `mmctl system version` match.
- **Password + MFA**: Interactive login prompts for MFA code if enabled. Non-interactive flows must use a PAT.
- **Rate limits apply**: Remote mode goes through the API and respects rate limits. Bulk ops may need `--per-page` tuning + sleeps.
- **`--local` ignores auth entirely**: Anyone with socket access is a system admin. Lock down filesystem permissions on the socket.
- **Export jobs are async**: `mmctl export create` returns a job ID; download only works once the job hits `success`. Poll `mmctl export list`.
- **Deleting users**: `mmctl user delete` is **permanent**. Prefer `deactivate` unless GDPR/retention policy requires hard delete.
- **Config patches don't restart**: Some settings only take effect after a server restart (e.g. plugin changes, cluster settings).
