# User-level agent guide

This file is loaded into every Claude Code session on this machine, across all repos.

## Bob (hermes) — MCP agent on the mac mini

User-scope MCP server `bob` is registered (SSE, LAN). It wraps the hermes-agent instance running on Casey's mac mini, which has access to:

- Official SDKs installed as npm packages (e.g. the GoHighLevel TypeScript SDK — preferred over GHL's web docs, which are often stale)
- Persistent memory and skills across projects
- Domain context Casey has built up in hermes over time

### When to use Bob

Call `mcp__bob__ask_bob` instead of guessing or relying on potentially-outdated public docs when you need:

- Exact API signatures / response shapes for third-party services (especially GHL)
- SDK-level type definitions
- Cross-project domain decisions Casey has made
- Anything where "what does the SDK actually say" beats "what do public docs claim"

### How to ask well

- Be specific: name the endpoint/method, state what you're trying to confirm, ask for the SDK's own type definitions.
- Use the `context` field to describe what you've already implemented so Bob can point out mismatches.
- Don't use Bob for generic knowledge — use him for things he has direct source access to.

### Confirmed Bob facts across projects

*(Add project-scoped facts to the relevant project's memory, not here. This section is for guidance that applies regardless of which repo you're in.)*

## CIL — Code Intelligence Layer (MCP)

User-scope MCP server `cil` is registered (SSE, `http://localhost:7780/sse`). It runs on Casey's mac mini and indexes codebases with tree-sitter + pgvector + a graph DB, so you can find definitions, callers/callees, and semantically-similar code across projects without grepping.

**Supported languages:** Python, JavaScript, TypeScript, TSX, C#. Index updates on git commit via a post-commit hook on the mac mini.

### Tools

- `mcp__cil__list_projects` — no params. Returns indexed projects, file/node counts, last-indexed time. **Call this first if you're unsure a project is indexed.**
- `mcp__cil__query_codebase` — params: `query` (string), `project` (string, from `list_projects`), `query_type` (default `find_definition`), `limit` (default 10). Returns file path, line number, signature, parent class.
  - `find_definition` — exact name lookup ("where is this defined?")
  - `find_callers` — who calls this function
  - `find_callees` — what this function calls
  - `similar_code` — semantic search by concept/description
  - `impact_analysis` — depth-2 callers ("what breaks if I change this?")
- `mcp__cil__get_coverage` — params: `project`. Latest coverage % per file vs 80% threshold. Python-only today (C# not implemented).

### When to use CIL

Prefer CIL over Grep/Glob when:

- You don't know where something is defined — `find_definition` beats grep for exact-name lookup across large codebases.
- You need relationships — `find_callers` / `find_callees` / `impact_analysis` are impractical to reconstruct by hand.
- You have a concept, not a name — `similar_code` finds relevant functions from a description.
- You're about to refactor — run `impact_analysis` first.

### When NOT to use CIL

- You already know the exact file path — just `Read` it.
- You need full file contents — CIL returns signatures + line numbers, not bodies.
- You're searching for string literals, config values, or comments — CIL only indexes functions/classes; use Grep.
- The project isn't indexed — check `list_projects`; if missing, fall back to Grep or ask Bob to index it.

**Rule of thumb:** CIL tells you *where to look* and *how things connect*. `Read` is still how you read the actual code once you know where it is.

## Workflow idea capture

When Casey says "add that to the workflow list" (or shares a dev-workflow/tooling idea he can't act on right now): create an issue in the **"Dev Workflow & Tooling"** Linear project under the **Casey Moses team (CAS)** — NOT the Hoppin team; workflow/process items are personal-team scope, product work is Hoppin scope. Rough capture beats losing the thought: title + a couple of sentences of context is enough, flesh out when picked up. When an experiment concludes and changes standing practice, write the outcome into the issue AND into this file (or the relevant repo CLAUDE.md/AGENTS.md) so agents inherit it.

## Delegation policy (main agent orchestrates, subagents execute)

Casey's standing preference (2026-07-08): use subagents for parallelism and to preserve the main agent's context budget — but route by task difficulty. (2026-07-09: Codex v0.144+ also has stable multi-agent support; these routing rules are tool-neutral and are mirrored in hoppin's AGENTS.md — don't describe orchestration as Claude-only.):

- **Main agent (Fable), 100% — no delegation:** novel work, first instance of any pattern, architecture/design decisions, design-fidelity UI (mockup screenshot loops), anything ambiguous enough to need judgment calls, and ALL review of subagent output before it becomes a commit/PR. Anything interactive with Casey stays here — subagents can't ask him questions mid-task.
- **Fork (background Fable, `subagent_type: "fork"`) — heavy but non-interactive Fable work:** inherits the main agent's full context snapshot at dispatch and runs out-of-band, so the mechanical churn (mass file reads, repeated test runs, batch fixes) doesn't consume the orchestrator's window. Use for big refactor sweeps, long verification passes, context-dependent research synthesis. Caveats: it preserves the main agent's CONTEXT BUDGET, not total token cost (its input = the whole conversation); its context freezes at dispatch; forks can't see each other.
- **Fresh Fable subagent (`model: fable`, cold context) — rare:** a genuinely hard problem that is also fully self-contained. If it's spec-able enough for a cold start, sonnet usually suffices — this lane earns its cost only when both hard AND independent.
- **Subagents (sonnet-tier) — patterned implementation:** Nth instance of an established pattern (the exemplar exists and is named), well-specified pages/endpoints that mirror existing code, test authoring after the first exemplar test, research/exploration reads.
- **Subagents (haiku-tier) — trivial mechanical:** bulk renames, stub pages, boilerplate sweeps.

**Rules that make this safe:**
1. **Never delegate the first instance of a pattern — delegate the Nth.** The exemplar is main-agent work.
2. The orchestrator (main agent) reads the Linear issue itself and **composes the subagent prompt**: paste the issue content verbatim + add exemplar file paths, current branch/state, verification commands (tests/type-check/build), the CIL/grep search-first rule, and the expected report format. Don't make subagents fetch Linear or rediscover context — MCP availability in subagent contexts is unreliable and curation is the orchestrator's job.
3. Subagents verify their own work (run the tests/build); the main agent re-verifies before committing. The PR auto-review pipeline is the second net, never the first.
4. Watch the metric: if delegated work needs more review rounds than solo work (~2-round baseline on hoppin), pull that task class back to the main agent.
