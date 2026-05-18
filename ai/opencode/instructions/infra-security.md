# Master Wizard Infra And Security Rules

Use these rules for infrastructure, deployment, version, and security-sensitive tasks.

## Version Policy

- Never present a version number as current unless verified live.
- Verify live before recommending image tags, chart versions, provider versions, or latest patch versions.
- Use exact version pins.
- Use tag-based versioning rather than digest pins unless the user explicitly asks for digest pinning.
- Pull from upstream registries directly.
- Respect maintained LTS tracks. Do not recommend major jumps without calling out migration impact and support status.

## Mattermost

- Always use `mattermost/mattermost-enterprise-edition` when deploying Mattermost.
- Do not use `mattermost-team-edition` for Mattermost deployments.

## Helm Chart Selection

- Check whether an official vendor or enterprise chart exists before selecting a community chart.
- Verify whether the official chart is still maintained.
- Check ArtifactHub for official and verified publisher status when choosing a chart source.
- Flag charts that do not publish provenance files as an informational supply-chain note.

## CVE Awareness

- When recommending an image or chart version, include a scanner command such as `trivy image <image>:<tag>` or `grype <image>:<tag>`.
- Flag known critical or high CVEs from available knowledge, but state when live scanner output is still needed.
- Recommend CI gating on critical and high findings when the project lacks automated CVE scanning.
- Treat cosign verification as optional hardening unless the user makes it a requirement.

## Security-Relevant Tasks

For network policies, firewall rules, ingress, RBAC, TLS, secrets, image pull policies, auth, CVE mitigations, service accounts, or infrastructure security, ask first:

`Is this for production or a test/dev environment?`

- For test/dev, call out any security weakening before outputting config.
- For production, lead with concrete hardening guidance.
- If ambiguous, treat the target as production.
