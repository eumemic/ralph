# Ralph Methodology Deep Dive

This document covers the principles and mechanics behind the Ralph pattern for autonomous AI development.

## Context Is Everything

When working with LLMs, context window management is the primary architectural driver. Every design decision in Ralph flows from this constraint:

### Why Context Matters

- **200K tokens advertised ≈ 176K truly usable** (system prompts, tool definitions consume the rest)
- **40-60% context utilization = "smart zone"** where the model performs best
- Above 60%: quality degrades, hallucinations increase, instructions get ignored
- Below 40%: wasted capacity, could be doing more per iteration

**The insight:** Tight tasks + 1 task per loop = 100% smart zone utilization every time.

### Fresh Context Per Iteration

Each loop iteration starts a completely new Claude process. This is *intentional*:

- **No context debt** - mistakes and confusion don't accumulate
- **Consistent starting point** - same files loaded every time (specs, plan, AGENTS.md)
- **Deterministic setup** - despite non-deterministic outputs, the input is identical
- **Natural checkpoints** - each commit is a clean break point

The bash loop is deliberately dumb (`while true; do claude -p < PROMPT.md; done`). Intelligence lives in the prompts and specs, not the loop mechanism.

### This Drives the Entire Architecture

### Main Agent as Scheduler

Don't allocate expensive work to the main context. Use subagents for heavy lifting:

- **Up to 500 parallel subagents** for search/read operations
- **Only 1 subagent** for build/tests (creates backpressure)
- **Opus subagents** for complex reasoning (debugging, architectural decisions)

### Subagents as Memory Extension

Each subagent gets ~156KB that's garbage collected when done. Fan out to avoid polluting the main context with search results and intermediate work.

### Simplicity Wins

- Fewer parts in the system
- Terse prompt content
- Verbose inputs degrade determinism
- Prefer Markdown over JSON for token efficiency

## Steering Ralph

Create signals and gates to guide successful output. Steer from two directions:

### Steer Upstream (Patterns)

**Deterministic setup:**
- First ~5,000 tokens reserved for specs
- Every loop iteration loads identical files (prompts + any operational context)
- Model starts from known state despite non-deterministic outputs

**Code as guidance:**
- Existing code shapes what gets generated
- If Ralph generates wrong patterns, add utilities and patterns to steer it right
- The codebase itself is a form of prompt

### Steer Downstream (Backpressure)

**Programmatic validation:**
- Tests, typechecks, lints, builds
- Reject invalid/unacceptable work automatically
- Pre-commit hooks as the gate

**Subjective validation:**
- Some criteria resist programmatic checks (creative quality, UX feel)
- LLM-as-judge can provide backpressure for subjective criteria
- Binary pass/fail reviews that iterate until passing

### AGENTS.md: The Heart of the Loop

The `.ralph/AGENTS.md` file is loaded every iteration and serves as the operational "cheat sheet" for the building agent. It should contain:

- **Build commands** - How to build/run the project
- **Validation commands** - Test, typecheck, lint commands
- **Operational patterns** - Gotchas, workarounds, project-specific knowledge
- **Codebase patterns** - Key abstractions, naming conventions, architectural decisions

**Critical constraints:**

- **Keep it brief (~60 lines max)** - A bloated AGENTS.md pollutes every future iteration's context
- **Operational only** - Status updates and progress notes belong in IMPLEMENTATION_PLAN.md, not here
- **Update sparingly** - Only add patterns that will help future iterations avoid repeated mistakes

Think of AGENTS.md as the "heart of the loop" - it's the single canonical source of "how to run/build" knowledge that persists across all iterations.

## Let Ralph Ralph

Ralph's effectiveness comes from trusting it to self-correct through iteration:

### Trust the Loop

- Lean into LLM's ability to self-identify, self-correct, self-improve
- Applies to implementation plan, task definition, prioritization
- Eventual consistency achieved through iteration, not upfront perfection

### The Plan is Disposable

This is one of Ralph's most important principles: **the implementation plan is cheap to regenerate**.

- Wrong plan? Delete it and run `ralph plan` again
- Regeneration cost = one planning loop (minutes, not hours)
- Much cheaper than Ralph going in circles on a bad trajectory
- You can delete the plan multiple times during a project - this is normal

**Regenerate when:**
- Going off track (implementing wrong things, duplicating work)
- Plan feels stale or doesn't match current state
- Too much clutter from completed items obscuring what's left
- Significant spec changes that invalidate existing tasks
- Confused about what's actually done vs. pending
- Agent seems to be thrashing or repeating itself

**Don't be precious about the plan.** It's a derived artifact, not a source of truth. The specs are the source of truth. If the plan is wrong, throw it out.

### Move Outside the Loop

To get the most from Ralph, get out of his way:

- Ralph does ALL the work, including deciding what to implement next
- Your job: engineer the setup and environment for success
- Sit ON the loop, not IN it

**Observe and course correct:**
- Watch patterns emerge, especially early on
- Where does Ralph go wrong?
- What signs does he need?
- Prompts evolve through observed failure patterns

**Tune like a guitar:**
- Don't prescribe everything upfront
- Observe and adjust reactively
- When Ralph fails a specific way, add a sign to help next time

### Signs Aren't Just Prompts

Signs are anything Ralph can discover:

- Prompt guardrails ("don't assume not implemented")
- Operational knowledge in project docs
- Utilities and patterns in the codebase
- Test fixtures that demonstrate correct behavior

## Three Phases, Two Prompts, One Loop

### Phase 1: Define Requirements (Human + LLM)

- Discuss project ideas → identify Jobs to Be Done
- Break JTBD into topics of concern
- Write specs for each topic
- This is creative, collaborative, human-driven

### Phase 2: Planning Loop

- Gap analysis: specs vs existing code
- Generate prioritized task list
- No implementation, just planning
- Can run multiple iterations if needed

### Phase 3: Building Loop

- Pick most important task from plan
- Implement, test, validate
- Update plan, commit
- Loop restarts with fresh context

Same loop mechanism, different prompts. The bash script is intentionally dumb:

```bash
while true; do
  cat PROMPT.md | claude -p --dangerously-skip-permissions
done
```

## Task Lifecycle in Building Loop

Each iteration:

1. **Orient** - Study specs (requirements)
2. **Read plan** - Study IMPLEMENTATION_PLAN.md
3. **Select** - Pick most important task
4. **Investigate** - Search codebase ("don't assume not implemented")
5. **Implement** - Make changes
6. **Validate** - Run tests (backpressure)
7. **Update plan** - Mark done, note discoveries
8. **Commit** - If validation passes
9. **Exit** - Context cleared, next iteration starts fresh

The fresh context each iteration is key - no accumulated context debt.

## Terminology

| Term | Definition |
|------|------------|
| **JTBD** | High-level user need or outcome (Job to Be Done) |
| **Topic of Concern** | A distinct aspect/component within a JTBD |
| **Spec** | Requirements doc for one topic (`specs/*.md`) |
| **Task** | Unit of work derived from comparing specs to code |

**Relationships:**
- 1 JTBD → multiple topics of concern
- 1 topic → 1 spec
- 1 spec → multiple tasks

## Further Reading

- [Geoffrey Huntley's original Ralph post](https://ghuntley.com/ralph/)
- [Clayton Farr's Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
