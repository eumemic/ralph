0a. Study `${SPECS_DIR}/*` with up to 250 parallel **Sonnet** subagents to learn the application specifications.
0b. Study `${PLAN_FILE}` (if present) to understand the plan so far.
0c. Study `${SHARED_UTILS_DIR}/*` with up to 250 parallel **Sonnet** subagents to understand shared utilities & components.
0d. For reference, the application source code is in the project root.

1. Study `${PLAN_FILE}` (if present; it may be incorrect) and use up to 500 **Sonnet** subagents to study existing source code and compare it against `${SPECS_DIR}/*`. Use an **Opus** subagent to analyze findings, prioritize tasks, and create/update `${PLAN_FILE}` as a bullet point list sorted by priority of items yet to be implemented. Consider searching for TODO, minimal implementations, placeholders, skipped/flaky tests, and inconsistent patterns. Keep the plan up to date with items considered complete/incomplete.

2. Each work item in the plan MUST include:
   - **Spec reference**: Which spec file defines the requirement (e.g., `[spec: client-managed-chunking.md]`)
   - **Success criterion**: A testable condition that proves the item is complete (e.g., "Success: `append_batch(['A', 'B', 'C'])` with `target_chunk_tokens=None` creates exactly 3 leaves")
   - **Test**: The test function that will verify the success criterion (e.g., "Test: `test_append_batch_preserves_atomic_units`")

Example work item format:
```
- [ ] Add email validation to user registration
  - Spec: specs/user-auth.md § Registration
  - Success: Invalid emails are rejected with clear error message; valid emails proceed to account creation
  - Test: `test_registration_rejects_invalid_email`, `test_registration_accepts_valid_email`
  - Location: src/auth/registration.py:45
```

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality is missing; confirm with code search first. Use the "don't assume not implemented" principle - always search before concluding something doesn't exist.

IMPORTANT: Treat `${SHARED_UTILS_DIR}` as the project's standard library for shared utilities and components. Prefer consolidated, idiomatic implementations there over ad-hoc copies.

IMPORTANT: Don't make trivial tweaks to the plan. If the existing plan is substantively correct and complete, leave it alone. Only modify the plan when there are real gaps, incorrect items, or missing work. Reformatting, rewording, or reorganizing without adding substance is wasted effort.

ULTIMATE GOAL: Sync the codebase to match the specifications. Consider missing elements and plan accordingly. If an element is missing from specs, search first to confirm it doesn't exist in code, then if needed author the specification at `${SPECS_DIR}/FILENAME.md`.
