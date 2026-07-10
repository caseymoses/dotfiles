## CIL MCP

When working in or reasoning about indexed codebases, use the `mcp__cil__` tools as the first-pass navigation layer before doing broad raw file reads.

- Start with `mcp__cil__.list_projects` when the relevant indexed project is unclear.
- Use `mcp__cil__.query_codebase` for definitions, callers, callees, similar code, and impact analysis.
- Use `mcp__cil__.list_endpoints` when investigating HTTP routes, controller actions, or API behavior.
- Use `mcp__cil__.get_coverage` when test coverage context would help guide risk or verification.

The CIL MCP is backed by vector search plus a graph database built from Tree-sitter analysis of classes, methods, call relationships, endpoints, and related code structure. Prefer it for locating relevant code and relationships; then read specific files only after it has narrowed the search area or when direct file contents are needed.

## Linear conventions (Casey's workspace)

- **Product work** belongs to the product's team/project (e.g. Hoppin team, `HOP-*` issues, "Dashboard Portal" project). One issue = one branch = one PR; reference the ticket ID in commits/PR titles.
- **Dev-workflow / tooling ideas** belong to the **"Dev Workflow & Tooling" project under the Casey Moses team (`CAS-*`)** — never the product team. Rough capture beats losing the thought: title + two sentences of context is enough.
- Repo-specific workflow rules live in each repo's `AGENTS.md`/`CLAUDE.md` — read those before implementing; this file only carries cross-repo conventions.
