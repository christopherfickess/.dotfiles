# Mattermost Integrations

Covers the four integration surfaces that don't require a full plugin: **incoming webhooks**, **outgoing webhooks**, **slash commands**, and **bot accounts** (with interactive messages and dialogs). All are configured per-team in **Integrations** menu or via API/`mmctl`.

## Decision guide

| Need | Use |
|------|-----|
| Push notifications **into** Mattermost from an external system (CI, monitoring, cron) | **Incoming webhook** |
| React to messages matching a trigger word, call out to an external service | **Outgoing webhook** |
| User types `/mycmd` and gets a response | **Slash command** (external or plugin) |
| Long-running bot that reads WS events, posts, reacts, DMs | **Bot account** + token + WS listener |
| Deep UI integration (modals, custom post rendering, sidebar components) | **Plugin** (see [plugins.md](plugins.md)) |

Rule of thumb: start with a bot + webhooks. Only build a plugin when you need UI surface area or server-side hooks.

## Incoming webhooks

External system POSTs JSON to a Mattermost URL; message appears in a channel.

### Create

System Console must have `ServiceSettings.EnableIncomingWebhooks=true`.

```bash
mmctl webhook create-incoming \
  --channel "eng:alerts" \
  --user "ops-bot" \
  --display-name "Grafana" \
  --description "Grafana alerts"
```

Returns an ID; the webhook URL is `${MM_URL}/hooks/<id>`.

### Post from the external system

```bash
curl -X POST "${MM_URL}/hooks/${HOOK_ID}" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Deployment finished",
    "username": "ci-bot",
    "icon_url": "https://example.com/ci.png",
    "channel": "deploys",
    "attachments": [{
      "color": "#2eb886",
      "title": "Build #482",
      "title_link": "https://ci.example.com/482",
      "fields": [
        {"short": true, "title": "env", "value": "prod"},
        {"short": true, "title": "duration", "value": "4m12s"}
      ]
    }]
  }'
```

- `channel` can be overridden per-request if the hook was created with "lock to channel" off.
- `attachments` schema is Slack-compatible — most Slack integrations work with minimal changes.

### Gotchas

- Webhook URLs are **secrets** — leaked URL = anyone can post as that bot in that channel. Rotate via `mmctl webhook delete-incoming` + recreate.
- No delivery guarantees — if the server is down, your POST fails. Add retries on the caller.
- `username` and `icon_url` overrides require `ServiceSettings.EnablePostUsernameOverride=true` and `EnablePostIconOverride=true`. Default off.

## Outgoing webhooks

Mattermost POSTs to your URL when a message matches a trigger word or channel.

### Create

```bash
mmctl webhook create-outgoing \
  --team eng \
  --channel incidents \
  --trigger-when exact \
  --trigger-word "!status" \
  --url "https://status.example.com/mm-webhook" \
  --user "ops-bot" \
  --display-name "Status Checker"
```

Trigger modes: `exact` (first word matches) or `start` (message starts with trigger).

### Payload sent to your URL

```json
{
  "token": "<verification token — check this>",
  "team_id": "...",
  "channel_id": "...",
  "channel_name": "incidents",
  "user_id": "...",
  "user_name": "alice",
  "post_id": "...",
  "text": "!status prod",
  "trigger_word": "!status"
}
```

**Always validate the `token`** against the one stored at webhook creation. Otherwise anyone who can reach your URL can forge messages.

### Response format

Return a JSON body to reply in-channel:

```json
{
  "text": "Prod is healthy",
  "response_type": "in_channel"
}
```

`response_type: "comment"` posts as a thread reply. Omit to post as a top-level message. Return `{}` or 200 with no body to stay silent.

## Slash commands (external)

Same shape as outgoing webhooks but triggered by typing `/mycmd args` instead of a trigger word.

### Create

```bash
mmctl command create eng \
  --title "Status" \
  --description "Check service status" \
  --trigger "status" \
  --url "https://status.example.com/mm-slash" \
  --creator admin \
  --response-username "status-bot" \
  --post \
  --autocomplete \
  --autocompleteDesc "Check prod status" \
  --autocompleteHint "[service]"
```

### Request payload

Mattermost sends `application/x-www-form-urlencoded` by default (configurable to JSON):

```
token=xxx
team_id=xxx
channel_id=xxx
user_id=xxx
user_name=alice
command=/status
text=prod
response_url=https://chat.example.com/hooks/commands/xxx
```

### Response

Same JSON shape as outgoing webhooks, plus two useful extras:

```json
{
  "response_type": "ephemeral",
  "text": "Checking...",
  "attachments": [{
    "actions": [
      {"id": "refresh", "name": "Refresh", "integration": {"url": "https://.../refresh"}}
    ]
  }]
}
```

- `response_type: "ephemeral"` = only the invoking user sees it.
- `response_url` lets you POST follow-up messages asynchronously (up to 5 within 30 min).

## Bot accounts

Preferred over "fake user" webhook posting. Shows a `BOT` badge, gets its own tokens, survives user policy changes.

### Create

