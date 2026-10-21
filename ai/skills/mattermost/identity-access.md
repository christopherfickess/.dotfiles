# Mattermost identity & access (SSO / LDAP / RBAC / ABAC)

How users authenticate and what they can reach. Default assumption: **Operator + Enterprise Edition** (this skill’s default). ABAC and some RBAC features need **Entry / Enterprise Advanced**.

| Layer | What it answers | Where |
|-------|-----------------|--------|
| **SSO** (SAML / OIDC / OAuth) | Who are you at login? | System Console → Authentication; `MM_SAML*` / `MM_OPENID*` / … → full env lists in [auth-env.md](auth-env.md) |
| **LDAP / AD** | Directory login + sync of users/groups/attrs | Authentication → AD/LDAP; `MM_LDAPSETTINGS_*` |
| **RBAC** (permissions / schemes) | What actions can this role take? | User Management → Permissions; API roles |
| **ABAC** (attributes) | Who may be in this team/channel / do this action? | System Attributes → Attribute-Based Access; `MM_ACCESSCONTROLSETTINGS_*` |

**Env var dumps for SAML/OIDC/Entra:** [auth-env.md](auth-env.md)  
**Agents plugin ABAC (MCP / services):** [agents.md](agents.md)

---

## Decision guide

| Goal | Use |
|------|-----|
| Corporate IdP login (Okta, Entra, ADFS, Ping) | **SAML** or **OIDC** ([auth-env.md](auth-env.md)) |
| Entra / Google / GitLab social-style SSO | **Office365** / **Google** / **GitLab** settings (same file) |
| Sync users/groups from AD, filter guests/admins | **LDAP** (+ optional SAML with `EnableSyncWithLdap`) |
| Restrict who can create channels, manage webhooks, etc. | **RBAC** System Scheme / Team Override Schemes |
| Restrict membership by dept / clearance / custom attrs | **ABAC** (Entry / Enterprise Advanced, v10.9+) |
| Delegate System Console slices without full sysadmin | **Delegated granular admin** roles (Enterprise+) |

Prefer **one primary interactive SSO** for end users. LDAP can still sync in the background when SAML/`EnableSyncWithLdap` is on.

---

## Mental model

```text
IdP / LDAP ──login+attrs──► Mattermost User
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
                 RBAC         ABAC       Team/Channel
              (can I act?)  (may I be    membership
                             here?)
```

- **RBAC** grants *capabilities* via roles in system / team / channel **context** (permissions cascade down).
- **ABAC** gates *membership* (and some actions) using **user / session attributes**. Private team/channel = strict; public = advisory (recommend / auto-add, no hard remove).
- Group-synced channels, shared channels, and default channels (Town Square / Off-Topic) are **ineligible** for ABAC membership policies.

---

## SSO (SAML / OIDC / OAuth) — ops checklist

1. Set `MM_SERVICESETTINGS_SITEURL` correctly (ACS / redirect URIs derive from it).
2. Enable provider (`MM_SAMLSETTINGS_ENABLE` or OpenID/Office365/…).
3. Register IdP redirect / ACS URLs (SAML ACS: `https://<site>/login/sso/saml`).
4. Mount certs as files in the pod for SAML (`IdpCertificateFile`, SP cert/key) — env vars are **paths**, not PEM blobs. See [auth-env.md](auth-env.md).
5. Map `Id` / `Email` / `Username` attributes; keep `IdAttribute` stable across IdP changes.
6. Optional: `MM_SAMLSETTINGS_ENABLESYNCWITHLDAP=true` when LDAP is also configured (login may require LDAP existence from v10.9+).
7. Test: Incognito → SSO button → land in Mattermost; check System Console → Users for Auth method.

Debug SSO:

| Symptom | Check |
|---------|--------|
| Infinite redirect / blank | SiteURL, proxy headers, cookie Secure/SameSite |
| Signature / decrypt errors | IdP cert mount path, Encrypt/Verify, SignatureAlgorithm (v11+ default SHA256) |
| User created but wrong email | EmailAttribute / claim mapping |
| Works for one user only | IdP group assignment / Mattermost user filter |

