---
name: ralph-build
description: Run or explain the Ralph building loop for implementing tasks from the plan
---

# Ralph Building Loop

The building loop implements tasks from `IMPLEMENTATION_PLAN.md`, one task per iteration, with testing and validation.

## When User Runs This Command

Explain what the building loop does and how to run it:

### What the Building Loop Does

1. **Studies specs and plan** - Loads context about what needs to be built
2. **Picks ONE task** - Selects the highest priority incomplete task
3. **Searches before building** - Confirms the feature isn't already implemented
4. **Implements** - Writes the code for that one task
5. **Tests and validates** - Runs tests, uses code-simplifier and code-review skills
6. **Commits** - Creates a commit with the working implementation
7. **Updates plan** - Marks the task complete in `IMPLEMENTATION_PLAN.md`

### How to Run It

**From the terminal (recommended for continuous iteration):**
```bash
ralph build          # Run until all tasks complete
ralph build 20       # Run max 20 iterations
```

**Single iteration from Claude Code:**
You can run a single build iteration right now. This will:
- Pick one task from the plan
- Implement it
- Test and commit
- Exit (the terminal command handles re-running with fresh context)

### Running a Single Iteration

If the user wants to run a single build iteration within this Claude session, execute:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/loop.sh" build 1
```

Or, for a more integrated experience, follow the building prompt directly:

1. Read the building prompt: `${CLAUDE_PLUGIN_ROOT}/prompts/PROMPT_build.md`
2. Execute its instructions within this session

### Important Notes

- **One task per iteration**: This is intentional - it prevents context overload and creates natural checkpoints
- **Fresh context matters**: The terminal `ralph build` command restarts Claude between iterations
- **Must commit**: The building loop requires commits - this creates backpressure and trackable progress
- **Pre-commit hooks**: Configure hooks to validate code quality before commits
- **Plan is updated**: After each task, the plan is updated to reflect progress

### Quality Gates

The building loop includes built-in quality checks:
1. **Tests** - Must pass (or be added if missing)
2. **code-simplifier skill** - Cleans up the implementation
3. **code-review skill** - Checks for issues before commit
4. **Pre-commit hooks** - Project-specific validation

### Configuration

Check `.ralph/config.yaml` for:
- `specs_dir`: Where to find specs (default: `./specs`)
- Model overrides if needed
