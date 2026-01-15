# Bugs vs. Gaps: When to Use Ralph

Ralph is designed for spec-to-code synchronization. Not all development work fits this model. This document clarifies what belongs in Ralph and what doesn't.

## The Core Distinction

**Gaps** (Ralph's domain):
- Spec says X, code doesn't do X
- Spec is missing, code needs to be written
- Spec is wrong, code faithfully implements the wrong thing

**Bugs** (outside Ralph's domain):
- Spec says X, code appears to implement X, but behavior is wrong at runtime
- The issue is only visible through execution, not static analysis

## Why Bugs Don't Fit Ralph

### 1. Specs Are Declarative

Specs describe the desired end state - how the world *should* exist. They're not a place to document transient issues or runtime observations. A bug is a deviation from an already-correct spec, not a missing requirement.

### 2. Different Workflows

**Feature development is top-down:**
```
ideate → write spec → plan → build
```

**Bug fixing is bottom-up:**
```
observe bad behavior → find reproduction steps → hypothesize → write failing test → implement fix
```

Forcing bugs into the top-down flow creates friction. The planning loop can't discover bugs because they're not visible through spec-vs-code comparison.

### 3. Planning Loop Can't Help

The planner does gap analysis: "spec says X, code does Y, gap is Z."

For bugs:
- Spec says X
- Code *appears* to do X
- But at runtime, behavior is wrong

The gap isn't visible through static analysis. The planner would see no issue.

### 4. Lifecycle Mismatch

If you documented bugs in specs, what happens after they're fixed?
- Delete the documentation? Loses history.
- Mark it as fixed? Clutters the spec with resolved issues.

Neither fits a document that's supposed to be the source of truth for *what to build*.

## When a "Bug" Is Actually a Design Gap

Sometimes what looks like a bug is actually a spec problem:

- "The spec didn't account for this edge case"
- "The spec assumed X but reality is Y"
- "The spec is ambiguous and the implementation chose wrong"

These *are* design gaps and should go through the normal spec update process:

1. Update the spec to clarify or add the missing requirement
2. Change status to READY
3. Run planning/building loops

**The test:** Does the spec need to change to fix this? If yes, it's a design gap. If the spec is already correct and complete, it's a bug.

## Handling Bugs

For true bugs (spec is right, code looks right, behavior is wrong):

1. **Use debugging workflows** - The `diagnose` skill or standard debugging approaches
2. **Write a failing test first** - Captures the bug as a regression test
3. **Fix and verify** - Standard development, not Ralph loops
4. **Consider if spec needs update** - If fixing the bug reveals a spec gap, update the spec

## Quick Reference

| Situation | Type | Action |
|-----------|------|--------|
| Spec says X, code doesn't do X | Implementation gap | Ralph: plan & build |
| Spec is incomplete or wrong | Design gap | Update spec, then Ralph |
| Spec is right, code looks right, runtime is wrong | Bug | Debug outside Ralph |
| Bug investigation reveals spec was incomplete | Design gap | Update spec, then Ralph |

## Summary

Ralph excels at: "Make the code match the spec."

Ralph doesn't help with: "The code matches the spec but something's still wrong."

For bugs, use debugging workflows. If debugging reveals the spec was incomplete, *then* bring it back to Ralph as a design gap.
