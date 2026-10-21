# Mattermost Database

Reference for querying the Mattermost DB directly — for debugging, reporting, or data recovery. **Postgres is the only supported database** going forward; MySQL is deprecated and should be flagged as legacy.

## Read-only, always

Direct writes are **unsupported** and can corrupt internal state (counters, caches, search indexes). Use the API or `mmctl` for any mutation. These queries assume you're on a read replica or using `BEGIN TRANSACTION READ ONLY`.

## Core tables

| Table | Purpose |
|-------|---------|
| `users` | User accounts |
| `teams` | Teams |
| `teammembers` | User ↔ team membership |
| `channels` | Channels (public/private/DM/group DM) |
| `channelmembers` | User ↔ channel membership + mention counts |
| `posts` | Messages (including edits/deletions as separate rows) |
| `reactions` | Emoji reactions on posts |
| `fileinfo` | File attachment metadata (actual bytes in file store) |
| `sessions` | Active user sessions |
| `bots` | Bot accounts (joined with `users`) |
| `pluginkeyvaluestore` | Plugin KV store contents |
| `audits` | Admin action audit log |
| `jobs` | Background job history |
| `preferences` | Per-user settings (sidebar order, flagged posts, etc.) |

## Common gotchas before writing SQL

- **Soft deletes everywhere**: `users.deleteat`, `channels.deleteat`, `posts.deleteat`, `teams.deleteat`, etc. `deleteat = 0` means active. Default to `WHERE deleteat = 0` unless you want historical.
- **Timestamps are bigint milliseconds since epoch** — not Postgres `timestamp`. Convert with `to_timestamp(createat / 1000)`.
- **Channel types**: `type` column — `'O'` open, `'P'` private, `'D'` direct, `'G'` group.
- **Post types**: `type` is empty string for user messages. System messages (`system_join_channel`, `system_add_to_channel`, etc.) have non-empty types. Almost always exclude: `WHERE posts.type = ''`.
- **DM channel names**: `name` is the two user IDs sorted and joined with `__`. There's no human-readable name.
- **Reply posts**: `rootid` is empty for top-level posts, else the root post ID. `parentid` was removed in newer schemas — use `rootid`.
- **Lowercase column names**: Postgres lowercases unquoted identifiers. In Mattermost, columns are all lowercase (`createat` not `CreateAt`, despite the Go struct naming).
- **Edits**: Editing a post updates the row in place (`editat` becomes non-zero and `originalid` points to a copy of the pre-edit row). Original rows have `deleteat > 0`.

## High-value queries

### Active user count last 7 days

```sql
SELECT COUNT(DISTINCT userid) AS active_users
FROM status
WHERE lastactivityat > (EXTRACT(EPOCH FROM NOW()) - 7*86400) * 1000;
```

(`status` table tracks last-seen; separate from `sessions` which tracks login tokens.)

### Message volume by day

```sql
SELECT
    DATE(to_timestamp(createat / 1000)) AS day,
    COUNT(*) AS posts
FROM posts
WHERE deleteat = 0
  AND type = ''
  AND createat > (EXTRACT(EPOCH FROM NOW()) - 30*86400) * 1000
GROUP BY day
ORDER BY day;
```

### Top 20 busiest channels last 30 days

```sql
SELECT
    c.displayname,
    c.name,
    t.name AS team_name,
    COUNT(*) AS post_count
FROM posts p
JOIN channels c ON p.channelid = c.id
LEFT JOIN teams t ON c.teamid = t.id
WHERE p.deleteat = 0
  AND p.type = ''
  AND p.createat > (EXTRACT(EPOCH FROM NOW()) - 30*86400) * 1000
GROUP BY c.id, c.displayname, c.name, t.name
ORDER BY post_count DESC
LIMIT 20;
```

### Users in a channel (resolve to usernames)

