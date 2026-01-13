---
name: ralph-setup
description: Install the Ralph CLI to your system PATH for easy terminal access
---

# Ralph CLI Setup

Help the user install the `ralph` CLI command to their system so they can run `ralph plan` and `ralph build` from any project directory.

## Steps

1. **Detect the user's environment:**
   - Check their shell (bash, zsh, fish)
   - Check their OS (macOS, Linux)
   - Check if `~/.local/bin` exists and is in PATH

2. **Offer installation options based on what's available:**

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

3. **Execute the chosen installation:**

   For Option A (recommended):
   ```bash
   mkdir -p ~/.local/bin
   ln -sf "${CLAUDE_PLUGIN_ROOT}/scripts/ralph" ~/.local/bin/ralph
   chmod +x ~/.local/bin/ralph
   ```

   Then check if `~/.local/bin` is in PATH. If not, tell them to add:
   ```bash
   # For bash (~/.bashrc):
   export PATH="$HOME/.local/bin:$PATH"

   # For zsh (~/.zshrc):
   export PATH="$HOME/.local/bin:$PATH"

   # For fish (~/.config/fish/config.fish):
   fish_add_path ~/.local/bin
   ```

   For Option B:
   ```bash
   sudo ln -sf "${CLAUDE_PLUGIN_ROOT}/scripts/ralph" /usr/local/bin/ralph
   ```

   For Option C:
   ```bash
   # Add to shell config:
   alias ralph='${CLAUDE_PLUGIN_ROOT}/scripts/ralph'
   ```

4. **Verify the installation:**
   ```bash
   which ralph
   ralph --help
   ```

5. **Tell the user they may need to restart their terminal** or run `source ~/.bashrc` (or equivalent) for changes to take effect.

## Important Notes

- The ralph script at `${CLAUDE_PLUGIN_ROOT}/scripts/ralph` is the main entry point
- It wraps `loop.sh` and handles the plan/build subcommands
- Always use `${CLAUDE_PLUGIN_ROOT}` for paths - never hardcode the plugin location
