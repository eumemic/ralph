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

When users discover problems with what Ralph built, or want to extend existing functionality, follow this diagnostic workflow.

### Step 1: Diagnose the Gap Type

Before jumping to solutions, determine what kind of gap exists:

**Option A: Implementation Gap**
The spec was correct, but the planners/builders failed to implement it correctly or at all.

Signs:
- Spec clearly describes the expected behavior
- Code doesn't match what the spec says
- Tests are missing or don't cover the spec's acceptance criteria
- Feature exists but has bugs that violate spec requirements

**Option B: Design Gap**
The spec was underspecified (planners filled in the blanks), the spec was wrong but faithfully implemented, or the user wants entirely new features.

Signs:
- Spec is vague or missing details that would have prevented the problem
- Implementation matches the spec, but the spec didn't capture what the user actually wanted
- User is describing behavior that isn't covered by any spec
- User says "I didn't think about..." or "I assumed it would..."

**How to diagnose:** Read the relevant spec(s) and compare to the problematic code/behavior. Ask:
- Does the spec clearly define the expected behavior?
- Does the code match what the spec says?
- Is the problem that the spec is wrong, or that the implementation is wrong?
- **Check the spec status** - is it READY? If it's still DRAFT, the loops never saw it. If it's COMPLETE, the loops skipped it.

### Step 2: Close Design Gaps (if applicable)

If you identified a design gap, the specs need work before implementation can proceed.

**For underspecified or wrong specs:**
1. Return to the three-phase spec process (Phase 1: discuss, Phase 2: interrogate, Phase 3: write)
2. Focus on the specific gap - you don't need to rewrite the whole spec
3. Update the existing spec file with corrections or additions
4. Be explicit about what changed and why
5. **Update status**: If spec was COMPLETE, change to READY. If major rework needed, change to DRAFT.

**For new features:**
1. Determine if this is a new topic (new spec file) or an extension of existing topic (update existing spec)
2. Follow the full three-phase process for new material
3. Write or update spec files accordingly
4. New specs start as DRAFT, existing specs being extended go to READY (or DRAFT if significant changes)

After closing design gaps, you now have an implementation gap (the specs describe something the code doesn't do yet). **Ensure the affected specs are in READY status** before proceeding.

### Step 3: Close Implementation Gaps

You have two options for closing implementation gaps:

**Option A: Targeted Fix (for small, well-defined gaps)**

Best when:
- The fix is localized (1-3 files)
- You understand exactly what needs to change
- The change is low-risk and straightforward

Process:
1. Deploy a subagent to investigate the specific gap
2. Have the subagent plan and implement the fix
3. Review their work before committing
4. Run relevant tests to validate

**Option B: Re-run Ralph Loops (for larger gaps or when unsure)**

Best when:
- Multiple related changes are needed
- You're not confident about the full scope
- The specs changed significantly
- You want the planning loop to discover related gaps

Process:
1. Run `ralph plan "scope string"` with a scope that targets the changed specs
   - Example: `ralph plan "user authentication"` after updating auth specs
   - The scope ensures the planner focuses on the relevant area
2. Review the generated/updated plan
3. Run `ralph build` to implement the planned tasks

### Step 4: Verify and Mark Complete

After implementation (whether targeted fix or ralph build):

1. Review the results with the user
2. Verify the feature works as specified
3. Ask user: "Are you satisfied with how [feature] works?"
4. If yes, mark the relevant READY specs as COMPLETE
5. If no, identify the gap (design or implementation) and repeat the process

**Only mark specs COMPLETE when the user explicitly confirms satisfaction.**

### Quick Reference: Gap Diagnosis

| Symptom | Likely Gap Type | Action |
|---------|----------------|--------|
| "It doesn't work like the spec says" | Implementation | Targeted fix or re-run build |
| "The spec didn't cover this case" | Design | Update spec, then implement |
| "I want to add a new feature" | Design | New/updated spec, then implement |
| "It works as specced but that's wrong" | Design | Fix spec, then re-implement |
| "Ralph built the wrong thing" | Check both | Read spec - if spec is right, implementation gap; if spec is wrong/vague, design gap |
| "Nothing happened when I ran plan/build" | Status issue | Check if specs are READY (not DRAFT or COMPLETE) |

### Common Status Problems

| Problem | Cause | Fix |
|---------|-------|-----|
| Loops don't see my spec | Status is DRAFT | Change to READY after user approves |
| Loops skip a spec I just modified | Status is COMPLETE | Change back to READY |
| Spec was modified but not re-implemented | Forgot to change COMPLETE → READY | Update status, re-run loops |
| New spec never got implemented | Left as DRAFT | Get user approval, change to READY |

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

- **`references/spec-writing.md`** - Detailed four-phase spec writing process
- **`references/methodology.md`** - Ralph principles, context optimization, subagent architecture
- **`references/prompt-anatomy.md`** - Prompt structure, guardrail numbering, language patterns

## Credits

- Original methodology: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Playbook synthesis: [Clayton Farr](https://github.com/ClaytonFarr/ralph-playbook)
