---
name: ralph
description: This skill should be used when the user asks to "write a spec", "create a spec", "define requirements", "use ralph", "ralph methodology", "autonomous development", "sync specs to code", "run the planning loop", "run the building loop", "fix what ralph built", "ralph built the wrong thing", "extend this feature", "the spec was wrong", "update the spec", or mentions the Ralph workflow for AI-assisted development.
---

# Ralph: Spec-to-Code Synchronization

**IMPORTANT: If user asks to "run the planning loop" or "run the building loop", just run `ralph plan` or `ralph build`. Do NOT try to act out the loop by reading specs and doing gap analysis yourself - that defeats the purpose of fresh context.**

Ralph is a methodology for autonomous AI development where humans write specs and the machine syncs code to match. The human stays in the problem space (defining what to build), while the machine handles the solution space (implementing it).

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/) with adaptations for Claude Code's plugin system.

## Core Concept

```
specs/ ──► [planning loop] ──► IMPLEMENTATION_PLAN.md ──► [building loop] ──► code
```

- **Human's job:** Write and refine specs (the "what")
- **Machine's job:** Gap analysis + implementation (the "how")

Specs are the source of truth. Code is the derived artifact.

## Architecture

### Project Structure

```
project-root/
├── specs/                         # Source of truth (prominent, version controlled)
│   ├── user-auth.md
│   └── data-export.md
├── .ralph/                        # Ralph configuration and generated files
│   ├── config.yaml                # Configuration (specs_dir, model overrides)
│   ├── AGENTS.md                  # Operational knowledge (build, test, patterns)
│   └── IMPLEMENTATION_PLAN.md     # Tasks + learnings (generated)
├── src/
└── ...
```

The `specs/` location can be customized via `.ralph/config.yaml`:

```yaml
specs_dir: ./docs/requirements  # Default: ./specs
```

### Two Loops

**Planning Loop** (`ralph plan`):
1. Reads specs/
2. Studies existing codebase
3. Performs gap analysis (spec vs implementation)
4. Generates/updates .ralph/IMPLEMENTATION_PLAN.md
5. No implementation, no commits

**Building Loop** (`ralph build`):
1. Reads specs + plan
2. Picks ONE task (highest priority)
3. Implements, tests, commits
4. Marks task complete in plan
5. Loop restarts with fresh context

Each iteration gets a fresh context window. The bash loop is intentionally dumb - it just keeps restarting the agent. Intelligence lives in the prompts and specs.

### Backpressure

Work is validated through:
- Pre-commit hooks (if configured)
- Tests encoding acceptance criteria
- Code review before commit

If validation fails, the agent fixes and retries. Bad work doesn't escape.

## Spec Status Lifecycle

Every spec has a status in its YAML frontmatter:

```yaml
---
status: DRAFT
---
```

### The Three Statuses

| Status | Meaning | Who Uses It |
|--------|---------|-------------|
| **DRAFT** | Work in progress | Ignored by planners and builders |
| **READY** | Ready to implement | Planners and builders work from these |
| **COMPLETE** | Done and verified | Ignored by planners and builders |

### Status Transitions

```
DRAFT ──► READY ──► COMPLETE
  ▲         │          │
  │         │          │
  └─────────┴──────────┘
      (design gaps found)
```

**You (the agent using this skill) manage these transitions, NOT the planning/building loops.**

### When to Transition

**DRAFT → READY:**
- User has reviewed and approved the spec
- All design questions are resolved
- Spec is complete enough for implementation

**READY → COMPLETE:**
- Implementation is done
- Tests pass
- User has verified the feature works as specified
- User explicitly confirms satisfaction

**READY/COMPLETE → DRAFT:**
- Major design gap discovered (spec needs significant rework)
- User wants to save work-in-progress changes

**COMPLETE → READY:**
- Design gap found in "complete" spec
- User wants feature extended or modified
- Bug discovered that indicates spec issue

### Important Rules

1. **You manage statuses** - Planning and building loops do NOT change spec statuses
2. **Ask before transitioning** - Confirm with user before marking READY or COMPLETE
3. **Default to DRAFT** - New specs start as DRAFT until user approves
4. **COMPLETE requires user sign-off** - Never mark COMPLETE without explicit user confirmation

## Spec Development

This is the human's primary activity. Collaborate with Claude to turn fuzzy ideas into clear specs.

**For the detailed four-phase process, see `references/spec-writing.md`.**

### Quick Summary