Full `MM_*` tables: [auth-env.md](auth-env.md).

---

## LDAP / Active Directory

License: LDAP sync is an **Enterprise** feature (login+sync). Configure in System Console → Authentication → AD/LDAP or via env.

### Core `MM_LDAPSETTINGS_*`

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_LDAPSETTINGS_ENABLE` | `Enable` | Allow LDAP login |
| `MM_LDAPSETTINGS_ENABLESYNC` | `EnableSync` | Background user/group sync (defaults with Enable if unset) |
| `MM_LDAPSETTINGS_LDAPSERVER` | `LdapServer` | Host |
| `MM_LDAPSETTINGS_LDAPPORT` | `LdapPort` | Default `389` |
| `MM_LDAPSETTINGS_CONNECTIONSECURITY` | `ConnectionSecurity` | `""` \| `TLS` \| `STARTTLS` |
| `MM_LDAPSETTINGS_BASEDN` | `BaseDN` | Search base |
| `MM_LDAPSETTINGS_BINDUSERNAME` | `BindUsername` | Service account DN/UPN |
| `MM_LDAPSETTINGS_BINDPASSWORD` | `BindPassword` | Secret |
| `MM_LDAPSETTINGS_USERFILTER` | `UserFilter` | e.g. `(objectClass=user)` / AD group member filters |
| `MM_LDAPSETTINGS_GROUPFILTER` | `GroupFilter` | Group sync (Enterprise) |
| `MM_LDAPSETTINGS_GUESTFILTER` | `GuestFilter` | Auto guest |
| `MM_LDAPSETTINGS_ENABLEADMINFILTER` | `EnableAdminFilter` | |
| `MM_LDAPSETTINGS_ADMINFILTER` | `AdminFilter` | Auto system admin (dangerous — keep tight) |
| `MM_LDAPSETTINGS_IDATTRIBUTE` | `IdAttribute` | Stable ID (often `objectGUID` / `entryUUID`) |
| `MM_LDAPSETTINGS_USERNAMEATTRIBUTE` | `UsernameAttribute` | |
| `MM_LDAPSETTINGS_LOGINIDATTRIBUTE` | `LoginIdAttribute` | What user types at login |
| `MM_LDAPSETTINGS_EMAILATTRIBUTE` | `EmailAttribute` | |
| `MM_LDAPSETTINGS_FIRSTNAMEATTRIBUTE` | `FirstNameAttribute` | |
| `MM_LDAPSETTINGS_LASTNAMEATTRIBUTE` | `LastNameAttribute` | |
| `MM_LDAPSETTINGS_NICKNAMEATTRIBUTE` | `NicknameAttribute` | |
| `MM_LDAPSETTINGS_POSITIONATTRIBUTE` | `PositionAttribute` | Good ABAC source when synced |
| `MM_LDAPSETTINGS_PICTUREATTRIBUTE` | `PictureAttribute` | |
| `MM_LDAPSETTINGS_GROUPDISPLAYNAMEATTRIBUTE` | `GroupDisplayNameAttribute` | |
| `MM_LDAPSETTINGS_GROUPIDATTRIBUTE` | `GroupIdAttribute` | |
| `MM_LDAPSETTINGS_SYNCINTERVALMINUTES` | `SyncIntervalMinutes` | |
| `MM_LDAPSETTINGS_READDREMOVEDMEMBERS` | `ReAddRemovedMembers` | |
| `MM_LDAPSETTINGS_QUERYTIMEOUT` | `QueryTimeout` | |
| `MM_LDAPSETTINGS_MAXPAGESIZE` | `MaxPageSize` | AD paging |
| `MM_LDAPSETTINGS_MAXIMUMLOGINATTEMPTS` | `MaximumLoginAttempts` | |
| `MM_LDAPSETTINGS_SKIPCERTIFICATEVERIFICATION` | `SkipCertificateVerification` | Dev only |
| `MM_LDAPSETTINGS_PUBLICCERTIFICATEFILE` | `PublicCertificateFile` | Client TLS |
| `MM_LDAPSETTINGS_PRIVATEKEYFILE` | `PrivateKeyFile` | Client TLS |
| `MM_LDAPSETTINGS_LOGINFIELDNAME` | `LoginFieldName` | UI label |

### Operator fragment

```yaml
mattermostEnv:
  - name: MM_LDAPSETTINGS_ENABLE
    value: "true"
  - name: MM_LDAPSETTINGS_ENABLESYNC
    value: "true"
  - name: MM_LDAPSETTINGS_LDAPSERVER
    value: "ldap.example.com"
  - name: MM_LDAPSETTINGS_LDAPPORT
    value: "636"
  - name: MM_LDAPSETTINGS_CONNECTIONSECURITY
    value: "TLS"
  - name: MM_LDAPSETTINGS_BASEDN
    value: "DC=example,DC=com"
  - name: MM_LDAPSETTINGS_USERFILTER
    value: "(objectCategory=person)"
  - name: MM_LDAPSETTINGS_IDATTRIBUTE
    value: "objectGUID"
  - name: MM_LDAPSETTINGS_USERNAMEATTRIBUTE
    value: "sAMAccountName"
  - name: MM_LDAPSETTINGS_LOGINIDATTRIBUTE
    value: "sAMAccountName"
  - name: MM_LDAPSETTINGS_EMAILATTRIBUTE
    value: "mail"
  - name: MM_LDAPSETTINGS_BINDUSERNAME
    valueFrom:
      secretKeyRef:
        name: mattermost-ldap
        key: bind_username
  - name: MM_LDAPSETTINGS_BINDPASSWORD
    valueFrom:
      secretKeyRef:
        name: mattermost-ldap
        key: bind_password
