# Mattermost Deployment & Operations

**Default stack:** Mattermost **Operator** + **Enterprise Edition** image + external Postgres + S3 + Gateway API HTTPRoute. Do not propose Team Edition or the community TE Helm chart unless the user explicitly asks.

Covers Operator CR, Terraform/Helm (Operator install), Ansible, HA, upgrades, backups. Follow the user's workspace rules for each tool (modular Terraform, roles-based Ansible, quoted bash vars, Helm requests/limits always set).

## Topology at a glance

Minimum viable (Operator + Enterprise):
- Mattermost Operator in-cluster
- `Mattermost` CR with `image: mattermost/mattermost-enterprise-edition` + `licenseSecret`
- External Postgres 13+ (RDS, Cloud SQL, or self-hosted)
- External file store (S3 / compatible; IRSA preferred)
- HTTPRoute → shared Gateway (not nginx Ingress)

Production HA:
- 2+ Mattermost replicas via the CR (`replicas` / `size`) behind Gateway / LB (sticky sessions **not** required; websocket upgrades must pass through)
- Postgres primary + read replica
- Object storage (S3) — local disk breaks HA
- Elasticsearch/OpenSearch for message search at scale (optional below ~5M posts)
- Prometheus + Grafana for metrics (`/metrics` on port 8067 by default; Enterprise for full metric set)

Canonical example: [examples/eks-rds-s3-mattermost.yaml](examples/eks-rds-s3-mattermost.yaml).

## Operator deployment (default)

