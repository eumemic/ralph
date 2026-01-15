# Debugging and Extending Specs

When users discover problems with what Ralph built, or want to extend existing functionality, follow this diagnostic workflow.

## Step 1: Diagnose the Gap Type

Before jumping to solutions, determine what kind of gap exists:

### Option A: Implementation Gap

The spec was correct, but the planners/builders failed to implement it correctly or at all.

**Signs:**
- Spec clearly describes the expected behavior
- Code doesn't match what the spec says
- Tests are missing or don't cover the spec's acceptance criteria
- Feature exists but has bugs that violate spec requirements

### Option B: Design Gap

The spec was underspecified (planners filled in the blanks), the spec was wrong but faithfully implemented, or the user wants entirely new features.

**Signs:**
- Spec is vague or missing details that would have prevented the problem
- Implementation matches the spec, but the spec didn't capture what the user actually wanted
- User is describing behavior that isn't covered by any spec
- User says "I didn't think about..." or "I assumed it would..."

### How to Diagnose

Read the relevant spec(s) and compare to the problematic code/behavior. Ask:
- Does the spec clearly define the expected behavior?
- Does the code match what the spec says?
- Is the problem that the spec is wrong, or that the implementation is wrong?
- **Check the spec status** - is it READY? If it's still DRAFT, the loops never saw it. If it's COMPLETE, the loops skipped it.

## Step 2: Close Design Gaps (if applicable)

If you identified a design gap, the specs need work before implementation can proceed.

### For Underspecified or Wrong Specs

1. Return to the three-phase spec process (Phase 1: discuss, Phase 2: interrogate, Phase 3: write)
2. Focus on the specific gap - you don't need to rewrite the whole spec
3. Update the existing spec file with corrections or additions
4. Be explicit about what changed and why
5. **Update status**: If spec was COMPLETE, change to READY. If major rework needed, change to DRAFT.

### For New Features

1. Determine if this is a new topic (new spec file) or an extension of existing topic (update existing spec)
2. Follow the full three-phase process for new material
3. Write or update spec files accordingly
4. New specs start as DRAFT, existing specs being extended go to READY (or DRAFT if significant changes)

After closing design gaps, you now have an implementation gap (the specs describe something the code doesn't do yet). **Ensure the affected specs are in READY status** before proceeding.

## Step 3: Close Implementation Gaps

Two options for closing implementation gaps:

### Option A: Targeted Fix (for small, well-defined gaps)

**Best when:**
- The fix is localized (1-3 files)
- You understand exactly what needs to change
- The change is low-risk and straightforward

**Process:**
1. Deploy a subagent to investigate the specific gap
2. Have the subagent plan and implement the fix
3. Review their work before committing
4. Run relevant tests to validate

### Option B: Re-run Ralph Loops (for larger gaps or when unsure)

**Best when:**
- Multiple related changes are needed
- You're not confident about the full scope
- The specs changed significantly
- You want the planning loop to discover related gaps

**Process:**
1. Run `ralph plan "scope string"` with a scope that targets the changed specs
   - Example: `ralph plan "user authentication"` after updating auth specs
   - The scope ensures the planner focuses on the relevant area
2. Review the generated/updated plan
3. Run `ralph build` to implement the planned tasks

## Step 4: Verify and Mark Complete

After implementation (whether targeted fix or ralph build):

1. Review the results with the user
2. Verify the feature works as specified
3. Ask user: "Are you satisfied with how [feature] works?"
4. If yes, mark the relevant READY specs as COMPLETE
5. If no, identify the gap (design or implementation) and repeat the process

**Only mark specs COMPLETE when the user explicitly confirms satisfaction.**

## Quick Reference: Gap Diagnosis

| Symptom | Likely Gap Type | Action |
|---------|----------------|--------|
| "It doesn't work like the spec says" | Implementation | Targeted fix or re-run build |
| "The spec didn't cover this case" | Design | Update spec, then implement |
| "I want to add a new feature" | Design | New/updated spec, then implement |
| "It works as specced but that's wrong" | Design | Fix spec, then re-implement |
| "Ralph built the wrong thing" | Check both | Read spec - if spec is right, implementation gap; if spec is wrong/vague, design gap |
| "Nothing happened when I ran plan/build" | Status issue | Check if specs are READY (not DRAFT or COMPLETE) |

## Common Status Problems

| Problem | Cause | Fix |
|---------|-------|-----|
| Loops don't see my spec | Status is DRAFT | Change to READY after user approves |
| Loops skip a spec I just modified | Status is COMPLETE | Change back to READY |
| Spec was modified but not re-implemented | Forgot to change COMPLETE → READY | Update status, re-run loops |
| New spec never got implemented | Left as DRAFT | Get user approval, change to READY |