```

### LDAP + SAML together

- SAML for interactive login UX; LDAP for directory truth / groups / attributes.
- `MM_SAMLSETTINGS_ENABLESYNCWITHLDAP` / `EnableSyncWithLdapIncludeAuth` — see [auth-env.md](auth-env.md).
- Group sync → System Console → Groups; link AD groups to teams/channels (Enterprise).

### LDAP debug

| Symptom | Check |
|---------|--------|
| Bind failed | Bind DN/password, TLS, firewall from pods to LDAP |
| Empty sync | BaseDN, UserFilter, MaxPageSize, QueryTimeout |
| Duplicate users | IdAttribute changed; users created via email before LDAP |
| Admin filter too broad | Disable AdminFilter until verified |
| mmctl | `mmctl ldap sync` / job status (version-dependent) |

NetworkPolicy: Mattermost pods must reach `LdapServer:LdapPort`.

---

## RBAC (permissions & schemes)

Mattermost uses a **modified RBAC**: permissions → roles → users in a **context** (system / team / channel). Permissions **cascade** from parent contexts.

Docs: [Advanced permissions](https://docs.mattermost.com/administration-guide/onboard/advanced-permissions.html), [backend](https://docs.mattermost.com/administration-guide/onboard/advanced-permissions-backend-infrastructure.html).

### Schemes

| Scheme | Scope | Notes |
|--------|-------|-------|
| **System Scheme** | All teams/channels | Defaults for guests, members, channel admins, team admins, system admin |
| **Team Override Scheme** | Assigned teams only | Entry / Enterprise Advanced; **replaces** System Scheme for that team (team in at most one override) |

UI: System Console → User Management → Permissions.

### Built-in role IDs (common)

| Role ID | Meaning |
|---------|---------|
| `system_admin` | Full system admin |
| `system_user` | Base authenticated user |
| `system_guest` | Guest (if guests enabled) |
| `team_admin` / `team_user` / `team_guest` | Team context |
| `channel_admin` / `channel_user` / `channel_guest` | Channel context |

Channel-level member/admin toggles and channel moderation still apply on top of schemes.

### Delegated granular administration (Enterprise+)

System Console → User Management → System Roles (or Delegated Granular Administration):

| Role | Typical use |
|------|-------------|
| System Manager | Broad console R/W except sensitive areas |
| User Manager | Users / teams / channels |
| Custom Group Manager | Custom groups only |
| Shared Channel Manager | Shared channels |
| Viewer | Read-mostly console |

**Gotcha:** granting **Can Edit** on *any* System Console page can expose `PUT /api/v4/config/patch` broadly — treat write access as high privilege.

### API / automation

- Permissions are enforced on REST endpoints; bots need the right roles.
- Inspect roles: System Console or `/api/v4/roles` / user role endpoints (admin token).
- mmctl: prefer documented `mmctl permissions` / `mmctl roles` commands for your server version (`mmctl help`).

### RBAC debug

| Symptom | Check |
|---------|--------|
| Can’t create public channel | System Scheme → All Members → create public channel; Team Override |
| Guest can see too much | Guest Accounts + guest permissions in scheme |
| Team behaves differently | Team Override Scheme membership |
| Plugin UI hidden | Plugin may check custom permissions — confirm role grant |

---

## ABAC (attribute-based access)

Available on **Entry and Enterprise Advanced**. Introduced ~**v10.9**; team membership ABAC from ~**v11.10**; public/private semantics refined in **v11.8+**. Confirm against your image tag.

Docs hub: [Attribute-Based Access Control](https://docs.mattermost.com/administration-guide/manage/admin/attribute-based-access-control.html).

### Prerequisites

1. Define **user attributes** (System Console → System Attributes / Attribute management). Prefer LDAP/SAML-synced or admin-managed attributes for policy use.
2. Enable ABAC: System Console → System Attributes → Attribute-Based Access.
3. From **v10.11**, **user-managed** attributes are **excluded** from ABAC by default (users can’t edit themselves into access). Opt-in: `EnableUserManagedAttributes`.
4. From **v12**, **session attributes** (IP, VPN, device posture, …) can appear in permission policies after enabling each under Session Attributes.

### `MM_ACCESSCONTROLSETTINGS_*`

| Env | config.json | Default / notes |
|-----|-------------|-----------------|
| `MM_ACCESSCONTROLSETTINGS_ENABLEATTRIBUTEBASEDACCESSCONTROL` | `EnableAttributeBasedAccessControl` | `false` |
| `MM_ACCESSCONTROLSETTINGS_ENABLEUSERMANAGEDATTRIBUTES` | `EnableUserManagedAttributes` | `false` — allow user-editable attrs in rules (risky) |
| `MM_ACCESSCONTROLSETTINGS_ENABLECHANNELPOLICYINDICATORS` | `EnableChannelPolicyIndicators` | `true` — UI hints; disable to reduce policy leakage |
| `MM_ACCESSCONTROLSETTINGS_TRUSTPROXYDEVICEIDENTITYHEADER` | `TrustProxyDeviceIdentityHeader` | `false` — only if proxy is trusted |
| `MM_ACCESSCONTROLSETTINGS_ENFORCEDEVICEIDCONSISTENCY` | `EnforceDeviceIDConsistency` | `false` |
| `MM_ACCESSCONTROLSETTINGS_ENABLEACCESSCONTROLAUDITLOGGING` | `EnableAccessControlAuditLogging` | `false` |
| `MM_ACCESSCONTROLSETTINGS_SYNCJOBINTERVALSECONDS` | `SyncJobIntervalSeconds` | `3600`; **minimum 60** (restart to apply) |
| `MM_ACCESSCONTROLSETTINGS_ATTRIBUTEREFRESHINTERVALSECONDS` | `AttributeRefreshIntervalSeconds` | `30` |

```yaml
mattermostEnv:
  - name: MM_ACCESSCONTROLSETTINGS_ENABLEATTRIBUTEBASEDACCESSCONTROL
    value: "true"
  - name: MM_ACCESSCONTROLSETTINGS_ENABLEACCESSCONTROLAUDITLOGGING
    value: "true"
  - name: MM_ACCESSCONTROLSETTINGS_SYNCJOBINTERVALSECONDS
    value: "3600"
