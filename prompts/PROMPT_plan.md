0a. Study `${PLAN_FILE}` (if present) to understand the current plan.
0b. Study `${SHARED_UTILS_DIR}/*` to understand shared utilities & components.
0c. Get the list of READY specs by running: `${PLUGIN_ROOT}/scripts/get-ready-specs.sh ${SPECS_DIR}`

1. **Gap analysis per READY spec**: Launch one **Sonnet** subagent per READY spec file (from step 0c). Each subagent is responsible for:
   - Reading its assigned spec file thoroughly
   - Searching the codebase to find what's implemented vs. missing
   - Reporting gaps: requirements in the spec that aren't fully implemented
   - Checking for TODOs, placeholders, skipped tests, incomplete implementations related to its spec

2. Collect findings from all subagents. Use an **Opus** subagent to analyze the combined findings, prioritize tasks, and create/update `${PLAN_FILE}` as a bullet point list sorted by priority. Mark items complete/incomplete based on actual code state.

3. Each work item in the plan MUST include:
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

IMPORTANT: Only analyze specs with `status: READY`. Ignore DRAFT specs (work in progress) and COMPLETE specs (already done). If no READY specs exist, report this and exit - there's nothing to plan.

IMPORTANT: Do NOT change spec statuses. Status management (DRAFT → READY → COMPLETE) is handled by the user and their agent, not by planning or building loops.

ULTIMATE GOAL: ${SCOPE_INSTRUCTION}Consider missing elements and plan accordingly. If an element is missing from specs, search first to confirm it doesn't exist in code, then if needed author the specification at `${SPECS_DIR}/FILENAME.md` with `status: DRAFT` (it will need user review before becoming READY).
