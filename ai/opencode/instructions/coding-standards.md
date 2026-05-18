# Master Wizard Coding Standards

Use these coding standards when editing or reviewing code.

## Before Writing Code

- Ask about requirements, constraints, environment, edge cases, and existing patterns before starting coding work.
- Exceptions: purely explanatory tasks, trivial one-line fixes with zero ambiguity, or explicit user instruction to proceed without asking.
- If an exception applies, state which exception applies before proceeding.

## General Engineering

- Prefer the smallest correct change.
- Match existing naming, structure, and patterns in the codebase.
- Write readable code over clever code.
- Break long functions into named helpers when one function does multiple things.
- Add comments only where they explain why a non-obvious decision exists.
- Flag potential bugs, edge cases, and gotchas the user did not ask about.

## Bash

- Quote variables: `"${VAR}"`, not `$VAR`.
- Structure real scripts with functions.
- Put magic values in named variables with comments explaining why the value exists.

## Python

- Use pinned dependencies in `requirements.txt`.
- Add type hints on every function.
- Use `logging` for real scripts and production tools.
- Catch specific exceptions only.
- Preserve tracebacks with `raise NewError(...) from e` at module boundaries.
- Keep entry points behind `if __name__ == "__main__":`.

## Terraform

- Put `depends_on` at the top of resource blocks.
- Prefer modules over monolithic stacks.
- Use `locals {}` for repeated expressions and tags.
- Prefer data sources over hardcoded values.
- Put module data sources in `data.tf`.
- Include human-friendly connection steps in `outputs.tf` for services, clusters, and databases.
- Comment non-obvious configuration values with why they exist.

## Helm

- Define resource requests and limits.
- Put tunable configuration in `values.yaml`.
- Use `_helpers.tpl` for reusable template logic.
- Expose replica counts, requests, limits, image tags, and other environment-specific values as chart values.
- Comment non-default values and conditional template branches when the reason is not obvious.

## Ansible

- Use roles and tasks, not monolithic playbooks.
- Keep secrets in Ansible Vault or encrypted var files only.
- Make tasks idempotent.
- Use role variable prefixes such as `rolename__varname`.
- Use handlers for service restarts and reloads.
- Prefer module-based tasks over `shell` or `command`.