```sql
SELECT u.username, u.email, cm.lastviewedat
FROM channelmembers cm
JOIN users u ON cm.userid = u.id
JOIN channels c ON cm.channelid = c.id
WHERE c.name = 'incidents'
  AND u.deleteat = 0
ORDER BY u.username;
```

### Find a post by content

```sql
SELECT
    to_timestamp(createat / 1000) AS when_posted,
    u.username,
    c.name AS channel,
    LEFT(p.message, 200) AS preview
FROM posts p
JOIN users u ON p.userid = u.id
JOIN channels c ON p.channelid = c.id
WHERE p.message ILIKE '%deploy failed%'
  AND p.deleteat = 0
  AND p.createat > (EXTRACT(EPOCH FROM NOW()) - 7*86400) * 1000
ORDER BY p.createat DESC
LIMIT 50;
```

For large tables, consider full-text search via Elasticsearch rather than `ILIKE` scans.

### Orphaned file attachments

```sql
SELECT COUNT(*) AS orphaned_files, SUM(size) AS total_bytes
FROM fileinfo
WHERE postid = '' AND createat < (EXTRACT(EPOCH FROM NOW()) - 7*86400) * 1000;
```

Files uploaded but never attached to a post. Can be cleaned up with `mmctl import process --cleanup`.

### Plugin KV store contents

```sql
SELECT pluginid, pkey, LENGTH(pvalue) AS value_bytes
FROM pluginkeyvaluestore
WHERE pluginid = 'com.example.my-plugin'
ORDER BY pkey;
```

Values are stored as `bytea`. Decode in app code, not SQL.

### Audit trail for a specific admin action

```sql
SELECT
    to_timestamp(createat / 1000) AS when_happened,
    u.username,
    action,
    extrainfo,
    ipaddress
FROM audits a
JOIN users u ON a.userid = u.id
WHERE action ILIKE '%channel%delete%'
  AND createat > (EXTRACT(EPOCH FROM NOW()) - 30*86400) * 1000
ORDER BY createat DESC;
```

## Indexes to know about

Mattermost ships with indexes on hot query paths. When adding reporting queries, check `pg_stat_user_indexes` for existing coverage before complaining about slow scans:

- `posts(channelid, createat)` — channel timeline
- `posts(userid, createat)` — user activity
- `posts(rootid)` — thread lookups
- `channels(teamid, name)` — name resolution
- `users(email)` + `users(username)` — login paths
- `sessions(userid, expiresat)` — session cleanup

Avoid adding custom indexes to production without coordinating — they slow down writes, and the next upgrade may add overlapping ones.

## Analytical patterns

For reporting dashboards, prefer:

1. **Read replica** — Postgres streaming replica, Mattermost auto-routes some reads if `SqlSettings.DataSourceReplicas` is set.
2. **ETL to a warehouse** — nightly dump to Snowflake/BigQuery/Redshift. Mattermost ships a `metrics` plugin that can push some aggregates; for custom metrics, pull from the DB.
3. **Materialized views** on the replica — refresh hourly for heavy aggregations.

Don't run multi-minute analytical queries against the primary.

## MySQL legacy notes

If you encounter a MySQL deployment:

- Column case differs (`CreateAt` vs `createat`) — MySQL preserves case; Postgres doesn't.
- Timestamp arithmetic uses `UNIX_TIMESTAMP() * 1000` instead of `EXTRACT(EPOCH FROM NOW()) * 1000`.
- `ILIKE` doesn't exist — use `LIKE` with `COLLATE utf8mb4_general_ci`.
- Flag it to the user as deprecated and recommend migration to Postgres (see [Mattermost migration guide](https://docs.mattermost.com/deploy/postgres-migration.html)).

## Direct DB write — don't

Repeat: don't. If a user asks to "just update a row to fix X":

1. First suggest the API or `mmctl` equivalent.
2. If no API path exists, flag the risk explicitly (cache invalidation, search index drift, audit log bypass, replication lag).
3. If they still want to proceed, require a full backup first and warn that the change won't be auditable.
