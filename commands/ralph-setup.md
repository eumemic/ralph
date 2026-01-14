---
name: ralph-setup
description: Install the Ralph CLI and dependencies for terminal access
---

# Ralph CLI Setup

Help the user install the `ralph` CLI command and its dependencies so they can run `ralph plan` and `ralph build` from any project directory.

## Steps

1. **Install Python dependencies:**
   ```bash
   pip install 'claude-transcriber>=0.2.0'
   ```

   This library is used to format Claude's streaming output during plan/build loops. Version 0.2.0+ is required for proper streaming support.

2. **Detect the user's environment:**
   - Check their shell (bash, zsh, fish)
   - Check their OS (macOS, Linux)
   - Check if `~/.local/bin` exists and is in PATH

3. **Offer installation options based on what's available:**

   **Option A: ~/.local/bin (Recommended for most users)**
   - Create `~/.local/bin` if it doesn't exist
   - Symlink or copy the ralph script there
   - This directory is typically in PATH on modern systems

   **Option B: Symlink to /usr/local/bin**
   - Requires sudo on some systems
   - More traditional Unix approach

   **Option C: Shell alias**
   - Add an alias to their shell config (.bashrc, .zshrc, config.fish)
   - No symlinks or permissions needed

4. **Execute the chosen installation:**

   For Option A (recommended):

   Create a **wrapper script** (not a symlink) that finds the latest installed version:
   ```bash
   mkdir -p ~/.local/bin
   cat > ~/.local/bin/ralph << 'WRAPPER'
#!/bin/bash
# Ralph CLI wrapper - finds latest installed version
RALPH_SCRIPT=$(ls -td ~/.claude/plugins/cache/eumemic/ralph/*/scripts/ralph 2>/dev/null | head -1)
if [ -z "$RALPH_SCRIPT" ] || [ ! -f "$RALPH_SCRIPT" ]; then
    echo "Error: Ralph plugin not found. Install with: claude plugin install ralph@eumemic"
    exit 1
fi
exec "$RALPH_SCRIPT" "$@"
WRAPPER
   chmod +x ~/.local/bin/ralph
   ```

   This wrapper automatically uses the latest version after `claude plugin update ralph@eumemic`.

   Then check if `~/.local/bin` is in PATH. If not, tell them to add:
   ```bash
   # For bash (~/.bashrc):
   export PATH="$HOME/.local/bin:$PATH"

   # For zsh (~/.zshrc):
   export PATH="$HOME/.local/bin:$PATH"

   # For fish (~/.config/fish/config.fish):
   fish_add_path ~/.local/bin
   ```

   For Option B (/usr/local/bin):

   Create the same wrapper script but in /usr/local/bin:
   ```bash
   sudo tee /usr/local/bin/ralph << 'WRAPPER' > /dev/null
#!/bin/bash
# Ralph CLI wrapper - finds latest installed version
RALPH_SCRIPT=$(ls -td ~/.claude/plugins/cache/eumemic/ralph/*/scripts/ralph 2>/dev/null | head -1)
if [ -z "$RALPH_SCRIPT" ] || [ ! -f "$RALPH_SCRIPT" ]; then
    echo "Error: Ralph plugin not found. Install with: claude plugin install ralph@eumemic"
    exit 1
fi
exec "$RALPH_SCRIPT" "$@"
WRAPPER
   sudo chmod +x /usr/local/bin/ralph
   ```

   For Option C (shell alias):
   ```bash
   # Add to shell config (.bashrc, .zshrc, config.fish):
   alias ralph='$(ls -td ~/.claude/plugins/cache/eumemic/ralph/*/scripts/ralph 2>/dev/null | head -1)'
   ```

5. **Verify the installation:**
   ```bash
   which ralph
   ralph --help
   ```

6. **Tell the user they may need to restart their terminal** or run `source ~/.bashrc` (or equivalent) for changes to take effect.

## Important Notes

- The ralph script at `${CLAUDE_PLUGIN_ROOT}/scripts/ralph` is the main entry point
- It wraps `loop.sh` and handles the plan/build subcommands
- Always use `${CLAUDE_PLUGIN_ROOT}` for paths - never hardcode the plugin location