| Phase | Activity | Output |
|-------|----------|--------|
| 1. Freeform Discussion | Conversational exploration of the idea | Understanding of JTBD |
| 2. Structured Interrogation | Use AskUserQuestion to resolve all ambiguity | All decisions resolved |
| 3. Draft Spec | Write `specs/filename.md` with `status: DRAFT` | Spec file created |
| 4. User Approval | Get explicit sign-off, change to `status: READY` | Spec ready for implementation |

**Critical rules:**
- Do NOT write the spec file until Phase 3
- Use AskUserQuestion tool in Phase 2 (not prose questions)
- No "open questions" in specs - resolve everything first
- One topic per spec file (use the "and" test to check)

## Debugging & Extending

When users discover problems with what Ralph built, or want to extend existing functionality, follow the diagnostic workflow in **`references/debugging-and-extending-specs.md`**.

### Quick Summary

1. **Diagnose the gap type**: Implementation gap (spec right, code wrong) or Design gap (spec wrong/incomplete)
2. **Close design gaps**: Update specs, manage status transitions
3. **Close implementation gaps**: Targeted fix or re-run `ralph plan/build`
4. **Verify and mark complete**: Get user sign-off, mark specs COMPLETE

### Key Tables

**Gap Diagnosis:**
| Symptom | Gap Type | Action |
|---------|----------|--------|
| "Doesn't work like spec says" | Implementation | Fix code |
| "Spec didn't cover this" | Design | Update spec first |
| "Works as specced but wrong" | Design | Fix spec, re-implement |

**Status Problems:**
| Problem | Fix |
|---------|-----|
| Loops don't see my spec | Change DRAFT → READY |
| Loops skip modified spec | Change COMPLETE → READY |

## Operations

### Setup

Initialize Ralph in a project:

```bash
ralph init
```

Or use the `/ralph-init` command in Claude Code.

This creates:
- `specs/` directory with a template
- `.ralph/config.yaml` for configuration
- `.ralph/IMPLEMENTATION_PLAN.md` placeholder

### Running the Loops

The loops are **separate processes** run from the terminal, not something the current agent executes inline:

```bash
ralph plan              # Run planning loop until plan stabilizes
ralph plan 5            # Run planning loop, max 5 iterations
ralph build             # Run building loop until all tasks complete
ralph build 10          # Run building loop, max 10 iterations
ralph --help            # Show help
```

When the user asks to "run the planning loop" or "run the building loop", you can either:
- **Run it for them** in the background (`run_in_background: true`) - offer this option
- **Let them run it** manually in their terminal - some users prefer this

Ask which they prefer. Either way, **do NOT attempt to act out the loop yourself** by reading the prompts and doing gap analysis - that defeats the purpose of fresh context each iteration.

### Environment Variables

```bash
RALPH_MODEL=opus            # Main agent model (default: opus)
RALPH_SUBAGENT_MODEL=sonnet # Subagent model (default: sonnet)
```

### When to Run Planning

- No plan exists yet
- Specs have changed significantly
- Plan feels stale or doesn't match reality
- Confused about what's actually done

### When to Run Building

- Plan exists and looks correct
- Ready to implement

### When to Regenerate Plan

- Agent is going in circles (implementing wrong things, duplicating work)
- Too much clutter from completed items
- Trajectory feels wrong

**The plan is disposable.** Wrong plan? Delete it and run `ralph plan` again. Regeneration costs one planning loop - cheap compared to wasted building loops. Don't be precious about the plan; the specs are the source of truth.

### AGENTS.md: Operational Knowledge

The `.ralph/AGENTS.md` file is the "heart of the loop" - it's loaded every iteration and contains operational knowledge:

- **Build & run commands** - How to build and run the project
- **Validation commands** - Test, typecheck, lint commands
- **Operational patterns** - Gotchas, workarounds, project quirks
- **Codebase patterns** - Key abstractions, naming conventions

**Critical:** Keep AGENTS.md brief (~60 lines max). Status updates and progress belong in IMPLEMENTATION_PLAN.md. A bloated AGENTS.md pollutes every future iteration's context.

## Additional Resources

Reference files for detailed guidance:

- **`references/spec-writing.md`** - Four-phase spec writing process
- **`references/debugging-and-extending-specs.md`** - Gap diagnosis and resolution workflow
- **`references/methodology.md`** - Ralph principles, context optimization, subagent architecture
- **`references/prompt-anatomy.md`** - Prompt structure, guardrail numbering, language patterns

## Credits

- Original methodology: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Playbook synthesis: [Clayton Farr](https://github.com/ClaytonFarr/ralph-playbook)
