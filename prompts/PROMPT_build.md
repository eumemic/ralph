0a. Study `${SPECS_DIR}/*` with up to 500 parallel **Sonnet** subagents to learn the application specifications.
0b. Study `${PLAN_FILE}`.
0c. Study `${AGENTS_FILE}` for operational knowledge (build commands, test commands, patterns).
0d. For reference, shared utilities are in `${SHARED_UTILS_DIR}/*`.

1. Pick **exactly ONE incomplete item** (a single `- [ ]` checkbox) from `${PLAN_FILE}`. **Announce your choice**: "I am working on: [copy the exact item text]". ONE means ONE - do not combine items, do not do "while I'm here" work, do not batch related items. Complete that single item, commit, and exit. The loop will restart you with fresh context for the next item. Before making changes, search the codebase (don't assume not implemented) using **Sonnet** subagents. You may use up to 500 parallel **Sonnet** subagents for searches/reads and only 1 **Sonnet** subagent for build/tests. Use **Opus** subagents when complex reasoning is needed (debugging, architectural decisions).

2. Each work item has a success criterion and associated test. **Write or update the test FIRST**, then implement until the test passes. The test is the proof of done - do not mark an item complete until its test passes.

3. After implementing functionality or resolving problems, run the tests for that unit of code. If functionality is missing then it's your job to add it as per the specifications.

4. When you discover issues, immediately update `${PLAN_FILE}` with your findings. When resolved, mark the item complete by changing `- [ ]` to `- [x]`.

5. Before committing, review your implementation for simplicity and correctness. Clean up any unnecessary complexity, check for bugs or issues, and address any problems found.

6. **YOU MUST COMMIT YOUR CHANGES.** When the tests pass, update `${PLAN_FILE}`, then `git add -A && git commit` with a message describing the changes. ${AUTO_PUSH_INSTRUCTION} The pre-commit hook will validate your work. If it fails, fix the issues and commit again. Your work is NOT done until the commit succeeds. Do not summarize or declare victory without a successful commit.

99999. Important: When authoring documentation, capture the why — tests and implementation importance.
999999. Important: Single sources of truth, no migrations/adapters. If tests unrelated to your work fail, resolve them as part of the increment.
9999999. ${AUTO_TAG_INSTRUCTION}
99999999. You may add extra logging if required to debug issues.
999999999. Keep `${PLAN_FILE}` current with learnings — future work depends on this to avoid duplicating efforts. Update especially after finishing your turn.
9999999999. When you learn something new about how to run the application, update `${AGENTS_FILE}` using a subagent but keep it brief. For example if you run commands multiple times before learning the correct command then that file should be updated.
99999999999. For any bugs you notice, resolve them or document them in `${PLAN_FILE}` even if unrelated to current work.
999999999999. Implement functionality completely. Placeholders and stubs waste efforts and time redoing the same work.
9999999999999. When `${PLAN_FILE}` becomes large, periodically clean out completed items from the file.
99999999999999. If you find inconsistencies in `${SPECS_DIR}/*`, use an **Opus** subagent to update the specs.
999999999999999. IMPORTANT: Keep `${AGENTS_FILE}` operational only — status updates and progress notes belong in `${PLAN_FILE}`. A bloated AGENTS.md pollutes every future loop's context.
