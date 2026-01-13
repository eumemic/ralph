---
name: ralph-plan
description: Run or explain the Ralph planning loop for gap analysis between specs and code
---

# Ralph Planning Loop

The planning loop analyzes gaps between specifications and the current implementation, generating an `IMPLEMENTATION_PLAN.md` with prioritized tasks.

## When User Runs This Command

Explain what the planning loop does and how to run it:

### What the Planning Loop Does

1. **Studies specs** - Reads all specification files from `specs/` (or configured location)
2. **Studies code** - Uses subagents to search and understand the existing codebase
3. **Gap analysis** - Identifies what's specified but not implemented, or implemented incorrectly
4. **Generates plan** - Creates/updates `.ralph/IMPLEMENTATION_PLAN.md` with prioritized tasks

### How to Run It

**From the terminal (recommended for continuous iteration):**
```bash
ralph plan           # Run until plan stabilizes
ralph plan 5         # Run max 5 iterations
```

**Single iteration from Claude Code:**
You can run a single planning iteration right now. This will:
- Read specs and analyze the codebase
- Generate or update the implementation plan
- Exit (the terminal command handles re-running with fresh context)

### Running a Single Iteration

If the user wants to run a single planning iteration within this Claude session, execute:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/loop.sh" plan 1
```

Or, for a more integrated experience, follow the planning prompt directly:

1. Read the planning prompt: `${CLAUDE_PLUGIN_ROOT}/prompts/PROMPT_plan.md`
2. Execute its instructions within this session

### Important Notes

- **Fresh context matters**: The terminal `ralph plan` command restarts Claude between iterations, giving each iteration full context capacity
- **Running in Claude Code**: A single iteration works fine, but for large codebases you'll want the terminal loop
- **The plan is idempotent**: Running planning multiple times refines the plan until it stabilizes
- **Plan location**: `.ralph/IMPLEMENTATION_PLAN.md` in the project root

### Configuration

Check `.ralph/config.yaml` for:
- `specs_dir`: Where to find specs (default: `./specs`)
- Model overrides if needed
