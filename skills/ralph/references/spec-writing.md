# Spec Writing Process

This document details the four-phase process for turning fuzzy ideas into clear, unambiguous specifications.

## Critical Rule

**Do NOT write the spec file until Phase 3.** The conversation must reach closure first. Jumping to writing too early leads to incomplete specs and wasted iteration.

## Phase 1: Freeform Discussion

Let the user talk through the idea. This is a *conversation*, not an interrogation.

### Guidelines

- **Even if a starting point exists** (e.g., a GitHub issue), don't assume it's complete
- Summarize your understanding, then ask: "Is there anything else you want to add or discuss before I start asking specific questions?"
- Let the user explain in their own words - don't interrupt with structured questions yet
- Understand the JTBD (Job to Be Done) - what is the *user* trying to accomplish?
- Note design issues the user raises
- **Investigate the codebase** - read relevant code to understand what exists and how it works
- **Consult skills** - use relevant skills to understand the system
- Ask clarifying questions naturally as they arise, but keep it conversational

### Boundaries

- Do NOT create any files yet
- Do NOT jump to Phase 2 until the user explicitly indicates they're ready

## Phase 2: Structured Interrogation

Once the user confirms they're ready for questions, systematically probe for gaps.

### Using AskUserQuestion

- **You MUST use the AskUserQuestion tool** - not bullet points, not numbered lists, not prose questions
- AskUserQuestion is a tool that presents multiple-choice options to the user
- Keep asking questions until every design decision is resolved with zero ambiguity
- Continue investigating code as new areas come up
- Identify edge cases, constraints, acceptance criteria
- Surface tradeoffs and get the user's preference

### The Goal

**A completely unambiguous spec.** No "open questions", no "TBD", no "we'll figure it out later". If something is unclear, ask another question.

### Signs You're Not Done

- Any decision could go multiple ways
- User seems uncertain
- You're tempted to write "open questions" in the spec
- You haven't looked at all the code that will be affected

## Phase 3: Draft the Spec

Only when the user confirms readiness, write the spec.

### Writing Guidelines

- Write directly to `specs/filename.md` (or configured specs_dir)
- **Start with `status: DRAFT`** in the YAML frontmatter
- Format is flexible - capture what matters clearly
- Include: JTBD, acceptance criteria, edge cases, constraints, key design decisions
- No "open questions" section - those should be resolved in Phase 2

### Iteration

If the user isn't satisfied with the draft, return to Phase 1 for another round.

## Phase 4: Approve for Implementation

After the user reviews and approves the spec:

- Change `status: DRAFT` to `status: READY`
- Confirm with user: "The spec is ready. Should I mark it READY for planning and implementation?"
- Only transition after explicit user approval

## Topics of Concern

Break each JTBD into topics. Each topic becomes one spec file.

### The "And" Test

Can you describe the topic in one sentence without "and"?

- ✅ "The color extraction system analyzes images to identify dominant colors" (one topic)
- ❌ "The user system handles authentication, profiles, and billing" (three topics - split it)

## Spec Content

Specs should be detailed enough that a planning agent can do gap analysis against the codebase.

### What to Include

- **What success looks like** - observable outcomes
- **Acceptance criteria** - testable conditions that prove the feature works
  - Each criterion should be concrete enough to become a test case
  - Good: "`append_batch(['A', 'B', 'C'])` creates exactly 3 leaves"
  - Bad: "batch append works correctly"
- **Edge cases** - what could go wrong, with expected behavior for each
- **Constraints** - performance, security, compatibility
- **Key design decisions** - choices made during Phase 2 and their rationale

### Testability Principle

If you can't describe how to test a requirement, the requirement isn't clear enough. Every acceptance criterion should map to a test.

## Quick Reference

| Phase | Activity | Output |
|-------|----------|--------|
| 1 | Freeform discussion | Understanding of JTBD |
| 2 | Structured interrogation | All decisions resolved |
| 3 | Draft spec | `specs/filename.md` with `status: DRAFT` |
| 4 | User approval | Status changed to `READY` |