```bash
mmctl bot create ops-bot --display-name "Ops Bot" --description "Ops automation"
mmctl bot assign ops-bot admin   # ownership
```

Then issue a token in System Console → Integrations → Bot Accounts → Create Token, or via API:

```bash
curl -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -X POST "${MM_URL}/api/v4/users/${BOT_USER_ID}/tokens" \
  -d '{"description":"ops automation"}'
```

Store the returned token in a secret manager. It won't be shown again.

### Bot capabilities

Bots can:
- Post to any channel they're a member of
- Be @mentioned
- React with emoji
- Create DM channels and message any user (`/api/v4/channels/direct`)
- Receive mentions via websocket

Bots cannot:
- Log into the webapp UI
- Be added to private channels without an admin or member adding them
- Join teams on their own — admin or team-admin must invite

### Interactive messages

Any post (from a webhook, slash command, or bot) can include `attachments[].actions[]` buttons/menus that call back into your service:

```json
{
  "text": "Deploy to prod?",
  "attachments": [{
    "actions": [
      {
        "id": "deploy_yes",
        "name": "Deploy",
        "style": "primary",
        "integration": {
          "url": "https://ci.example.com/mm/deploy",
          "context": {"env": "prod", "sha": "abc123"}
        }
      },
      {
        "id": "deploy_no",
        "name": "Cancel",
        "style": "danger",
        "integration": {"url": "https://ci.example.com/mm/cancel"}
      }
    ]
  }]
}
```

When clicked, Mattermost POSTs to the `integration.url` with:

```json
{
  "user_id": "...",
  "user_name": "alice",
  "channel_id": "...",
  "team_id": "...",
  "post_id": "...",
  "trigger_id": "...",
  "context": {"env": "prod", "sha": "abc123"}
}
```

Response can `update` the message, post a new one, or open an **interactive dialog**.

### Interactive dialogs (modal forms)

Open a modal in response to a button click:

```json
{
  "trigger_id": "...",
  "url": "https://ci.example.com/mm/dialog-submit",
  "dialog": {
    "callback_id": "deploy_confirm",
    "title": "Confirm deploy",
    "introduction_text": "Deploying `${sha}` to prod",
    "elements": [
      {"display_name": "Reason", "name": "reason", "type": "text", "subtype": "textarea"},
      {"display_name": "Rollback plan ready?", "name": "rollback", "type": "bool"}
    ],
    "submit_label": "Deploy"
  }
}
```

POST this to `/api/v4/actions/dialogs/open` with a valid `trigger_id` (only valid for ~3 seconds after the button click).

On submit, Mattermost POSTs the form values to your `url`.

## Bot message listener (Python example)

Combine bot token + websocket to react to mentions:

```python
import asyncio, json, os, re
import aiohttp
import websockets

MM_URL = os.environ["MM_URL"]
WS_URL = MM_URL.replace("https://", "wss://") + "/api/v4/websocket"
TOKEN = os.environ["MM_BOT_TOKEN"]

async def post(session, channel_id, message, root_id=""):
    await session.post(
        f"{MM_URL}/api/v4/posts",
        headers={"Authorization": f"Bearer {TOKEN}"},
        json={"channel_id": channel_id, "message": message, "root_id": root_id},
    )

async def main():
    async with aiohttp.ClientSession() as session, websockets.connect(WS_URL) as ws:
        await ws.send(json.dumps({
            "seq": 1, "action": "authentication_challenge",
            "data": {"token": TOKEN},
        }))
        async for raw in ws:
            event = json.loads(raw)
            if event.get("event") != "posted":
                continue
            post_data = json.loads(event["data"]["post"])
            if "@ops-bot" not in post_data["message"]:
                continue
            # React in thread
            await post(
                session,
                post_data["channel_id"],
                "on it",
                root_id=post_data.get("root_id") or post_data["id"],
            )

asyncio.run(main())
```

Add reconnect logic + exponential backoff for production.

## Verification tokens — always check them

Every webhook/slash command POST includes a `token` field. Store the expected token at webhook creation; reject requests where it doesn't match. Treat this as the only auth layer for outgoing webhooks and slash commands.

```python
if request.form.get("token") != os.environ["MM_WEBHOOK_TOKEN"]:
    return "forbidden", 403
```

## Gotchas

- **Trigger IDs expire fast** (~3s). Dialog opens must happen immediately on button click, not after slow processing.
- **`response_url` is single-use per invocation window** — 5 messages / 30 min. Don't try to drip-feed updates past that.
- **Attachment field layout**: `short: true` renders two fields side-by-side; `short: false` is full-width. Mix them for compact alerts.
- **Markdown rendering**: Supports a subset of CommonMark + GFM. Code fences, tables, and `~strikethrough~` work. HTML is stripped.
- **@-mentions in messages posted by webhooks**: Need `@channel`, `@here`, or specific usernames spelled out. The sender's identity doesn't carry @-permissions.
- **Cross-team integrations**: Each incoming/outgoing webhook is scoped to one team. Multi-team automation needs a bot account, not webhooks.
- **Rate limits**: Bots are subject to the same per-user rate limit. High-traffic bots should request a dedicated rate limit exemption or batch posts.
