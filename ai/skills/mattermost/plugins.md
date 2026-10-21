# Mattermost Plugins

Plugins extend the server (Go) and/or the webapp (React/TypeScript). They're distributed as a single `.tar.gz` bundle uploaded via System Console or `mmctl plugin add`.

## Anatomy of a plugin bundle

```
my-plugin/
├── plugin.json              # Manifest — required
├── server/
│   ├── plugin.go            # Implements plugin.MattermostPlugin
│   └── ...
├── webapp/
│   ├── src/index.tsx        # Registers webapp components
│   └── package.json
├── assets/                  # Optional static files
└── Makefile                 # Standard build (uses mattermost-plugin-starter-template)
```

## Scaffold with the starter template

Don't build from scratch. Fork or copy [`mattermost/mattermost-plugin-starter-template`](https://github.com/mattermost/mattermost-plugin-starter-template):

```bash
git clone https://github.com/mattermost/mattermost-plugin-starter-template my-plugin
cd my-plugin
# Edit plugin.json: id, name, description
make
# Produces: dist/my-plugin-x.y.z.tar.gz
```

The template handles:
- Go + webapp build orchestration
- Hot-reload during dev (`make deploy`)
- i18n extraction
- Linting + tests

## `plugin.json` essentials

```json
{
  "id": "com.example.my-plugin",
  "name": "My Plugin",
  "description": "Does the thing",
  "homepage_url": "https://github.com/example/my-plugin",
  "support_url": "https://github.com/example/my-plugin/issues",
  "version": "0.1.0",
  "min_server_version": "9.0.0",
  "server": {
    "executables": {
      "linux-amd64": "server/dist/plugin-linux-amd64",
      "linux-arm64": "server/dist/plugin-linux-arm64",
      "darwin-amd64": "server/dist/plugin-darwin-amd64",
      "darwin-arm64": "server/dist/plugin-darwin-arm64",
      "windows-amd64": "server/dist/plugin-windows-amd64.exe"
    }
  },
  "webapp": {
    "bundle_path": "webapp/dist/main.js"
  },
  "settings_schema": {
    "settings": [
      {
        "key": "WelcomeMessage",
        "display_name": "Welcome message",
        "type": "text",
        "default": "Welcome!"
      }
    ]
  }
}
```

- `id` must match the directory name inside the tarball exactly, or the server silently rejects it on some versions. Reverse-DNS style.
- `min_server_version` enforced on install — bump when you depend on a newer API.
- `settings_schema` auto-generates a System Console config page. Types: `text`, `longtext`, `number`, `bool`, `radio`, `dropdown`, `generated`, `username`, `custom`.

## Server plugin (Go)

### Minimal plugin

```go
package main

import (
    "github.com/mattermost/mattermost/server/public/plugin"
    "github.com/mattermost/mattermost/server/public/model"
)

type Plugin struct {
    plugin.MattermostPlugin
}

func (p *Plugin) OnActivate() error {
    p.API.LogInfo("plugin activated")
    return nil
}

func (p *Plugin) MessageWillBePosted(c *plugin.Context, post *model.Post) (*model.Post, string) {
    if post.Message == "ping" {
        post.Message = "pong"
    }
    return post, ""
}

func main() {
    plugin.ClientMain(&Plugin{})
}
```

Return value `(nil, "reason")` from `MessageWillBePosted` **rejects** the post with that reason shown to the user.

### Key hooks (full list in `plugin.Hooks` interface)

| Hook | Fires when |
|------|------------|
| `OnActivate` / `OnDeactivate` | Plugin enabled/disabled |
| `OnConfigurationChange` | System Console settings saved |
| `MessageWillBePosted` | Before a post hits the DB (can modify or reject) |
| `MessageHasBeenPosted` | After post persisted (async, no modification) |
| `MessageWillBeUpdated` / `MessageHasBeenUpdated` | Edits |
| `UserHasJoinedChannel` / `UserHasLeftChannel` | Membership changes |
| `UserHasBeenCreated` / `UserHasLoggedIn` | User lifecycle |
| `ServeHTTP(w, r)` | Any HTTP request to `/plugins/<id>/*` |
| `ExecuteCommand` | Slash command invoked |

### Register a slash command

```go
func (p *Plugin) OnActivate() error {
    return p.API.RegisterCommand(&model.Command{
        Trigger:          "mycmd",
        AutoComplete:     true,
        AutoCompleteDesc: "Does the thing",
        AutoCompleteHint: "[subcommand]",
    })
}

func (p *Plugin) ExecuteCommand(c *plugin.Context, args *model.CommandArgs) (*model.CommandResponse, *model.AppError) {
    return &model.CommandResponse{
        ResponseType: model.CommandResponseTypeEphemeral, // or InChannel
        Text:         "hello " + args.UserId,
    }, nil
}
```

### Config with hot-reload

