# Mattermost Auth Environment Variables (SAML / OIDC / OAuth)

Complete `MM_*` catalog for authentication providers, derived from current `model.Config` (`SamlSettings`, `SSOSettings` / `OpenIdSettings` / `GitLabSettings` / `GoogleSettings`, `Office365Settings`) and the [Authentication configuration settings](https://docs.mattermost.com/administration-guide/configure/authentication-configuration-settings.html) docs.

For LDAP, RBAC schemes, ABAC policies, and how SSO fits with access control, read [identity-access.md](identity-access.md) first — this file is the provider env-var deep dive.

**Version note:** Field names below match current Mattermost server `config.go`. From v11, new SAML installs default `SignatureAlgorithm` to `RSAwithSHA256` (was `RSAwithSHA1`). Always confirm against your target image tag if something looks off.

Secrets (`Secret`, `Id`, bind passwords, cert file *paths*) should come from Kubernetes Secrets via `valueFrom` in CRD `mattermostEnv` — not plaintext in the CR.

---

## Decision guide

| Provider | Config block | Typical use |
|----------|--------------|-------------|
| SAML 2.0 (Okta, ADFS, OneLogin, Ping, etc.) | `SamlSettings` | Enterprise SSO |
| Custom OpenID Connect | `OpenIdSettings` | Generic OIDC IdP |
| GitLab | `GitLabSettings` | GitLab OAuth **or** OIDC (same keys; set DiscoveryEndpoint for OIDC) |
| Google | `GoogleSettings` | Google OAuth **or** OIDC |
| Microsoft Entra ID | `Office365Settings` | Entra OAuth **or** OIDC (`DirectoryId` required) |

Enable **one primary** interactive SSO path for users. Multiple can be on, but login UX gets messy.

---

## SamlSettings — full list

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_SAMLSETTINGS_ENABLE` | `Enable` | Master switch |
| `MM_SAMLSETTINGS_ENABLESYNCWITHLDAP` | `EnableSyncWithLdap` | Needs LDAP configured; v10.9+ login checks LDAP existence |
| `MM_SAMLSETTINGS_ENABLESYNCWITHLDAPINCLUDEAUTH` | `EnableSyncWithLdapIncludeAuth` | Override SAML ID/email binding with LDAP attrs |
| `MM_SAMLSETTINGS_IGNOREGUESTSLDAPSYNC` | `IgnoreGuestsLdapSync` | Skip LDAP sync for SAML guests |
| `MM_SAMLSETTINGS_VERIFY` | `Verify` | Default `true` — verify response signature |
| `MM_SAMLSETTINGS_ENCRYPT` | `Encrypt` | Default `true` — decrypt assertions |
| `MM_SAMLSETTINGS_SIGNREQUEST` | `SignRequest` | Sign AuthnRequest with SP private key |
| `MM_SAMLSETTINGS_IDPURL` | `IdpURL` | IdP SSO URL (where Mattermost sends SAML request) |
| `MM_SAMLSETTINGS_IDPDESCRIPTORURL` | `IdpDescriptorURL` | IdP issuer / Entity ID |
| `MM_SAMLSETTINGS_IDPMETADATAURL` | `IdpMetadataURL` | IdP metadata URL |
| `MM_SAMLSETTINGS_SERVICEPROVIDERIDENTIFIER` | `ServiceProviderIdentifier` | SP Entity ID (ADFS Relying Party Identifier) |
| `MM_SAMLSETTINGS_ASSERTIONCONSUMERSERVICEURL` | `AssertionConsumerServiceURL` | `https://<site>/login/sso/saml` |
| `MM_SAMLSETTINGS_SIGNATUREALGORITHM` | `SignatureAlgorithm` | `RSAwithSHA1` \| `RSAwithSHA256` \| `RSAwithSHA512` |
| `MM_SAMLSETTINGS_CANONICALALGORITHM` | `CanonicalAlgorithm` | `Canonical1.0` \| `Canonical1.1` |
| `MM_SAMLSETTINGS_SCOPINGIDPPROVIDERID` | `ScopingIDPProviderId` | Optional IdP scoping |
| `MM_SAMLSETTINGS_SCOPINGIDPNAME` | `ScopingIDPName` | Optional IdP scoping display name |
| `MM_SAMLSETTINGS_IDPCERTIFICATEFILE` | `IdpCertificateFile` | Path to IdP public cert **inside the pod** |
| `MM_SAMLSETTINGS_PUBLICCERTIFICATEFILE` | `PublicCertificateFile` | Path to SP public cert |
| `MM_SAMLSETTINGS_PRIVATEKEYFILE` | `PrivateKeyFile` | Path to SP private key |
| `MM_SAMLSETTINGS_IDATTRIBUTE` | `IdAttribute` | Stable user bind attribute |
| `MM_SAMLSETTINGS_GUESTATTRIBUTE` | `GuestAttribute` | Guest role mapping |
| `MM_SAMLSETTINGS_ENABLEADMINATTRIBUTE` | `EnableAdminAttribute` | |
| `MM_SAMLSETTINGS_ADMINATTRIBUTE` | `AdminAttribute` | System admin designation (not LDAP Admin Filter) |
| `MM_SAMLSETTINGS_FIRSTNAMEATTRIBUTE` | `FirstNameAttribute` | |
| `MM_SAMLSETTINGS_LASTNAMEATTRIBUTE` | `LastNameAttribute` | |
| `MM_SAMLSETTINGS_EMAILATTRIBUTE` | `EmailAttribute` | Required for notifications |
| `MM_SAMLSETTINGS_USERNAMEATTRIBUTE` | `UsernameAttribute` | UI identity / @mentions |
| `MM_SAMLSETTINGS_NICKNAMEATTRIBUTE` | `NicknameAttribute` | |
| `MM_SAMLSETTINGS_LOCALEATTRIBUTE` | `LocaleAttribute` | |
| `MM_SAMLSETTINGS_POSITIONATTRIBUTE` | `PositionAttribute` | |
| `MM_SAMLSETTINGS_LOGINBUTTONTEXT` | `LoginButtonText` | Default `SAML` |

### SAML cert files in Kubernetes

Env vars point at **file paths**, not PEM contents. Mount certs as a Secret volume, then set paths:

```yaml
# On the Mattermost CR
spec:
  volumes:
    - name: saml-certs
      secret:
        secretName: mattermost-saml-certs
  volumeMounts:
    - name: saml-certs
      mountPath: /etc/mattermost/saml
      readOnly: true
  mattermostEnv:
    - name: MM_SAMLSETTINGS_ENABLE
      value: "true"
    - name: MM_SAMLSETTINGS_IDPCERTIFICATEFILE
      value: "/etc/mattermost/saml/idp.crt"
    - name: MM_SAMLSETTINGS_PUBLICCERTIFICATEFILE
      value: "/etc/mattermost/saml/sp.crt"
    - name: MM_SAMLSETTINGS_PRIVATEKEYFILE
      value: "/etc/mattermost/saml/sp.key"
    - name: MM_SAMLSETTINGS_ASSERTIONCONSUMERSERVICEURL
      value: "https://chat.example.com/login/sso/saml"
    - name: MM_SAMLSETTINGS_SERVICEPROVIDERIDENTIFIER
      value: "https://chat.example.com/login/sso/saml"
    - name: MM_SAMLSETTINGS_VERIFY
      value: "true"
    - name: MM_SAMLSETTINGS_ENCRYPT
      value: "true"
    - name: MM_SAMLSETTINGS_SIGNATUREALGORITHM
      value: "RSAwithSHA256"
    - name: MM_SAMLSETTINGS_EMAILATTRIBUTE
      value: "Email"
    - name: MM_SAMLSETTINGS_USERNAMEATTRIBUTE
      value: "Username"
    - name: MM_SAMLSETTINGS_IDATTRIBUTE
      value: "Id"
```

IdP URL / descriptor / metadata usually also come from env or Secret:

```yaml
    - name: MM_SAMLSETTINGS_IDPURL
      valueFrom:
        secretKeyRef:
          name: mattermost-saml
          key: idp_url
    - name: MM_SAMLSETTINGS_IDPDESCRIPTORURL
      valueFrom:
        secretKeyRef:
          name: mattermost-saml
          key: idp_descriptor_url
    - name: MM_SAMLSETTINGS_IDPMETADATAURL
      valueFrom:
        secretKeyRef:
          name: mattermost-saml
          key: idp_metadata_url
```

---

## OpenIdSettings — custom OIDC (full list)

Uses embedded `SSOSettings` fields under `OpenIdSettings` in `config.json`.

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_OPENIDSETTINGS_ENABLE` | `Enable` | |
| `MM_OPENIDSETTINGS_ID` | `Id` | Client ID |
| `MM_OPENIDSETTINGS_SECRET` | `Secret` | Client secret — use Secret |
| `MM_OPENIDSETTINGS_SCOPE` | `Scope` | Default `profile openid email` |
| `MM_OPENIDSETTINGS_DISCOVERYENDPOINT` | `DiscoveryEndpoint` | `.../.well-known/openid-configuration` |
| `MM_OPENIDSETTINGS_AUTHENDPOINT` | `AuthEndpoint` | Optional if discovery set |
| `MM_OPENIDSETTINGS_TOKENENDPOINT` | `TokenEndpoint` | Optional if discovery set |
| `MM_OPENIDSETTINGS_USERAPIENDPOINT` | `UserAPIEndpoint` | Optional if discovery set |
| `MM_OPENIDSETTINGS_BUTTONTEXT` | `ButtonText` | Login button label |
| `MM_OPENIDSETTINGS_BUTTONCOLOR` | `ButtonColor` | e.g. `#145DBF` |
| `MM_OPENIDSETTINGS_USEPREFERREDUSERNAME` | `UsePreferredUsername` | Map `preferred_username` claim |

### Custom OIDC `mattermostEnv` example

```yaml
mattermostEnv:
  - name: MM_OPENIDSETTINGS_ENABLE
    value: "true"
  - name: MM_OPENIDSETTINGS_BUTTONTEXT
    value: "Company SSO"
  - name: MM_OPENIDSETTINGS_BUTTONCOLOR
    value: "#145DBF"
  - name: MM_OPENIDSETTINGS_SCOPE
    value: "profile openid email"
  - name: MM_OPENIDSETTINGS_DISCOVERYENDPOINT
    value: "https://idp.example.com/.well-known/openid-configuration"
  - name: MM_OPENIDSETTINGS_USEPREFERREDUSERNAME
    value: "true"
  - name: MM_OPENIDSETTINGS_ID
    valueFrom:
      secretKeyRef:
        name: mattermost-oidc
        key: client_id
  - name: MM_OPENIDSETTINGS_SECRET
    valueFrom:
      secretKeyRef:
        name: mattermost-oidc
        key: client_secret
```

Redirect URIs to register at the IdP (pattern):
- `https://<site>/login/openid/complete`
- `https://<site>/signup/openid/complete`

(Exact paths follow Mattermost OpenID docs for your version — verify in docs if customizing.)

---

## GitLabSettings — OAuth + OIDC

Same `SSOSettings` shape. For OpenID, set `DiscoveryEndpoint`; for classic OAuth, set Auth/Token/UserAPI endpoints.

| Env | config.json |
|-----|-------------|
| `MM_GITLABSETTINGS_ENABLE` | `Enable` |
| `MM_GITLABSETTINGS_ID` | `Id` |
| `MM_GITLABSETTINGS_SECRET` | `Secret` |
| `MM_GITLABSETTINGS_SCOPE` | `Scope` |
| `MM_GITLABSETTINGS_DISCOVERYENDPOINT` | `DiscoveryEndpoint` |
| `MM_GITLABSETTINGS_AUTHENDPOINT` | `AuthEndpoint` |
| `MM_GITLABSETTINGS_TOKENENDPOINT` | `TokenEndpoint` |
| `MM_GITLABSETTINGS_USERAPIENDPOINT` | `UserAPIEndpoint` |
| `MM_GITLABSETTINGS_BUTTONTEXT` | `ButtonText` |
| `MM_GITLABSETTINGS_BUTTONCOLOR` | `ButtonColor` |
| `MM_GITLABSETTINGS_USEPREFERREDUSERNAME` | `UsePreferredUsername` |

GitLab.com OIDC discovery default: `https://gitlab.com/.well-known/openid-configuration`

Team Edition OAuth often requires `read_user` scope; Enterprise/Professional OpenID requires at least `openid`.

Redirect URLs:
- `https://<site>/login/gitlab/complete`
- `https://<site>/signup/gitlab/complete`

---

## GoogleSettings — OAuth + OIDC

| Env | config.json | Default / notes |
|-----|-------------|-----------------|
| `MM_GOOGLESETTINGS_ENABLE` | `Enable` | |
| `MM_GOOGLESETTINGS_ID` | `Id` | Client ID |
| `MM_GOOGLESETTINGS_SECRET` | `Secret` | Client secret |
| `MM_GOOGLESETTINGS_SCOPE` | `Scope` | OAuth default historically `profile email`; OIDC uses `profile openid email` |
| `MM_GOOGLESETTINGS_DISCOVERYENDPOINT` | `DiscoveryEndpoint` | `https://accounts.google.com/.well-known/openid-configuration` |
| `MM_GOOGLESETTINGS_AUTHENDPOINT` | `AuthEndpoint` | `https://accounts.google.com/o/oauth2/v2/auth` |
| `MM_GOOGLESETTINGS_TOKENENDPOINT` | `TokenEndpoint` | `https://www.googleapis.com/oauth2/v4/token` |
| `MM_GOOGLESETTINGS_USERAPIENDPOINT` | `UserAPIEndpoint` | People API URL (see docs) |
| `MM_GOOGLESETTINGS_BUTTONTEXT` | `ButtonText` | |
| `MM_GOOGLESETTINGS_BUTTONCOLOR` | `ButtonColor` | |
| `MM_GOOGLESETTINGS_USEPREFERREDUSERNAME` | `UsePreferredUsername` | Documented for OIDC; preferred_username support for Google has historically been limited — test on your version |

---

## Office365Settings — Entra ID (OAuth + OIDC)

Extends SSO fields with `DirectoryId`.

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_OFFICE365SETTINGS_ENABLE` | `Enable` | |
| `MM_OFFICE365SETTINGS_ID` | `Id` | Application (client) ID |
| `MM_OFFICE365SETTINGS_SECRET` | `Secret` | Client secret |
| `MM_OFFICE365SETTINGS_DIRECTORYID` | `DirectoryId` | Tenant ID — **required** for Entra |
| `MM_OFFICE365SETTINGS_SCOPE` | `Scope` | OAuth default `User.Read`; OIDC typically includes `openid` |
| `MM_OFFICE365SETTINGS_DISCOVERYENDPOINT` | `DiscoveryEndpoint` | Often `https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration` or tenant-specific |
| `MM_OFFICE365SETTINGS_AUTHENDPOINT` | `AuthEndpoint` | `https://login.microsoftonline.com/common/oauth2/v2.0/authorize` |
| `MM_OFFICE365SETTINGS_TOKENENDPOINT` | `TokenEndpoint` | `https://login.microsoftonline.com/common/oauth2/v2.0/token` |
| `MM_OFFICE365SETTINGS_USERAPIENDPOINT` | `UserAPIEndpoint` | `https://graph.microsoft.com/v1.0/me` |
| `MM_OFFICE365SETTINGS_USEPREFERREDUSERNAME` | `UsePreferredUsername` | |

Entra OIDC discovery is commonly tenant-scoped:

```text
https://login.microsoftonline.com/<DirectoryId>/v2.0/.well-known/openid-configuration
```

### Entra ID `mattermostEnv` example

```yaml
mattermostEnv:
  - name: MM_OFFICE365SETTINGS_ENABLE
    value: "true"
  - name: MM_OFFICE365SETTINGS_USEPREFERREDUSERNAME
    value: "true"
  - name: MM_OFFICE365SETTINGS_DIRECTORYID
    valueFrom:
      secretKeyRef:
        name: mattermost-entra
        key: directory_id
  - name: MM_OFFICE365SETTINGS_ID
    valueFrom:
      secretKeyRef:
        name: mattermost-entra
        key: client_id
  - name: MM_OFFICE365SETTINGS_SECRET
    valueFrom:
      secretKeyRef:
        name: mattermost-entra
        key: client_secret
  - name: MM_OFFICE365SETTINGS_DISCOVERYENDPOINT
    valueFrom:
      secretKeyRef:
        name: mattermost-entra
        key: discovery_endpoint
```

---

## Related ServiceSettings (login policy)

Often set alongside SSO:

| Env | Purpose |
|-----|---------|
| `MM_EMAILSETTINGS_ENABLESIGNUPWITHEMAIL` | Disable local signup when SSO-only |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHEMAIL` | Disable email/password login |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHUSERNAME` | Disable username/password login |
| `MM_TEAMSETTINGS_ENABLEOPENSERVER` | Allow account creation without invite |
| `MM_TEAMSETTINGS_ENABLEUSERCREATION` | Allow new user creation |
| `MM_SERVICESETTINGS_ENABLEMULTIFACTORAUTHENTICATION` | MFA for local/LDAP (SSO MFA is IdP-side) |
| `MM_SERVICESETTINGS_ENABLEEMAILINVITATIONS` | Invite emails |

SSO-only starter:

```yaml
- name: MM_EMAILSETTINGS_ENABLESIGNINWITHEMAIL
  value: "false"
- name: MM_EMAILSETTINGS_ENABLESIGNINWITHUSERNAME
  value: "false"
- name: MM_EMAILSETTINGS_ENABLESIGNUPWITHEMAIL
  value: "false"
```

Keep one break-glass local system admin until SSO is verified.

---

## Gotchas

- **Cert paths vs PEM**: SAML `*CertificateFile` / `PrivateKeyFile` are filesystem paths. Mount Secrets; don't paste PEM into the env var.
- **ACS URL must match SiteURL**: `MM_SERVICESETTINGS_SITEURL` + `/login/sso/saml` must equal `AssertionConsumerServiceURL`.
- **HA + license**: SSO features may require Professional/Enterprise — set `spec.licenseSecret` on the CR.
- **Discovery vs manual endpoints**: Prefer DiscoveryEndpoint for OIDC; Auth/Token/UserAPI are fallbacks / OAuth-era fields.
- **GitLab/Google/Office365 blocks are reused** for both OAuth 2.0 and OpenID Connect console sections — same env names.
- **v10.9+ SAML+LDAP sync**: If `EnableSyncWithLdap=true`, users missing from LDAP fail login.
- **Never commit client secrets** in GitOps plaintext — ExternalSecrets / SealedSecrets / SOPS.
