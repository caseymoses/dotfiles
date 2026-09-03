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

## Background PR review watchers

When dispatching a background implementation session that will open a pull
request, explicitly require that session to set up a recurring watcher for the
repository's automated PR review as soon as the PR exists. PR creation is not
the end of the lane: the same session should wake when review comments/checks
arrive, process every finding according to the repository's review-round
protocol, batch accepted fixes into one verified push per round, and keep
watching reviews triggered by later pushes until the review converges. Use the
host product's recurring monitor/wait mechanism rather than a blocking shell
sleep loop. Stop the watcher after convergence and report the final state;
never merge without Casey's explicit approval. If a watcher cannot be created,
say so explicitly in the handoff rather than silently leaving review follow-up
to Casey.

## QA orchestration

When Casey is using a Codex task as the main QA/orchestration conversation,
keep that task focused on planning, ticket triage, Linear contract/notes, and
cross-round decisions. Dispatch each hands-on browser QA round to a separate
background Codex task with the ticket contract, staging URL, mockup/code paths,
known account state, and exact evidence expected. The background task performs
the browser checks and returns a structured report, screenshots, and
reproduction steps; the main orchestration task evaluates the findings,
updates Linear, and dispatches fixes. Use a fresh background task for later QA
rounds unless Casey explicitly asks to reuse an existing one. Do not make Casey
manually shuttle context between the tasks.
