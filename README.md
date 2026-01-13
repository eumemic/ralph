# Ralph

Autonomous AI-assisted development methodology that keeps specs and code in sync through intelligent iteration loops.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/) with adaptations for Claude Code.

## The Idea

**Humans write specs (the "what"). The machine handles implementation (the "how").**

```
specs/ ──► [planning loop] ──► IMPLEMENTATION_PLAN.md ──► [building loop] ──► code
```

- Specs are the source of truth
- Code is the derived artifact
- Fresh context per iteration prevents context debt
- Built-in quality gates create backpressure

## Installation

### 1. Add the plugin to Claude Code

```bash
/plugin marketplace add eumemic/ralph
```

### 2. Install the CLI

Run the setup command in Claude Code:

```
/ralph-setup
```

This adds `ralph` to your PATH.

## Usage

### Initialize a project

```bash
ralph init
```

Creates:
- `specs/` - Where you write specifications
- `.ralph/config.yaml` - Configuration
- `.ralph/IMPLEMENTATION_PLAN.md` - Generated task list

### Write specs

Create markdown files in `specs/` describing what you want to build. Focus on:

- **What success looks like** - Observable outcomes
- **Acceptance criteria** - Testable conditions
- **Edge cases** - What could go wrong
- **Constraints** - Performance, security, compatibility

Use the `/ralph` skill in Claude Code to help write specs through a structured conversation.

### Run the planning loop

```bash
ralph plan
```

Analyzes your specs against the codebase and generates a prioritized implementation plan in `.ralph/IMPLEMENTATION_PLAN.md`.

### Run the building loop

```bash
ralph build
```

Implements tasks one at a time, each iteration:
1. Picks ONE task from the plan
2. Writes test first
3. Implements
4. Validates
5. Commits
6. Restarts with fresh context

### Environment variables

```bash
RALPH_MODEL=opus            # Main agent (default: opus)
RALPH_SUBAGENT_MODEL=sonnet # Subagents (default: sonnet)
```

## Project Structure

```
your-project/
├── specs/                         # Commit this - your specifications
│   ├── feature-one.md
│   └── feature-two.md
├── .ralph/                        # Gitignore this - generated files
│   ├── config.yaml
│   └── IMPLEMENTATION_PLAN.md
└── src/
```

- **`specs/`** should be committed to your repo - these are your project's requirements
- **`.ralph/`** should be gitignored - it contains generated files and local config

Add to your `.gitignore`:
```
.ralph/
```

## Configuration

Edit `.ralph/config.yaml`:

```yaml
# Where to find specs (default: ./specs)
specs_dir: ./specs

# Or put them elsewhere
# specs_dir: ./docs/requirements
```

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-init` | Initialize Ralph in current project |
| `/ralph-setup` | Install `ralph` CLI to your PATH |
| `/ralph-plan` | Explain/run the planning loop |
| `/ralph-build` | Explain/run the building loop |

## How It Works

### Planning Loop

1. Reads all specs
2. Studies existing codebase with parallel subagents
3. Performs gap analysis (spec vs implementation)
4. Generates prioritized task list
5. Repeats until plan stabilizes

### Building Loop

1. Reads specs and plan
2. Picks highest priority incomplete task
3. Searches codebase ("don't assume not implemented")
4. Writes test first, then implements
5. Runs validation (tests, code-review, code-simplifier)
6. Commits on success
7. Exits - loop restarts with fresh context

Each iteration gets a clean 200K token context. No accumulated confusion.

## Credits

- Original methodology: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Playbook synthesis: [Clayton Farr](https://github.com/ClaytonFarr/ralph-playbook)

## License

MIT