Install/upgrade the Operator (Helm or manifests from [`mattermost/mattermost-operator`](https://github.com/mattermost/mattermost-operator)), then apply a `Mattermost` CR:

```yaml
apiVersion: installation.mattermost.com/v1beta1
kind: Mattermost
metadata:
  name: mattermost
  namespace: mattermost
spec:
  image: mattermost/mattermost-enterprise-edition
  version: "10.5.0"   # pin explicitly
  replicas: 2
  licenseSecret: mattermost-license
  ingress:
    enabled: false    # HTTPRoute is the default edge path
  database:
    external:
      secret: mattermost-db
  fileStore:
    external:
      url: s3.amazonaws.com
      bucket: mattermost-prod-files
      useServiceAccount: true
  mattermostEnv:
    - name: MM_SERVICESETTINGS_SITEURL
      value: "https://chat.example.com"
    - name: MM_FILESETTINGS_AMAZONS3SSL
      value: "true"
    - name: MM_FILESETTINGS_AMAZONS3SSE
      value: "true"
    - name: MM_CLUSTERSETTINGS_ENABLE
      value: "true"
```

Always pair with a companion `HTTPRoute` (see Edge routing below) unless the user requests legacy Ingress.

### Driving Operator from Terraform

Prefer `kubernetes_manifest` / `kubectl_manifest` for the `Mattermost` CR, or Helm only for **installing the Operator** itself — not the TE app chart.

```hcl
resource "helm_release" "mattermost_operator" {
  depends_on = [kubernetes_namespace.mm]

  name       = "mattermost-operator"
  repository = "https://helm.mattermost.com"
  chart      = "mattermost-operator"   # Operator chart — not mattermost-team-edition
  version    = var.operator_chart_version
  namespace  = kubernetes_namespace.mm_operator.metadata[0].name
}

# App install = Mattermost CR (Enterprise image + licenseSecret), not TE Helm values
```

Per workspace rule: **always set requests + limits** on scheduling when overriding `size`, use `locals{}` tag maps, pass env-specific values through `tfvars`.

## Team Edition / community Helm (opt-in only)

Use **only** when the user explicitly asks for Team Edition or the community chart [`mattermost/mattermost-team-edition`](https://github.com/mattermost/mattermost-helm). Do not offer this as the default path.

<details>
<summary>Legacy TE Helm sketch (not default)</summary>

```yaml
image:
  repository: mattermost/mattermost-team-edition
  tag: "9.11.0"
replicaCount: 2
# ... externalDB + S3 as needed
```

```hcl
resource "helm_release" "mattermost" {
  chart = "mattermost-team-edition"  # TE only — not the default
  # ...
}
```

</details>

## Terraform module structure

Per workspace rules — modular, every module gets `variables.tf`, `outputs.tf`, `data.tf`. Tag maps in `locals{}`. `depends_on` at top of resource blocks.

```
modules/mattermost/
├── main.tf             # Resources
├── variables.tf        # Inputs
├── outputs.tf          # Connection steps for newcomers
├── data.tf             # All data sources here
├── locals.tf           # Tag map, computed values
├── values.yaml.tpl     # Helm values template
└── README.md
```

### `outputs.tf` — newcomer-friendly

Per workspace rule, outputs include real connection steps using interpolated values, not raw strings.

```hcl
output "connect_steps" {
  value = <<-EOT
    Mattermost deployed. To connect:

    1. Add to /etc/hosts (dev) or configure DNS (prod):
       ${aws_lb.mm.dns_name} ${var.site_hostname}

    2. Open: https://${var.site_hostname}

    3. First-run admin creation URL:
       https://${var.site_hostname}/signup_user_complete

    4. Shell into a pod for mmctl:
       kubectl -n ${kubernetes_namespace.mm.metadata[0].name} \
         exec -it deploy/mattermost -- mmctl --local system status

    5. Postgres connection (for debugging):
       psql "host=${aws_db_instance.mm.address} port=5432 dbname=mattermost user=mmuser sslmode=require"

    6. Tail logs:
       kubectl -n ${kubernetes_namespace.mm.metadata[0].name} \
         logs -f deploy/mattermost
  EOT
}
```

### Tag map pattern (`locals.tf`)

```hcl
locals {
  tags = merge(var.extra_tags, {
    Application = "mattermost"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner_team
    CostCenter  = var.cost_center
  })
}
```

Apply via `tags = local.tags` on every taggable resource.

## Ansible for VM-based installs

Roles-based structure (per workspace rule — no monolithic playbooks):

```
roles/
├── mattermost_server/
│   ├── tasks/main.yml
│   ├── handlers/main.yml
│   ├── templates/mattermost.service.j2
│   ├── templates/config.json.j2
│   └── defaults/main.yml
├── mattermost_db/
└── mattermost_proxy/
```

Secrets (DB password, S3 keys, token signing keys) go in **Ansible Vault**:

```bash
ansible-vault encrypt_string --vault-id prod@prompt \
  'super-secret-password' --name 'mm_db_password'
```

Never commit plaintext. Reference as `{{ mm_db_password }}` in templates.

### Example task — install + enable

```yaml
- name: Install Mattermost binary
  ansible.builtin.unarchive:
    src: "https://releases.mattermost.com/{{ mm_version }}/mattermost-{{ mm_version }}-linux-amd64.tar.gz"
    dest: /opt
    remote_src: true
    creates: "/opt/mattermost/bin/mattermost"
  notify: restart mattermost

- name: Render config.json
  ansible.builtin.template:
    src: config.json.j2
    dest: /opt/mattermost/config/config.json
    owner: mattermost
    group: mattermost
    mode: "0640"
  notify: restart mattermost

- name: Enable + start service
  ansible.builtin.systemd:
    name: mattermost
    enabled: true
    state: started
    daemon_reload: true
```

## Configuration — env vars preferred over `config.json`

For the full `MM_*` catalog, Operator CRD `spec.mattermostEnv` examples, Secret `valueFrom` patterns, and section tables, see [env.md](env.md).

- SAML / OIDC / Entra / Google / GitLab env catalogs → [auth-env.md](auth-env.md)
- Full EKS + RDS + S3 Operator CR (HTTPRoute + Cilium Gateway, IRSA) → [examples/eks-rds-s3-mattermost.yaml](examples/eks-rds-s3-mattermost.yaml)

## Edge routing (default: Gateway API HTTPRoute)

**Default for EKS / platform installs:** do **not** use nginx Ingress or `awsLoadBalancerController`.

**Operator status (local `mattermost-operator` on `master`):** the CRD still only has `spec.ingress` and `spec.awsLoadBalancerController`. There is **no** native `spec.httpRoute` field yet — platform installs disable Ingress and ship a companion `HTTPRoute` (see Mattermost IaC / BYOC). Prefer that pattern until Operator grows first-class HTTPRoute support.

1. Set `spec.ingress.enabled: false` on the Mattermost CR (Operator must not create an Ingress).
2. Attach a Gateway API `HTTPRoute` to the shared Gateway (typically `cilium-gateway` in `kube-system`, `sectionName: https`).
3. `backendRefs` point at the Operator-managed Service — same name as the Mattermost CR — port `8065`.
4. Namespace needs Gateway access (e.g. label `gateway-access: cilium-gateway`).
5. Gateway API CRDs must exist **before** the Cilium Gateway controller starts, or HTTPRoutes stay `PROGRAMMED: Unknown`.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: mattermost
  namespace: mattermost
spec:
  parentRefs:
    - name: cilium-gateway
      namespace: kube-system
      sectionName: https
  hostnames:
    - chat.example.com
  rules:
    - backendRefs:
        - name: mattermost   # Mattermost CR metadata.name
          port: 8065
```

**Legacy (avoid for new work):** nginx Ingress (`spec.ingress.enabled: true` + annotations) or `spec.awsLoadBalancerController`. Prefer HTTPRoute instead.

Any `config.json` setting can be set as `MM_<SECTION>_<KEY>` with dots replaced by underscores:

| Config path | Env var |
|-------------|---------|
| `ServiceSettings.SiteURL` | `MM_SERVICESETTINGS_SITEURL` |
| `SqlSettings.DataSource` | `MM_SQLSETTINGS_DATASOURCE` |
| `FileSettings.DriverName` | `MM_FILESETTINGS_DRIVERNAME` |
| `FileSettings.AmazonS3Bucket` | `MM_FILESETTINGS_AMAZONS3BUCKET` |
| `ClusterSettings.Enable` | `MM_CLUSTERSETTINGS_ENABLE` |
| `MetricsSettings.Enable` | `MM_METRICSSETTINGS_ENABLE` |

Env vars **override** `config.json` and take effect at process start. Changes in System Console don't persist for env-var-controlled settings (they show as read-only).

Show both forms in docs — ops teams prefer env vars for 12-factor, but the config file is still canonical for admins browsing System Console.

## High availability

Enable cluster mode:

```
MM_CLUSTERSETTINGS_ENABLE=true
MM_CLUSTERSETTINGS_CLUSTERNAME=prod
MM_CLUSTERSETTINGS_USEIPADDRESS=true
MM_CLUSTERSETTINGS_READONLYCONFIG=true
```

- **License required**: Cluster mode is an Enterprise feature.
- Nodes discover each other via gossip. In Kubernetes, use a headless service and set `MM_CLUSTERSETTINGS_OVERRIDEHOSTNAME` to the pod IP.
- Config must be read-only on nodes — manage via env vars or a shared file. `ReadOnlyConfig=true` prevents drift between nodes.
- Edge must support **websocket upgrades** (`/api/v4/websocket`). Cilium Gateway / Gateway API HTTPRoute handles this; legacy ALB/nginx also can if configured.

## Upgrades

Standard flow:

1. **Backup first**: `pg_dump` the DB, snapshot the S3 bucket (or verify versioning on).
2. **Read the [release notes](https://docs.mattermost.com/upgrade/release-notes.html)** — check for migrations, config changes, deprecations.
3. **Rolling restart** in HA: `kubectl rollout restart deploy/mattermost`. Workloads drain gracefully if `terminationGracePeriodSeconds >= 30`.
4. **DB migrations** run automatically on startup of the first upgraded node. Monitor logs for `Running migration` messages.
5. **Jump supported path**: You can upgrade across one ESR (Extended Support Release) at a time. Don't skip multiple majors.

Downgrades are **not supported** once DB migrations run. Restore from backup instead.

## Backups

Three things to back up:

| Component | How | Frequency |
|-----------|-----|-----------|
| Database | `pg_dump` or managed snapshots | At least daily; hourly for busy prod |
| File store | S3 versioning + lifecycle, or `rsync` for local disk | Continuous (versioning) |
| Config | Store `config.json` + env var manifests in git | On change |

Point-in-time recovery requires WAL archiving on Postgres. For RDS, enable automated backups + point-in-time restore.

## Monitoring

Prometheus endpoint on port **8067** (configurable). Full production metrics assume **Enterprise** (our default).

Key metrics to alert on:
- `mattermost_api_time_seconds` p95 — API latency
- `mattermost_db_store_time_seconds` p95 — DB latency
- `mattermost_http_errors_total` rate — 5xx rate
- `mattermost_cluster_cluster_requests_total` — inter-node chatter (HA only)
- `mattermost_websocket_connections` — active WS connections per node

Standard infra alerts also apply: pod restarts, Postgres connection pool exhaustion, S3 5xx, disk pressure.

## Common deployment gotchas

- **Postgres `max_connections`**: Mattermost opens up to `MaxOpenConns` (default 300) per node. HA with 4 nodes + leader election jobs can exhaust default RDS limits. Bump `max_connections` or lower `MaxOpenConns`.
- **S3 permissions**: Need `s3:GetObject`, `PutObject`, `DeleteObject`, `ListBucket`, `GetBucketLocation`. `AbortMultipartUpload` for large file uploads. Prefer IRSA / workload identity over access keys.
- **Websocket behind proxy**: Prefer Gateway API HTTPRoute → Cilium Gateway. If stuck on legacy nginx, set `proxy_http_version 1.1`, `Upgrade`, and `Connection` headers.
- **Email**: SMTP settings not auto-configured. Without SMTP, password reset and email verification break silently.
- **File size limits**: `MM_FILESETTINGS_MAXFILESIZE` default is 100MB. Raise Gateway / proxy body limits to match.
- **Push notifications**: Mobile push requires the Mattermost Push Proxy or a self-hosted equivalent. Self-hosted servers can't push directly to APNS/FCM.
- **Session timeouts**: Default is 30 days mobile, 30 days web. SSO users get kicked back to IdP on expiry — tune `MM_SERVICESETTINGS_SESSIONLENGTHWEBINHOURS`.

## Security checklist (non-trivial, flag on review)

- [ ] `MM_SERVICESETTINGS_SITEURL` set — many security headers depend on it
- [ ] TLS terminated at LB with modern cipher suites
- [ ] `MM_SERVICESETTINGS_ENABLEINSECUREOUTGOINGCONNECTIONS=false`
- [ ] `MM_SERVICESETTINGS_ALLOWEDUNTRUSTEDINTERNALCONNECTIONS` restricted (not `*`)
- [ ] Admin accounts use SSO + MFA, not local passwords
- [ ] Personal access tokens disabled unless integrations need them
- [ ] File store bucket has public access blocked, versioning on
- [ ] DB in private subnet, security group restricts to app subnets only
- [ ] Secrets in a secret manager (AWS Secrets Manager, Vault), not env files in git
- [ ] Prometheus `/metrics` endpoint not exposed to the public internet
