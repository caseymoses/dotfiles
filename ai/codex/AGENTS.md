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

## Automated dev pipeline (agent-dispatch) — how work is routed

Casey's main development path (from 2026-08-31) is the autonomous lane
pipeline on the mac mini: repo `caseymoses/agent-dispatch` (local
`~/Code/agent-dispatch`), sibling of `pr-review-service`. Interactive
sessions — Codex, Claude Code, Bob — are for **orchestration, small tasks, and
building out the pipeline itself**, not for implementing stories.

**Routing rule**

- **Story/feature work that has a Linear issue → the pipeline.** In-session,
  get the issue decision-complete (acceptance criteria, mockup path, dated
  DECISION blocks in the description, open questions answered), then move it
  to the team's **Ready** column or hand Casey the drag. Do NOT implement it
  in-session and do NOT spin up background implementation tasks for it — that
  duplicates the pipeline and races it on the same branch.
- **Small tasks → in-session:** quick fixes, doc/config edits, investigations,
  Linear grooming, questions. The "Background PR review watchers" rule below
  still applies to any small task that opens a PR from a session.
- **Harness build-out (agent-dispatch, pr-review-service, QA agent, deploy
  step) → in-session with Casey**; pipeline-improvement tasks are dogfooded
  through the pipeline wherever it can already handle them.

**What a Ready issue gets:** claim (→ Dev Planning) → worktree from fresh
`origin/main` → plan phase (plan posted as a Linear comment; product questions
park the issue with the `needs-input` label + Discord ping instead of
guessing; answer-and-re-drag re-dispatches) → dev phase in a herdr pane
(test-first, one ready PR; → In Progress, then Code Review at PR-open) →
automated review rounds fed back to the still-live lane (that repo's
review-round protocol, max 4) → consensus APPROVE = delivery digest on the
issue + In Review + Discord ping. Agents report only through `.dispatch/`
status files; the dispatcher never parses prose. **Merging stays human.** Not
built yet: QA phase (CAS-243), deploy/release-notes step (CAS-244), auto-merge
gate, local intermediate review rounds (CAS-240).

**Linear state map (who flips):** Ready (Casey) → Dev Planning / In Progress /
Code Review / In Review (dispatcher) → Ready for Deploy (GitHub merge
automation) → Done (Casey at prod deploy). A parked lane keeps its column;
`needs-input` is a label, not a state.

**Where it lives:** mini `~/.hermes/scripts/agent_dispatch/` (launchd
`com.casey.agent-dispatch`, 120s ticks), config
`~/.hermes/dispatch-config.json` (per-machine — models and autonomy flags live
here; deploy never clobbers it), lanes `~/.hermes/dispatch-state/lanes.json`,
log `~/.hermes/logs/agent-dispatch.log`, review artifacts
`~/.hermes/pr-reviews/<owner>__<repo>/pr-N/<sha12>/`. Configured for hoppin
only today (team HOP, one repo slug); onboarding another project is a config
entry plus that repo's own review-round protocol in its `AGENTS.md`.

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
