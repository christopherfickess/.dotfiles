# Mattermost REST API

Base URL: `https://<host>/api/v4`. All endpoints documented at [api.mattermost.com](https://api.mattermost.com/).

## Authentication

Three auth modes, in order of preference for automation:

1. **Personal Access Token (PAT)** — long-lived, per-user, revocable. Must be enabled in System Console → Integrations → Integration Management → "Enable Personal Access Tokens".
2. **Bot Access Token** — issued when a bot account is created via `/api/v4/bots`. Preferred for integrations (bot shows as the sender, not a human).
3. **Session token** — obtained from `/users/login`. Short-lived, carries CSRF requirements for browser clients.

Header for all three:

```
Authorization: Bearer <token>
```

Session login (returns token in `Token` response header):

```bash
curl -i -X POST "${MM_URL}/api/v4/users/login" \
  -H "Content-Type: application/json" \
  -d '{"login_id":"admin","password":"'"${PASS}"'"}'
```

## Common operations

### Resolve team / channel / user IDs

```bash
# Team by name
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  "${MM_URL}/api/v4/teams/name/${TEAM_NAME}"

# Channel by name (needs team ID)
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  "${MM_URL}/api/v4/teams/${TEAM_ID}/channels/name/${CHANNEL_NAME}"

# User by username
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  "${MM_URL}/api/v4/users/username/${USERNAME}"
```

### Post a message (plain + threaded + with props)

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/posts" \
  -d '{
    "channel_id": "'"${CHANNEL_ID}"'",
    "message": "deploy complete",
    "root_id": "'"${THREAD_ROOT_ID:-}"'",
    "props": {
      "attachments": [{
        "color": "#36a64f",
        "title": "Deploy succeeded",
        "fields": [
          {"short": true, "title": "env", "value": "prod"},
          {"short": true, "title": "sha", "value": "abc123"}
        ]
      }]
    }
  }'
```

`root_id` empty = top-level post. Set to a post ID to reply in a thread.

### Upload a file then attach to a post

Two-step. File first, post second with the returned `file_id`.

```bash
# Step 1: upload
FILE_ID=$(curl -s -H "Authorization: Bearer ${MM_TOKEN}" \
  -F "channel_id=${CHANNEL_ID}" \
  -F "files=@./report.pdf" \
  "${MM_URL}/api/v4/files" | jq -r '.file_infos[0].id')

# Step 2: attach to post
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/posts" \
  -d '{"channel_id":"'"${CHANNEL_ID}"'","message":"report","file_ids":["'"${FILE_ID}"'"]}'
```

### Create a channel

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/channels" \
  -d '{
    "team_id": "'"${TEAM_ID}"'",
    "name": "incident-20261007",
    "display_name": "Incident 2026-10-07",
    "type": "O",
    "purpose": "Active incident channel"
  }'
```

Types: `O` = public, `P` = private, `D` = DM, `G` = group DM.

### Add a user to a channel

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/channels/${CHANNEL_ID}/members" \
  -d '{"user_id":"'"${USER_ID}"'"}'
```

### Search posts

```bash
curl -H "Authorization: Bearer ${MM_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${MM_URL}/api/v4/teams/${TEAM_ID}/posts/search" \
  -d '{"terms":"deploy failed from:ops-bot in:incidents","is_or_search":false}'
```

Search supports modifiers: `from:`, `in:`, `on:`, `before:`, `after:`, `#hashtag`, quoted phrases.

## Pagination

Standard pattern: `?page=0&per_page=200`. Max `per_page` is **200** for most endpoints (not 100 — a common mistake). Loop until a page returns fewer than `per_page` items.

```bash
page=0
while :; do
  resp=$(curl -s -H "Authorization: Bearer ${MM_TOKEN}" \
    "${MM_URL}/api/v4/users?page=${page}&per_page=200")
  count=$(echo "${resp}" | jq 'length')
  [[ "${count}" -eq 0 ]] && break
  echo "${resp}" | jq -c '.[]'
  [[ "${count}" -lt 200 ]] && break
  page=$((page+1))
done
```

## Rate limits

Default: 10 req/s per user and per IP, configurable in `RateLimitSettings`. Bulk work needs backoff:

- Honor `X-Ratelimit-Remaining` and `X-Ratelimit-Reset` response headers
- On HTTP `429`, sleep until `Retry-After` seconds pass
- For large user/channel exports, prefer `mmctl export` or direct DB reads over API loops

## Websocket (real-time events)

Endpoint: `wss://<host>/api/v4/websocket`

Handshake: send an `authentication_challenge` message with your token as the first frame.

```json
{"seq": 1, "action": "authentication_challenge", "data": {"token": "<MM_TOKEN>"}}
```

Server pushes events (`posted`, `channel_viewed`, `user_added`, `typing`, etc.) as JSON. Required for bots that react to messages — polling the API is not a substitute and will hit rate limits.

Python example using `websockets`:

```python
import asyncio, json, os, websockets

async def main():
    url = os.environ["MM_WS_URL"]  # wss://host/api/v4/websocket
    token = os.environ["MM_TOKEN"]
    async with websockets.connect(url) as ws:
        await ws.send(json.dumps({
            "seq": 1,
            "action": "authentication_challenge",
            "data": {"token": token},
        }))
        async for msg in ws:
            event = json.loads(msg)
            if event.get("event") == "posted":
                post = json.loads(event["data"]["post"])
                print(post["channel_id"], post["message"])

asyncio.run(main())
```

## Common gotchas

- **IDs vs names**: Nearly every endpoint takes 26-char IDs. Resolve names first.
- **Timestamps**: `create_at`, `update_at`, `delete_at` are **milliseconds** since epoch. Not seconds.
- **Soft deletes**: `delete_at > 0` means deleted. Default list endpoints exclude deleted; pass `include_deleted=true` to include.
- **Cloud restrictions**: Some admin endpoints (`/config`, `/cluster/*`, `/elasticsearch/*`) return 403 on Cloud workspaces.
- **ETags**: GET endpoints return `ETag` headers; pass `If-None-Match` for conditional requests to save bandwidth.
- **CSRF**: Only required for cookie-session auth from browsers. Token auth is exempt.
- **Field selection**: No GraphQL-style field selection. Full objects always returned — budget for response size.

## Client libraries

- Go: `github.com/mattermost/mattermost/server/public/model` → `model.Client4`
- JS/TS: `@mattermost/client` on npm (`Client4` class)
- Python: `mattermostdriver` (community-maintained, HTTP + WS)

Use these in production code rather than hand-rolled HTTP — they handle auth, pagination, and retries.
