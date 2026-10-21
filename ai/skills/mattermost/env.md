# Mattermost Environment Variables

Every `config.json` leaf maps to an `MM_*` env var. Env vars **override** `config.json`. Settings controlled by env become read-only in System Console; if another console change is saved, the env value is written back into `config.json`.

Authoritative docs:
- [Environment variables](https://docs.mattermost.com/administration-guide/configure/environment-variables.html)
- [Environment configuration settings](https://docs.mattermost.com/administration-guide/configure/environment-configuration-settings.html)
- [Site](https://docs.mattermost.com/administration-guide/configure/site-configuration-settings.html) / [Authentication](https://docs.mattermost.com/administration-guide/configure/authentication-configuration-settings.html) / other System Console sections (same `MM_*` derivation)

## Naming rule (derive any setting)

1. Take the `config.json` path: `ServiceSettings.SiteURL`
2. Prefix `MM_`, uppercase, replace `.` with `_`
3. Result: `MM_SERVICESETTINGS_SITEURL`

Nested structs keep every segment:

| config.json path | Env var |
|------------------|---------|
| `SqlSettings.DataSource` | `MM_SQLSETTINGS_DATASOURCE` |
| `FileSettings.AmazonS3Bucket` | `MM_FILESETTINGS_AMAZONS3BUCKET` |
| `AutoTranslationSettings.LibreTranslate.URL` | `MM_AUTOTRANSLATIONSETTINGS_LIBRETRANSLATE_URL` |
| `PluginSettings.PluginStates` | `MM_PLUGINSETTINGS_PLUGINSTATES` (JSON string) |

**Types:**
- bool → `"true"` / `"false"` (strings in Kubernetes)
- number → string digit, e.g. `"100"`
- string array → JSON array string, e.g. `'["X-Forwarded-For","X-Real-Ip"]'`
- object maps (plugins) → JSON object string (supported since v7.5 for `PLUGINS` / `PLUGINSTATES`)

**Special non-config vars:**
| Var | Purpose |
|-----|---------|
| `MM_LICENSE` | License file contents; overrides DB/file license for that process |
| `MM_CUSTOM_DEFAULTS_PATH` | Path to JSON of defaults applied only when keys are unset |
| `MM_CONFIG` | (container/operator contexts) path or DB config store URI when used |

Restart required for env changes that restart-require in `config.json`.

---

## Mattermost Operator CRD — `spec.mattermostEnv`

CR: `apiVersion: installation.mattermost.com/v1beta1`, `kind: Mattermost`

`spec.mattermostEnv` is a standard Kubernetes `[]EnvVar` list injected into Mattermost **application** pods.

### Literal values

```yaml
apiVersion: installation.mattermost.com/v1beta1
kind: Mattermost
metadata:
  name: mattermost
spec:
  image: mattermost/mattermost-enterprise-edition
  version: "10.5.0"
  replicas: 2
  ingress:
    enabled: true
    host: chat.example.com
  database:
    external:
      secret: db-credentials
  fileStore:
    external:
      url: s3.amazonaws.com
      bucket: mattermost-prod-files
      secret: file-store-credentials
  mattermostEnv:
    - name: MM_SERVICESETTINGS_SITEURL
      value: "https://chat.example.com"
    - name: MM_SERVICESETTINGS_ENABLELOCALMODE
      value: "true"
    - name: MM_FILESETTINGS_AMAZONS3SSL
      value: "true"
    - name: MM_FILESETTINGS_AMAZONS3SSE
      value: "true"
    - name: MM_FILESETTINGS_AMAZONS3REGION
      value: "us-east-1"
    - name: MM_CLUSTERSETTINGS_ENABLE
      value: "true"
    - name: MM_CLUSTERSETTINGS_CLUSTERNAME
      value: "prod"
    - name: MM_METRICSSETTINGS_ENABLE
      value: "true"
```

### From Secrets / ConfigMaps (`valueFrom`)

Preferred for credentials and connection strings:

```yaml
spec:
  mattermostEnv:
    - name: MM_SQLSETTINGS_DATASOURCE
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: MM_SQLSETTINGS_DATASOURCE
    - name: MM_EMAILSETTINGS_SMTPPASSWORD
      valueFrom:
        secretKeyRef:
          name: smtp-credentials
          key: password
    - name: MM_FILESETTINGS_AMAZONS3ACCESSKEYID
      valueFrom:
        secretKeyRef:
          name: file-store-credentials
          key: accesskey
    - name: MM_FILESETTINGS_AMAZONS3SECRETACCESSKEY
      valueFrom:
        secretKeyRef:
          name: file-store-credentials
          key: secretkey
    - name: MM_LICENSE
      valueFrom:
        secretKeyRef:
          name: mattermost-license
          key: license
```

### Operator DB secret keys (external database)

External DB Secret (operator-managed injection) commonly uses:

| Secret key | Effect |
|------------|--------|
| `DB_CONNECTION_STRING` | Primary DSN (required) |
| `DB_CONNECTION_CHECK_URL` | Init-container readiness check URL (optional) |
| `MM_SQLSETTINGS_DATASOURCEREPLICAS` | Read-replica DSN list (optional) |

Example Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
stringData:
  DB_CONNECTION_STRING: "postgres://mmuser:SECRET@db.example.com:5432/mattermost?sslmode=require&connect_timeout=10"
  MM_SQLSETTINGS_DATASOURCEREPLICAS: "postgres://mmuser:SECRET@db-ro.example.com:5432/mattermost?sslmode=require"
```

URL-encode special characters in passwords (`@`, `/`, `#`, etc.) or the DSN parses wrong.

### File-store Secret keys

| Secret key | Maps to |
|------------|---------|
| `accesskey` | S3 access key (operator wires into file settings) |
| `secretkey` | S3 secret key |

Still set region/bucket/SSL/SSE via `mattermostEnv` as shown above.

### Plugin JSON via CRD env

```yaml
mattermostEnv:
  - name: MM_PLUGINSETTINGS_PLUGINSTATES
    value: '{"com.mattermost.calls":{"Enable":true},"com.mattermost.nps":{"Enable":true}}'
  - name: MM_PLUGINSETTINGS_ENABLEUPLOADS
    value: "false"
```

### Helm chart equivalent

Team-edition / operator charts usually expose the same list under values, e.g.:

```yaml
mattermostApp:
  extraEnv:
    - name: MM_SERVICESETTINGS_SITEURL
      value: "https://chat.example.com"
```

(Exact key name varies by chart — `extraEnv`, `env`, or `mattermostEnv`. Prefer matching the chart's values schema; semantics are identical: inject `MM_*` into the app container.)

### docker-compose / systemd

```yaml
environment:
  MM_SERVICESETTINGS_SITEURL: "https://chat.example.com"
  MM_SQLSETTINGS_DRIVERNAME: "postgres"
  MM_SQLSETTINGS_DATASOURCE: "postgres://..."
```

```ini
[Service]
Environment=MM_SERVICESETTINGS_SITEURL=https://chat.example.com
EnvironmentFile=/etc/mattermost/mm.env
```

---

## Catalog by config section

Not every leaf is listed (hundreds exist). Use the naming rule for anything missing. Below: ops-critical and commonly CRD-set vars.

### ServiceSettings — web / sessions / security

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_SERVICESETTINGS_SITEURL` | `SiteURL` | Required in prod |
| `MM_SERVICESETTINGS_LISTENADDRESS` | `ListenAddress` | Default `:8065` |
| `MM_SERVICESETTINGS_CONNECTIONSECURITY` | `ConnectionSecurity` | `""` or `TLS` |
| `MM_SERVICESETTINGS_TLSCERTFILE` | `TLSCertFile` | |
| `MM_SERVICESETTINGS_TLSKEYFILE` | `TLSKeyFile` | |
| `MM_SERVICESETTINGS_USELETSENCRYPT` | `UseLetsEncrypt` | |
| `MM_SERVICESETTINGS_FORWARD80TO443` | `Forward80To443` | Usually `false` behind LB |
| `MM_SERVICESETTINGS_READTIMEOUT` | `ReadTimeout` | seconds |
| `MM_SERVICESETTINGS_WRITETIMEOUT` | `WriteTimeout` | |
| `MM_SERVICESETTINGS_IDLETIMEOUT` | `IdleTimeout` | |
| `MM_SERVICESETTINGS_WEBSERVERMODE` | `WebserverMode` | `gzip` / `uncompressed` / `disabled` |
| `MM_SERVICESETTINGS_ENABLECHANNELVIEWEDMESSAGES` | `EnableChannelViewedMessages` | |
| `MM_SERVICESETTINGS_ENABLEINSECUREOUTGOINGCONNECTIONS` | `EnableInsecureOutgoingConnections` | Keep `false` in prod |
| `MM_SERVICESETTINGS_ENABLEHARDENEDMODE` | `EnableHardenedMode` | |
| `MM_SERVICESETTINGS_ALLOWEDUNTRUSTEDINTERNALCONNECTIONS` | `AllowedUntrustedInternalConnections` | Do not set `*` |
| `MM_SERVICESETTINGS_TRUSTEDPROXYIPHEADER` | `TrustedProxyIPHeader` | JSON array |
| `MM_SERVICESETTINGS_WEBSOCKETURL` | `WebsocketURL` | |
| `MM_SERVICESETTINGS_LICENSEFILELOCATION` | `LicenseFileLocation` | Prefer `MM_LICENSE` / `licenseSecret` |
| `MM_SERVICESETTINGS_TLSMINVER` | `TLSMinVer` | Default `1.2` |
| `MM_SERVICESETTINGS_TLSSTRICTTRANSPORT` | `TLSStrictTransport` | |
| `MM_SERVICESETTINGS_TLSSTRICTTRANSPORTMAXAGE` | `TLSStrictTransportMaxAge` | |
| `MM_SERVICESETTINGS_TLSOVERWRITECIPHERS` | `TLSOverwriteCiphers` | JSON array |
| `MM_SERVICESETTINGS_ALLOWCOOKIESFORSUBDOMAINS` | `AllowCookiesForSubdomains` | |
| `MM_SERVICESETTINGS_MAXIMUMPAYLOADSIZEBYTES` | `MaximumPayloadSizeBytes` | |
| `MM_SERVICESETTINGS_MAXIMUMURLLENGTH` | `MaximumURLLength` | |
| `MM_SERVICESETTINGS_GOROUTINEHEALTHTHRESHOLD` | `GoroutineHealthThreshold` | |
| `MM_SERVICESETTINGS_CLUSTERLOGTIMEOUTMILLISECONDS` | `ClusterLogTimeoutMilliseconds` | |
| `MM_SERVICESETTINGS_ENABLELOCALMODE` | `EnableLocalMode` | mmctl `--local` |
| `MM_SERVICESETTINGS_LOCALMODESOCKETLOCATION` | `LocalModeSocketLocation` | |
| `MM_SERVICESETTINGS_ENABLEDEVELOPER` | `EnableDeveloper` | Dev only |
| `MM_SERVICESETTINGS_ENABLETESTING` | `EnableTesting` | Dev only |
| `MM_SERVICESETTINGS_ENABLESECURITYFIXALERT` | `EnableSecurityFixAlert` | |
| `MM_SERVICESETTINGS_ENABLEEMAILINVITATIONS` | `EnableEmailInvitations` | |
| `MM_SERVICESETTINGS_ENABLEMULTIFACTORAUTHENTICATION` | `EnableMultifactorAuthentication` | |
| `MM_SERVICESETTINGS_ENFORCEMULTIFACTORAUTHENTICATION` | `EnforceMultifactorAuthentication` | |
| `MM_SERVICESETTINGS_MAXIMUMLOGINATTEMPTS` | `MaximumLoginAttempts` | |
| `MM_SERVICESETTINGS_SESSIONLENGTHWEBINDAYS` | `SessionLengthWebInDays` | (or InHours on newer) |
| `MM_SERVICESETTINGS_SESSIONLENGTHMOBILEINDAYS` | `SessionLengthMobileInDays` | |
| `MM_SERVICESETTINGS_SESSIONLENGTHSSOINDAYS` | `SessionLengthSSOInDays` | |
| `MM_SERVICESETTINGS_SESSIONCACHEINMINUTES` | `SessionCacheInMinutes` | |
| `MM_SERVICESETTINGS_SESSIONIDLETIMEOUTINMINUTES` | `SessionIdleTimeoutInMinutes` | |
| `MM_SERVICESETTINGS_ENABLEUSERACCESSTOKENS` | `EnableUserAccessTokens` | PATs |
| `MM_SERVICESETTINGS_ENABLEBOTACCOUNTCREATION` | `EnableBotAccountCreation` | |
| `MM_SERVICESETTINGS_ENABLEOAUTHSERVICEPROVIDER` | `EnableOAuthServiceProvider` | |
| `MM_SERVICESETTINGS_ENABLEINCOMINGWEBHOOKS` | `EnableIncomingWebhooks` | |
| `MM_SERVICESETTINGS_ENABLEOUTGOINGWEBHOOKS` | `EnableOutgoingWebhooks` | |
| `MM_SERVICESETTINGS_ENABLECOMMANDS` | `EnableCommands` | |
| `MM_SERVICESETTINGS_ENABLEPOSTUSERNAMEOVERRIDE` | `EnablePostUsernameOverride` | |
| `MM_SERVICESETTINGS_ENABLEPOSTICONOVERRIDE` | `EnablePostIconOverride` | |
| `MM_SERVICESETTINGS_ENABLECUSTOMEMOJI` | `EnableCustomEmoji` | |
| `MM_SERVICESETTINGS_ENABLELINKPREVIEWS` | `EnableLinkPreviews` | |
| `MM_SERVICESETTINGS_ENABLESVGCROSSORIGINCROSSORIGIN` | (if present) | Check version |
| `MM_SERVICESETTINGS_ALLOWCORSFROM` | `AllowCorsFrom` | |
| `MM_SERVICESETTINGS_CORSALLOWEDORIGINS` | (alias/version-dependent) | Prefer docs for version |
| `MM_SERVICESETTINGS_ENABLETUTORIAL` | `EnableTutorial` | |
| `MM_SERVICESETTINGS_ENABLEONBOARDINGFLOW` | `EnableOnboardingFlow` | |
| `MM_SERVICESETTINGS_ENABLEDESKTOPLANDINGPAGE` | `EnableDesktopLandingPage` | |
| `MM_SERVICESETTINGS_MINIMUMDESKTOPAPPVERSION` | `MinimumDesktopAppVersion` | |
| `MM_SERVICESETTINGS_MANAGEDRESOURCEPATHS` | `ManagedResourcePaths` | |

### SqlSettings — database

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_SQLSETTINGS_DRIVERNAME` | `DriverName` | Use `postgres` for new installs |
| `MM_SQLSETTINGS_DATASOURCE` | `DataSource` | Primary DSN |
| `MM_SQLSETTINGS_DATASOURCEREPLICAS` | `DataSourceReplicas` | Read replicas |
| `MM_SQLSETTINGS_DATASOURCESEARCHREPLICAS` | `DataSourceSearchReplicas` | Search replicas |
| `MM_SQLSETTINGS_MAXOPENCONNS` | `MaxOpenConns` | Per node; watch RDS limits |
| `MM_SQLSETTINGS_MAXIDLECONNS` | `MaxIdleConns` | ~½ of MaxOpenConns |
| `MM_SQLSETTINGS_CONNMAXLIFETIMEMILLISECONDS` | `ConnMaxLifetimeMilliseconds` | |
| `MM_SQLSETTINGS_CONNMAXIDLETIMEMILLISECONDS` | `ConnMaxIdleTimeMilliseconds` | |
| `MM_SQLSETTINGS_QUERYTIMEOUT` | `QueryTimeout` | seconds |
| `MM_SQLSETTINGS_TRACE` | `Trace` | Log SQL — leave `false` |
| `MM_SQLSETTINGS_DISABLEDATABASESEARCH` | `DisableDatabaseSearch` | When ES handles search |
| `MM_SQLSETTINGS_MINIMUMHASHTAGLENGTH` | `MinimumHashtagLength` | |
| `MM_SQLSETTINGS_ATRESTENCRYPTKEY` | `AtRestEncryptKey` | Don't rotate casually |

### FileSettings — local / S3

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_FILESETTINGS_DRIVERNAME` | `DriverName` | `local` or `amazons3` |
| `MM_FILESETTINGS_DIRECTORY` | `Directory` | Local path |
| `MM_FILESETTINGS_MAXFILESIZE` | `MaxFileSize` | Bytes |
| `MM_FILESETTINGS_ENABLEFILEATTACHMENTS` | `EnableFileAttachments` | |
| `MM_FILESETTINGS_ENABLEMOBILEUPLOAD` | `EnableMobileUpload` | |
| `MM_FILESETTINGS_ENABLEMOBILEDOWNLOAD` | `EnableMobileDownload` | |
| `MM_FILESETTINGS_EXTRACTCONTENT` | `ExtractContent` | Doc content search |
| `MM_FILESETTINGS_ARCHIVEDOWNLOAD` | (version-dependent) | |
| `MM_FILESETTINGS_AMAZONS3BUCKET` | `AmazonS3Bucket` | |
| `MM_FILESETTINGS_AMAZONS3REGION` | `AmazonS3Region` | |
| `MM_FILESETTINGS_AMAZONS3ACCESSKEYID` | `AmazonS3AccessKeyId` | Prefer IRSA / secret |
| `MM_FILESETTINGS_AMAZONS3SECRETACCESSKEY` | `AmazonS3SecretAccessKey` | |
| `MM_FILESETTINGS_AMAZONS3ENDPOINT` | `AmazonS3Endpoint` | MinIO / custom |
| `MM_FILESETTINGS_AMAZONS3SSL` | `AmazonS3SSL` | Set `true` |
| `MM_FILESETTINGS_AMAZONS3SSE` | `AmazonS3SSE` | Set `true` on AWS |
| `MM_FILESETTINGS_AMAZONS3SIGNV2` | `AmazonS3SignV2` | Legacy; usually false |
| `MM_FILESETTINGS_AMAZONS3PATHPREFIX` | `AmazonS3PathPrefix` | |
| `MM_FILESETTINGS_AMAZONS3BUCKETENDPOINT` | `AmazonS3BucketEndpoint` | |
| `MM_FILESETTINGS_AMAZONS3LOCATIONCONSTRAINT` | `AmazonS3LocationConstraint` | |
| `MM_FILESETTINGS_AMAZONS3TRACE` | `AmazonS3Trace` | |

### EmailSettings — SMTP / mail

| Env | config.json |
|-----|-------------|
| `MM_EMAILSETTINGS_ENABLESIGNUPWITHEMAIL` | `EnableSignUpWithEmail` |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHEMAIL` | `EnableSignInWithEmail` |
| `MM_EMAILSETTINGS_ENABLESIGNINWITHUSERNAME` | `EnableSignInWithUsername` |
| `MM_EMAILSETTINGS_REQUIREEMAILVERIFICATION` | `RequireEmailVerification` |
| `MM_EMAILSETTINGS_FEEDBACKEMAIL` | `FeedbackEmail` |
| `MM_EMAILSETTINGS_FEEDBACKNAME` | `FeedbackName` |
| `MM_EMAILSETTINGS_REPLYTOADDRESS` | `ReplyToAddress` |
| `MM_EMAILSETTINGS_SMTPSERVER` | `SMTPServer` |
| `MM_EMAILSETTINGS_SMTPPORT` | `SMTPPort` |
| `MM_EMAILSETTINGS_ENABLESMTPAUTH` | `EnableSMTPAuth` |
| `MM_EMAILSETTINGS_SMTPUSERNAME` | `SMTPUsername` |
| `MM_EMAILSETTINGS_SMTPPASSWORD` | `SMTPPassword` |
| `MM_EMAILSETTINGS_CONNECTIONSECURITY` | `ConnectionSecurity` |
| `MM_EMAILSETTINGS_SKIPSERVERCERTIFICATEVERIFICATION` | `SkipServerCertificateVerification` |
| `MM_EMAILSETTINGS_SMTPSERVERTIMEOUT` | `SMTPServerTimeout` |
| `MM_EMAILSETTINGS_ENABLEEMAILBATCHING` | `EnableEmailBatching` |
| `MM_EMAILSETTINGS_EMAILBATCHINGBUFFERSIZE` | `EmailBatchingBufferSize` |
| `MM_EMAILSETTINGS_EMAILBATCHINGINTERVAL` | `EmailBatchingInterval` |
| `MM_EMAILSETTINGS_ENABLENOTIFICATIONPREVIEW` | (version-dependent) |
| `MM_EMAILSETTINGS_PUSHNOTIFICATIONCONTENTS` | `PushNotificationContents` |
| `MM_EMAILSETTINGS_PUSHNOTIFICATIONSERVER` | `PushNotificationServer` |
| `MM_EMAILSETTINGS_SENDPUSHNOTIFICATIONS` | `SendPushNotifications` |
| `MM_EMAILSETTINGS_ENABLESMTPAUTH` | `EnableSMTPAuth` |

### ClusterSettings — HA (Enterprise)

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_CLUSTERSETTINGS_ENABLE` | `Enable` | Requires license |
| `MM_CLUSTERSETTINGS_CLUSTERNAME` | `ClusterName` | |
| `MM_CLUSTERSETTINGS_OVERRIDEHOSTNAME` | `OverrideHostname` | Often pod IP in k8s |
| `MM_CLUSTERSETTINGS_USEIPADDRESS` | `UseIPAddress` | |
| `MM_CLUSTERSETTINGS_ENABLEEXPERIMENTALGOSSIP` | (legacy/version) | Prefer current gossip defaults |
| `MM_CLUSTERSETTINGS_READONLYCONFIG` | `ReadOnlyConfig` | `true` in HA + env-driven config |
| `MM_CLUSTERSETTINGS_GOSSIPPORT` | `GossipPort` | |
| `MM_CLUSTERSETTINGS_STREAMINGPORT` | `StreamingPort` | Older versions |

### MetricsSettings / LogSettings

| Env | config.json |
|-----|-------------|
| `MM_METRICSSETTINGS_ENABLE` | `Enable` |
| `MM_METRICSSETTINGS_BLOCKPROFILERATE` | `BlockProfileRate` |
| `MM_METRICSSETTINGS_LISTENADDRESS` | `ListenAddress` | Default `:8067` |
| `MM_LOGSETTINGS_ENABLECONSOLE` | `EnableConsole` |
| `MM_LOGSETTINGS_CONSOLELEVEL` | `ConsoleLevel` |
| `MM_LOGSETTINGS_CONSOLEJSON` | `ConsoleJson` |
| `MM_LOGSETTINGS_ENABLEFILE` | `EnableFile` |
| `MM_LOGSETTINGS_FILELEVEL` | `FileLevel` |
| `MM_LOGSETTINGS_FILEJSON` | `FileJson` |
| `MM_LOGSETTINGS_FILELOCATION` | `FileLocation` |
| `MM_LOGSETTINGS_ENABLEWEBHOOKDEBUGGING` | `EnableWebhookDebugging` |
| `MM_LOGSETTINGS_ENABLEDIAGNOSTICS` | `EnableDiagnostics` |
| `MM_LOGSETTINGS_MAXFIELDSIZE` | (version-dependent) |

### ElasticsearchSettings

| Env | config.json |
|-----|-------------|
| `MM_ELASTICSEARCHSETTINGS_BACKEND` | `Backend` |
| `MM_ELASTICSEARCHSETTINGS_CONNECTIONURL` | `ConnectionUrl` |
| `MM_ELASTICSEARCHSETTINGS_USERNAME` | `Username` |
| `MM_ELASTICSEARCHSETTINGS_PASSWORD` | `Password` |
| `MM_ELASTICSEARCHSETTINGS_ENABLEINDEXING` | `EnableIndexing` |
| `MM_ELASTICSEARCHSETTINGS_ENABLESEARCHING` | `EnableSearching` |
| `MM_ELASTICSEARCHSETTINGS_ENABLEAUTOCOMPLETE` | `EnableAutocomplete` |
| `MM_ELASTICSEARCHSETTINGS_SNIFF` | `Sniff` |
| `MM_ELASTICSEARCHSETTINGS_POSTINDEXREPLICAS` | `PostIndexReplicas` |
| `MM_ELASTICSEARCHSETTINGS_POSTINDEXSHARDS` | `PostIndexShards` |
| `MM_ELASTICSEARCHSETTINGS_AGGREGATESEARCHSPOSTS` | (version-dependent) |
| `MM_ELASTICSEARCHSETTINGS_REQUESTTIMEOUTSECONDS` | `RequestTimeoutSeconds` |
| `MM_ELASTICSEARCHSETTINGS_SKIPTLSVERIFICATION` | `SkipTLSVerification` |
| `MM_ELASTICSEARCHSETTINGS_TRACE` | `Trace` |

### PluginSettings

| Env | config.json | Notes |
|-----|-------------|-------|
| `MM_PLUGINSETTINGS_ENABLE` | `Enable` | |
| `MM_PLUGINSETTINGS_ENABLEUPLOADS` | `EnableUploads` | Often `false` in locked prod |
| `MM_PLUGINSETTINGS_ALLOWINSECUREDOWNLOADURL` | `AllowInsecureDownloadUrl` | |
| `MM_PLUGINSETTINGS_ENABLEHEALTHCHECK` | `EnableHealthCheck` | |
| `MM_PLUGINSETTINGS_DIRECTORY` | `Directory` | |
| `MM_PLUGINSETTINGS_CLIENTDIRECTORY` | `ClientDirectory` | |
| `MM_PLUGINSETTINGS_PLUGINS` | `Plugins` | JSON string |
| `MM_PLUGINSETTINGS_PLUGINSTATES` | `PluginStates` | JSON string |
| `MM_PLUGINSETTINGS_REQUIREPLUGINSIGNATURE` | `RequirePluginSignature` | |
| `MM_PLUGINSETTINGS_SIGNATUREPUBLICKEYFILES` | `SignaturePublicKeyFiles` | |

### RateLimitSettings

| Env | config.json |
|-----|-------------|
| `MM_RATELIMITSETTINGS_ENABLE` | `Enable` |
| `MM_RATELIMITSETTINGS_PERSEC` | `PerSec` |
| `MM_RATELIMITSETTINGS_MAXBURST` | `MaxBurst` |
| `MM_RATELIMITSETTINGS_MEMORYSTORESIZE` | `MemoryStoreSize` |
| `MM_RATELIMITSETTINGS_VARYBYREMOTEADDR` | `VaryByRemoteAddr` |
| `MM_RATELIMITSETTINGS_VARYBYUSER` | `VaryByUser` |
| `MM_RATELIMITSETTINGS_VARYBYHEADER` | `VaryByHeader` |

### TeamSettings / Localization / Theme / Support / NativeApp

| Env | config.json |
|-----|-------------|
| `MM_TEAMSETTINGS_SITENAME` | `SiteName` |
| `MM_TEAMSETTINGS_MAXUSERSPERTEAM` | `MaxUsersPerTeam` |
| `MM_TEAMSETTINGS_ENABLEUSERCREATION` | `EnableUserCreation` |
| `MM_TEAMSETTINGS_ENABLEOPENSERVER` | `EnableOpenServer` |
| `MM_TEAMSETTINGS_RESTRICTCREATIONTODOMAINS` | `RestrictCreationToDomains` |
| `MM_TEAMSETTINGS_ENABLECUSTOMBRAND` | `EnableCustomBrand` |
| `MM_TEAMSETTINGS_CUSTOMBRANDTEXT` | `CustomBrandText` |
| `MM_TEAMSETTINGS_CUSTOMDESCRIPTIONTEXT` | `CustomDescriptionText` |
| `MM_TEAMSETTINGS_MAXCHANNELSPERTEAM` | `MaxChannelsPerTeam` |
| `MM_TEAMSETTINGS_MAXNOTIFICATIONSPERCHANNEL` | `MaxNotificationsPerChannel` |
| `MM_TEAMSETTINGS_ENABLECONFIRMEDNOTIFICATIONS` | (version-dependent) |
| `MM_LOCALIZATIONSETTINGS_DEFAULTSERVERLOCALE` | `DefaultServerLocale` |
| `MM_LOCALIZATIONSETTINGS_DEFAULTCLIENTLOCALE` | `DefaultClientLocale` |
| `MM_LOCALIZATIONSETTINGS_AVAILABLELOCALES` | `AvailableLocales` |
| `MM_THEMESETTINGS_ENABLETHEMESELECTION` | `EnableThemeSelection` |
| `MM_THEMESETTINGS_ALLOWCUSTOMTHEMES` | `AllowCustomThemes` |
| `MM_THEMESETTINGS_ALLOWEDTHEMES` | `AllowedThemes` |
| `MM_THEMESETTINGS_DEFAULTTHEME` | `DefaultTheme` |
| `MM_SUPPORTSETTINGS_HELPLINK` | `HelpLink` |
| `MM_SUPPORTSETTINGS_TERMSOFSERVICELINK` | `TermsOfServiceLink` |
| `MM_SUPPORTSETTINGS_PRIVACYPOLICYLINK` | `PrivacyPolicyLink` |
| `MM_SUPPORTSETTINGS_ABOUTLINK` | `AboutLink` |
| `MM_SUPPORTSETTINGS_REPORTAPROBLEMLINK` | `ReportAProblemLink` |
| `MM_SUPPORTSETTINGS_ENABLEASKCOMMUNITYLINK` | `EnableAskCommunityLink` |
| `MM_NATIVEAPPSETTINGS_APPDOWNLOADLINK` | `AppDownloadLink` |
| `MM_NATIVEAPPSETTINGS_ANDROIDAPPDOWNLOADLINK` | `AndroidAppDownloadLink` |
| `MM_NATIVEAPPSETTINGS_IOSAPPDOWNLOADLINK` | `IosAppDownloadLink` |
| `MM_NATIVEAPPSETTINGS_MOBILEEXTERNALBROWSER` | `MobileExternalBrowser` |

### PasswordSettings / LdapSettings (auth — abbreviated)

Full LDAP + ABAC + RBAC/SSO playbooks: [identity-access.md](identity-access.md). Full SAML/OIDC `MM_*`: [auth-env.md](auth-env.md).

| Env | config.json |
|-----|-------------|
| `MM_PASSWORDSETTINGS_MINIMUMLENGTH` | `MinimumLength` |
| `MM_PASSWORDSETTINGS_LOWERCASE` | `Lowercase` |
| `MM_PASSWORDSETTINGS_NUMBER` | `Number` |
| `MM_PASSWORDSETTINGS_UPPERCASE` | `Uppercase` |
| `MM_PASSWORDSETTINGS_SYMBOL` | `Symbol` |
| `MM_LDAPSETTINGS_ENABLE` | `Enable` |
| `MM_LDAPSETTINGS_ENABLESYNC` | `EnableSync` |
| `MM_LDAPSETTINGS_LDAPSERVER` | `LdapServer` |
| `MM_LDAPSETTINGS_LDAPPORT` | `LdapPort` |
| `MM_LDAPSETTINGS_CONNECTIONSECURITY` | `ConnectionSecurity` |
| `MM_LDAPSETTINGS_BASEDN` | `BaseDN` |
| `MM_LDAPSETTINGS_BINDUSERNAME` | `BindUsername` |
| `MM_LDAPSETTINGS_BINDPASSWORD` | `BindPassword` |
| `MM_LDAPSETTINGS_USERFILTER` | `UserFilter` |
| `MM_LDAPSETTINGS_GROUPFILTER` | `GroupFilter` |
| `MM_LDAPSETTINGS_IDATTRIBUTE` | `IdAttribute` |
| `MM_LDAPSETTINGS_USERNAMEATTRIBUTE` | `UsernameAttribute` |
| `MM_LDAPSETTINGS_LOGINIDATTRIBUTE` | `LoginIdAttribute` |
| `MM_LDAPSETTINGS_EMAILATTRIBUTE` | `EmailAttribute` |
| `MM_LDAPSETTINGS_FIRSTNAMEATTRIBUTE` | `FirstNameAttribute` |
| `MM_LDAPSETTINGS_LASTNAMEATTRIBUTE` | `LastNameAttribute` |
| `MM_LDAPSETTINGS_NICKNAMEATTRIBUTE` | `NicknameAttribute` |
| `MM_LDAPSETTINGS_POSITIONATTRIBUTE` | `PositionAttribute` |
| `MM_LDAPSETTINGS_LOGINFIELDNAME` | `LoginFieldName` |
| `MM_LDAPSETTINGS_SKIPCERTIFICATEVERIFICATION` | `SkipCertificateVerification` |
| `MM_LDAPSETTINGS_MAXIMUMLOGINATTEMPTS` | `MaximumLoginAttempts` |
| `MM_LDAPSETTINGS_ENABLEADMINFILTER` | `EnableAdminFilter` |
| `MM_LDAPSETTINGS_ADMINFILTER` | `AdminFilter` |
| `MM_LDAPSETTINGS_GUESTFILTER` | `GuestFilter` |

### SAML / OIDC / OAuth — full lists

For the complete SAML, OpenID Connect, GitLab, Google, and Entra ID (`Office365Settings`) env catalogs, cert-mount patterns, and SSO-only login policy vars, see **[auth-env.md](auth-env.md)**.

### Full EKS + RDS + S3 Operator example

Ready-to-adapt CR + Secrets + HTTPRoute (Cilium Gateway, IRSA, `mattermostEnv`): **[examples/eks-rds-s3-mattermost.yaml](examples/eks-rds-s3-mattermost.yaml)**.

### Notification / Privacy / DataRetention / Compliance (common)

| Env | config.json |
|-----|-------------|
| `MM_PRIVACYSETTINGS_SHOWEMAILADDRESS` | `ShowEmailAddress` |
| `MM_PRIVACYSETTINGS_SHOWFULLNAME` | `ShowFullName` |
| `MM_DATARETENTIONSETTINGS_ENABLEMESSAGERETENTION` | `EnableMessageDeletion` / retention fields |
| `MM_DATARETENTIONSETTINGS_ENABLEFILERETENTION` | file retention fields |
| `MM_DATARETENTIONSETTINGS_MESSAGEDELETIONDAYS` | `MessageRetentionDays` |
| `MM_DATARETENTIONSETTINGS_FILEDELETIONDAYS` | `FileRetentionDays` |
| `MM_COMPLIANCESETTINGS_ENABLE` | `Enable` |
| `MM_COMPLIANCESETTINGS_DIRECTORY` | `Directory` |
| `MM_COMPLIANCESETTINGS_ENABLEDAILYBATCH` | `EnableDaily` |
| `MM_MESSAGEEXPORTSETTINGS_ENABLEEXPORT` | `EnableExport` |
| `MM_MESSAGEEXPORTSETTINGS_EXPORTFORMAT` | `ExportFormat` |
| `MM_MESSAGEEXPORTSETTINGS_DAILYRUNTIME` | `DailyRunTime` |

Exact field names shift slightly by version — verify against your server's `config.json` / docs for that release.

### AutoTranslationSettings

| Env | config.json |
|-----|-------------|
| `MM_AUTOTRANSLATIONSETTINGS_ENABLE` | `Enable` |
| `MM_AUTOTRANSLATIONSETTINGS_PROVIDER` | `Provider` |
| `MM_AUTOTRANSLATIONSETTINGS_LIBRETRANSLATE_URL` | `LibreTranslate.URL` |
| `MM_AUTOTRANSLATIONSETTINGS_LIBRETRANSLATE_APIKEY` | `LibreTranslate.APIKey` |

---

## Production CRD starter pack

Minimal env block most prod Operator installs want:

```yaml
mattermostEnv:
  - name: MM_SERVICESETTINGS_SITEURL
    value: "https://chat.example.com"
  - name: MM_SERVICESETTINGS_FORWARD80TO443
    value: "false"
  - name: MM_SERVICESETTINGS_ENABLEINSECUREOUTGOINGCONNECTIONS
    value: "false"
  - name: MM_SQLSETTINGS_DRIVERNAME
    value: "postgres"
  - name: MM_SQLSETTINGS_MAXOPENCONNS
    value: "100"
  - name: MM_SQLSETTINGS_MAXIDLECONNS
    value: "50"
  - name: MM_FILESETTINGS_AMAZONS3SSL
    value: "true"
  - name: MM_FILESETTINGS_AMAZONS3SSE
    value: "true"
  - name: MM_CLUSTERSETTINGS_ENABLE
    value: "true"
  - name: MM_CLUSTERSETTINGS_CLUSTERNAME
    value: "prod"
  - name: MM_CLUSTERSETTINGS_READONLYCONFIG
    value: "true"
  - name: MM_METRICSSETTINGS_ENABLE
    value: "true"
  - name: MM_LOGSETTINGS_CONSOLEJSON
    value: "true"
  - name: MM_PLUGINSETTINGS_ENABLEUPLOADS
    value: "false"
```

Secrets (DSN, SMTP password, S3 keys, license) via `valueFrom.secretKeyRef` — never plaintext in the CR if you can avoid it.

---

## Gotchas

- **Bools must be strings in k8s:** `value: "true"` not `value: true` (YAML bool can break some tooling; Operator accepts both but string is safer).
- **JSON env values need escaping** in YAML — use single-quoted JSON or a Secret.
- **Replica DSNs must be URL-encoded.**
- **Env-locked settings**: admins see them grayed out in System Console — expected.
- **`MM_LICENSE` is per-process** in HA — prefer `spec.licenseSecret` so every pod gets it.
- **Operator may already inject** DB/file-store vars from Secrets; duplicate `mattermostEnv` entries for the same key can override — check the rendered Deployment.
- **Version drift**: field renames happen between majors. When unsure, dump your running config (`mmctl config show` / `config.json`) and derive the env name from the live path.
- For exhaustive per-setting docs (defaults, UI path, restart requirement), use the Mattermost docs pages linked at the top — this file is the ops/CRD cheat sheet + derivation rule, not a mirror of every System Console help string.