```

### Policy types

| Type | Who manages | Effect |
|------|-------------|--------|
| System-wide policies | System Admin | Apply across many channels/teams |
| Permission policies | System Admin | Attribute rules on actions (e.g. file upload/download, burn-on-read) |
| Team membership policies | System / Team Admin | Who may join / see team (v11.10+) |
| Team-scoped channel policies | Team Admin | Channels in that team |
| Channel-specific rules | Channel / Team Admin | Single channel (Channel Settings) |

### Private vs public (strict vs advisory)

| Resource | Behaviour |
|----------|-----------|
| **Private** channel/team | Hard gate: non-matching members removed on sync; only matching users add/invite |
| **Public** channel/team | Advisory: no forced removals; auto-add and/or “Recommended” in browse UI |

Channel-specific rules are **additive** with system policies: for private channels **both** must pass.

Self-exclusion protection exists for private channel rule editors (don’t lock yourself out).

### ABAC + Agents

Agents plugin can use ABAC on MCP servers / services (Enterprise Advanced). Denied users often **don’t see** the agent (not an Inactive badge). See [agents.md](agents.md).

### ABAC debug

| Symptom | Check |
|---------|--------|
| Policy never fires | ABAC disabled; license not Advanced/Entry; attribute not populated |
| User edited attr to gain access | User-managed attrs — keep `EnableUserManagedAttributes=false` |
| Public channel still joinable | Expected (advisory) — use private for hard gates |
| Members not removed | Sync interval; private vs public; ineligible channel type |
| Session attr rules ignored | Session attribute not enabled; proxy trust flags |
| After config change no effect | SyncJobIntervalSeconds needs **process restart** to reschedule |

API surface (admin): `/api/v4/access_control_*` style routes — see server `access_control.go` / docs for your version.

---

## End-to-end patterns (Enterprise)

### Pattern A — SAML login + LDAP attrs + ABAC channels

1. Entra/Okta SAML → Mattermost ([auth-env.md](auth-env.md)).
2. LDAP sync for `department` / `memberOf`-derived custom attributes (or SAML attrs mapped into user profile).
3. Enable ABAC; create system policy `department == Engineering` on private channels.
4. Keep RBAC System Scheme for who can *create* channels; ABAC for who can *join* sensitive ones.

### Pattern B — LDAP-only shop

1. `MM_LDAPSETTINGS_ENABLE` + sync + group sync.
2. Link LDAP groups to teams/channels.
3. RBAC schemes for action permissions.
4. ABAC optional if group sync already sufficient.

### Pattern C — OIDC + RBAC only (no ABAC)

1. OpenID / Entra OIDC.
2. System Scheme + Team Overrides.
3. Skip ABAC unless Entry/Advanced license and attribute policies are required.

---

## Quick verification commands

```bash
# Auth + whoami
curl -sH "Authorization: Bearer ${MM_TOKEN}" "${MM_URL}/api/v4/users/me" | jq '{id,username,email,auth_service,roles}'

# Config fragments (sysadmin) — redact secrets
curl -sH "Authorization: Bearer ${MM_TOKEN}" "${MM_URL}/api/v4/config" | \
  jq '{Saml: .SamlSettings.Enable, Ldap: .LdapSettings.Enable, ABAC: .AccessControlSettings.EnableAttributeBasedAccessControl}'
```

```bash
mmctl user search email@example.com
# LDAP sync job — check mmctl help for your version
```

---

## Related skill files

- SAML/OIDC/Entra full `MM_*` → [auth-env.md](auth-env.md)
- General env / CRD → [env.md](env.md)
- Agents access / ABAC on MCP → [agents.md](agents.md)
- Deploy Operator mounts for SAML certs → [deploy.md](deploy.md)
