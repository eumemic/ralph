# Prompt Anatomy

This document explains the structure and language patterns used in Ralph's prompts.

## Prompt Structure

Both planning and building prompts follow a similar structure:

### Phase 0: Orientation (0a, 0b, 0c, ...)

Load context before doing work:

```
0a. Study `${SPECS_DIR}/*` with up to 500 parallel subagents...
0b. Study `${PLAN_FILE}`...
0c. For reference, the application source code is in the project root.
```

The agent orients itself to:
- What should be built (specs)
- What's planned (implementation plan)
- What exists (source code)

### Phases 1-4: Main Instructions

The core work of the iteration:

**Planning mode:**
1. Gap analysis (specs vs code)
2. Generate/update implementation plan
3. No implementation

**Building mode:**
1. Choose ONE task (highest priority)
2. Implement with validation
3. Update plan with findings
4. Commit when tests pass

### Guardrails (99999... numbering)

Higher numbers = more critical. This unusual numbering ensures guardrails sort to the end and signal priority:

```
99999. Important: When authoring documentation, capture the why...
999999. Important: Single sources of truth, no migrations/adapters...
9999999. Keep the plan current with learnings...
...
999999999999. If you find inconsistencies in specs, update them...
```

The escalating 9s create visual hierarchy and (possibly) influence model attention.

## Key Language Patterns

These specific phrases have been discovered to work effectively:

### "Study" (not "read" or "look at")

```
Study `${SPECS_DIR}/*` with up to 500 parallel subagents...
```

"Study" implies deeper comprehension than "read".

### "Don't assume not implemented"

```
Before making changes, search the codebase (don't assume not implemented)...
```

This is critical - prevents agents from reimplementing existing functionality. Forces investigation before creation.

### "Using parallel subagents" / "Up to N subagents"

```
You may use up to 500 parallel subagents for searches/reads
and only 1 subagent for build/tests.
```

Explicit subagent limits:
- High parallelism for read operations (cheap, fast)
- Single threading for mutations (backpressure)

### "Ultrathink"

```
Use an Opus subagent to analyze findings, prioritize tasks... Ultrathink.
```

Triggers extended thinking mode for complex reasoning.

### "Capture the why"

```
Important: When authoring documentation, capture the why — tests and implementation importance.
```

Don't just document what, explain why it matters.

### "Keep it up to date"

```
Keep the plan current with learnings —
future work depends on this to avoid duplicating efforts.
```

The plan is living documentation, not a static checklist.

### "If functionality is missing then it's your job to add it"

```
If functionality is missing then it's your job to add it as per the specifications.
```

Agents should be self-sufficient, not blocked by missing pieces.

### "Resolve them or document them"

```
For any bugs you notice, resolve them or document them in the plan
```

Nothing gets ignored - either fix it now or ensure it's tracked.

## Planning Prompt Template

```markdown
0a. Study `${SPECS_DIR}/*` with up to 250 parallel subagents...
0b. Study `${PLAN_FILE}` (if present)...
0c. For reference, the application source code is in the project root.

1. Study the plan (if present; it may be incorrect) and use
   up to 500 subagents to study existing source code and
   compare it against specs. Analyze findings, prioritize tasks,
   and create/update the implementation plan...

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality
is missing; confirm with code search first.

ULTIMATE GOAL: Sync the codebase to match the specifications...
```

Key elements:
- Orientation before analysis
- Gap analysis with subagents
- Explicit "plan only" constraint
- Project goal for context

## Building Prompt Template

```markdown
0a. Study `${SPECS_DIR}/*` with up to 500 parallel subagents...
0b. Study `${PLAN_FILE}`.
0c. For reference, the application source code is in the project root.

1. Pick exactly ONE incomplete item from the plan. Announce your choice.
   Before making changes, search the codebase (don't assume not implemented)...

2. Each work item has a success criterion and test. Write the test FIRST,
   then implement until it passes...

3. When you discover issues, immediately update the plan...

4. YOU MUST COMMIT YOUR CHANGES. Run `git add -A && git commit`...

99999. Important: When authoring documentation, capture the why...
[more guardrails with escalating 9s]
```

Key elements:
- Same orientation pattern
- Single task selection (ONE means ONE)
- Investigation before implementation
- Test-first development
- Validation before commit
- Guardrails for quality

## Quality Gates

### Pre-commit as Backpressure

The agent tries to commit - if pre-commit hooks fail, the commit is rejected and the agent must fix issues.

### Review Before Commit

Before attempting commit:
1. Review the implementation for simplicity and correctness
2. Check for bugs, edge cases, and issues

This adds quality gates before the pre-commit hook.

### Operational Knowledge

When operational discoveries are made (how to run tests, build gotchas), document them in project files like README.md or DEVELOPMENT.md for future reference.

## Task Completion

When a task is complete:
1. Mark it as `- [x]` in the plan (keeps history)
2. Only delete items if they become irrelevant (e.g., superseded by spec changes)

The planning loop will re-detect any gaps if work was incomplete.