```go
type configuration struct {
    WelcomeMessage string
}

func (p *Plugin) OnConfigurationChange() error {
    var cfg configuration
    if err := p.API.LoadPluginConfiguration(&cfg); err != nil {
        return err
    }
    p.setConfig(&cfg)
    return nil
}
```

Store config behind a mutex-protected pointer so concurrent requests see atomic swaps.

### KV store (plugin-scoped persistence)

```go
// Set with 1-hour TTL
p.API.KVSetWithExpiry("last-run", []byte(time.Now().String()), 3600)

// Get
val, appErr := p.API.KVGet("last-run")

// Compare-and-swap for atomic updates
p.API.KVCompareAndSet("counter", oldVal, newVal)
```

KV keys are per-plugin, 50-byte max. Values up to 8KB by default; configurable.

### Scheduled jobs

```go
import "github.com/mattermost/mattermost/server/public/plugin"

p.API.RegisterCommand(&model.Command{...})
// For cron-like jobs, use the cluster.Job helper:
job, _ := cluster.Schedule(p.API, "nightly-report", cluster.MakeWaitForRoundedInterval(24*time.Hour), p.runReport)
defer job.Close()
```

`cluster.Schedule` is HA-safe — only one node runs the job at a time.

## Webapp plugin (React/TypeScript)

### Entry point

```tsx
import {Store, Action} from 'redux';

export default class MyPlugin {
    initialize(registry: any, store: Store<any, Action>) {
        registry.registerChannelHeaderButtonAction(
            <Icon/>,
            (channel) => store.dispatch(openModal(channel)),
            'My tooltip',
        );

        registry.registerPostTypeComponent('custom_type', CustomPost);
        registry.registerRootComponent(MyModal);
        registry.registerSlashCommandWillBePostedHook(onCommand);
    }
}

window.registerPlugin('com.example.my-plugin', new MyPlugin());
```

### Common `registry` methods

- `registerChannelHeaderButtonAction` — icon in channel header
- `registerPostTypeComponent(type, Component)` — custom rendering for posts with `type: "custom_<type>"`
- `registerRootComponent(Component)` — modal / overlay root
- `registerMainMenuAction` — menu item in `☰`
- `registerPostDropdownMenuComponent` — post actions dropdown
- `registerLeftSidebarHeaderComponent` — above channel list
- `registerWebSocketEventHandler('custom_<id>_<event>', handler)` — receive events from your server plugin

### Server → webapp events

Server side:

```go
p.API.PublishWebSocketEvent("alert", map[string]interface{}{
    "severity": "high",
    "message":  "something broke",
}, &model.WebsocketBroadcast{ChannelId: channelID})
```

Webapp side:

```ts
registry.registerWebSocketEventHandler(
    'custom_com.example.my-plugin_alert',
    (event) => console.log(event.data),
);
```

Event name is namespaced: `custom_<plugin.id>_<name>`.

## Testing

- Server: standard Go `testing` + `plugintest.API` mock from `github.com/mattermost/mattermost/server/public/plugin/plugintest`
- Webapp: Jest + React Testing Library (template includes config)
- E2E against a real server: `make deploy` + Playwright

Run everything with `make test`.

## Deploying

### Local dev loop

```bash
export MM_SERVICESETTINGS_SITEURL="http://localhost:8065"
export MM_ADMIN_USERNAME=admin
export MM_ADMIN_PASSWORD=admin
make deploy   # Builds + uploads via API + enables
```

### Production

```bash
mmctl plugin add my-plugin-0.1.0.tar.gz
mmctl plugin enable com.example.my-plugin
```

Or upload the `.tar.gz` via System Console → Plugin Management.

## Gotchas

- **Panic recovery**: Hooks that panic crash the plugin process; the server restarts it but you lose state. Always recover in goroutines you spawn.
- **Blocking hooks**: `MessageWillBePosted` runs **synchronously** on the post path. Keep it fast or you'll tank message throughput.
- **Cross-plugin calls**: Only via `p.API.PluginHTTP(req)` to another plugin's `ServeHTTP`. No direct Go imports between plugins.
- **Bundled binaries**: Cross-compile for all target OS/arch combos in `plugin.json`. Missing a platform = plugin fails to activate on that node.
- **Webapp bundle size**: Single bundle, loaded by all users. Keep it small; code-split heavy deps.
- **Settings reload**: `OnConfigurationChange` fires on every save, including unrelated system settings. Diff before reacting if your reload is expensive.
- **i18n**: Server strings via `p.API.GetBundledI18N` + `go-i18n` message files under `assets/i18n/`. Webapp strings via `react-intl`. Per workspace rule, only edit `en.json`.

## Reference links

- API docs: [developers.mattermost.com/integrate/plugins/](https://developers.mattermost.com/integrate/plugins/)
- Hooks reference: `github.com/mattermost/mattermost/server/public/plugin/api.go`
- Webapp registry: `github.com/mattermost/mattermost/webapp/channels/src/plugins/registry.ts`
- Starter template: [`mattermost/mattermost-plugin-starter-template`](https://github.com/mattermost/mattermost-plugin-starter-template)
