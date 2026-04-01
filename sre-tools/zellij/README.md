# Zellij Templates for SRE Tools

This directory contains Zellij layout templates for common SRE monitoring and debugging tasks.

## Available Templates

### 1. K9s Deployment Watch (`k9s-deployment-watch.kdl`)
A comprehensive layout with multiple K9s instances and kubectl watches for monitoring Kubernetes deployments.

**Features:**
- 3 K9s panes for interactive navigation
- Watch pods across all namespaces
- Watch deployments, services, and nodes
- Real-time event monitoring

**Usage:**
```bash
zellij_k9s_watch
```

### 2. Kubectl Checks (`kubectl-checks.kdl`)
A detailed monitoring layout focused on a specific namespace with resource usage tracking.

**Features:**
- Pod and deployment status in target namespace
- Resource usage monitoring (pods and nodes)
- Event watching
- ConfigMaps, Secrets, PVCs, and Ingress monitoring

**Usage:**
```bash
# Interactive prompt for namespace
zellij_kubectl_checks

# Specify namespace directly
zellij_kubectl_checks my-namespace
```

### 3. Custom Mattermost Watch (`watch-mattermost-deployments.kdl`)
Custom layout for Mattermost-specific deployment monitoring.

**Usage:**
```bash
zellij_custom_watch
```

## Template Structure

All templates follow the Zellij KDL (KDL Document Language) format with:
- Split panes (horizontal/vertical)
- Command execution with arguments
- Tab templates with status bars

## Creating Your Own Templates

```bash
# Create a new template
create_zellij_template my-custom-template

# List all available templates
list_zellij_templates
```

## Available Functions

- `zellij_k9s_watch` - Launch K9s deployment watch layout
- `zellij_kubectl_checks` - Launch kubectl checks layout
- `zellij_custom_watch` - Launch custom Mattermost watch layout
- `list_zellij_templates` - List all available templates
- `create_zellij_template` - Create a new template

## Dependencies

- [Zellij](https://zellij.dev) - Terminal workspace manager
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [k9s](https://k9scli.io/) - Kubernetes CLI management tool (optional)

## Installation

Zellij functions are sourced automatically when using the main SRE tools setup.

For more information on Zellij layouts, visit: https://zellij.dev/documentation/
