# cterm

A pre-wired terminal IDE: one WezTerm window split in two — your AI coding agent
on the left, Neovim on the right. The agent edits files, Neovim opens them
automatically. Works on Windows and macOS/Linux.

## What it does

- Launches WezTerm with two panes from any directory.
- Left pane: an agent CLI of your choice (Claude Code by default; also Copilot,
  Codex, Gemini, or any binary on `PATH`).
- Right pane: Neovim, listening on `127.0.0.1:6666`.
- Hook: when the agent edits or writes a file, Neovim auto-opens it in the
  right pane so you can review the change immediately.
- Fully isolated Neovim config — uses its own plugins and state under the repo,
  so your existing `~/.config/nvim` (or `%LOCALAPPDATA%\nvim`) is untouched.

## Prerequisites

You need WezTerm, Neovim ≥ 0.10, Python 3, Node.js (for the npm-based agent
CLIs), a Nerd Font, and at least one agent CLI.

### Windows (winget)

    winget install --id=wez.wezterm
    winget install --id=Neovim.Neovim
    winget install --id=Python.Python.3.13
    winget install --id=OpenJS.NodeJS
    winget install --id=GitHub.cli

JetBrainsMono Nerd Font — download `JetBrainsMono.zip` from
https://github.com/ryanoasis/nerd-fonts/releases and install the `.ttf` files.

### macOS (Homebrew)

    brew install --cask wezterm
    brew install neovim python node gh
    brew install --cask font-jetbrains-mono-nerd-font

### Agent CLI (pick one or more)

Most agents ship via npm:

    npm install -g @anthropic-ai/claude-code   # claude
    npm install -g @openai/codex               # codex
    npm install -g @google/gemini-cli          # gemini

GitHub Copilot CLI is a `gh` extension:

    gh auth login
    gh extension install github/gh-copilot

### Verify

    wezterm --version
    nvim --version
    python3 --version
    claude --version

## Install

Clone the repo, then run the installer for your OS.

**Windows (PowerShell)** — adds the repo to your user `PATH`:

    git clone https://github.com/antonisoaho/cterm.git
    cd cterm
    powershell -ExecutionPolicy Bypass -File install.ps1

Restart your terminal afterward.

**macOS / Linux / git-bash / WSL** — symlinks into `~/.local/bin`:

    git clone https://github.com/antonisoaho/cterm.git
    cd cterm
    bash install.sh

If `~/.local/bin` is not on your `PATH`, the script prints the line to add.

## Launch

From any directory:

    cterm              # uses Claude Code (default)
    cterm copilot      # uses GitHub Copilot CLI
    cterm codex        # uses Codex
    cterm gemini       # uses Gemini
    cterm <bin>        # any binary on PATH

The `cterm` working directory becomes the agent's working directory.

## Pane navigation

| Keys     | Action                  |
|----------|-------------------------|
| `Alt+h`  | Focus left pane (agent) |
| `Alt+l`  | Focus right pane (nvim) |
| `Shift+Enter` | Newline in agent prompt (no submit) |

## Neovim keymaps (leader = Space)

| Keys              | Action                                      |
|-------------------|---------------------------------------------|
| `<leader>e`       | Toggle file tree                            |
| `<leader>ge`      | Toggle git status tree                      |
| `<leader>gd`      | Open Diffview                               |
| `<leader>gh`      | File history                                |
| `<leader>gq`      | Close Diffview                              |
| `]c` / `[c`       | Next / prev git hunk                        |
| `<leader>hp/s/r/b`| Hunk preview / stage / reset / blame        |
| `<leader>ff/g/b/h`| Telescope files / grep / buffers / help     |
| `<S-h>` / `<S-l>` | Prev / next buffer                          |
| `<leader>bd`      | Close current file (keep window/nvim open)  |
| `<C-h/j/k/l>`     | Window navigation (incl. terminal)          |
| `<Esc>` (term)    | Terminal to normal mode                     |
| `<leader>w/q`     | Save / quit                                 |

## How the agent → nvim sync works

The agent (Claude Code) is launched with an extra settings file scoped to the
cterm repo, registering a `PostToolUse` hook on `Write|Edit|EnterPlanMode`.
After every edit the hook calls:

    nvim --server 127.0.0.1:6666 --remote <file>

Other agents (Copilot, Codex, Gemini) launch without the hook. Add equivalent
integration if their CLI supports it.

## Isolation

The launcher exports:

    XDG_CONFIG_HOME = <repo>
    XDG_DATA_HOME   = <repo>/.data
    XDG_STATE_HOME  = <repo>/.state
    XDG_CACHE_HOME  = <repo>/.cache

Plugin state lives entirely under `<repo>/.data/` (git-ignored).

## Customizing

- **WezTerm** — `wezterm.lua` (panes, keys, theme, font).
- **Neovim** — `nvim/` (plugins under `nvim/lua/plugins/`, keymaps in
  `nvim/lua/config/keymaps.lua`).
- **Hook script** — `scripts/nvim-open.sh` and `scripts/nvim-open.py`.
- **Agent settings** — `.claude/settings.json` (loaded via `--settings`).

## Updating plugins

Inside the playground nvim:

    :Lazy sync

Commit the resulting `nvim/lazy-lock.json` to pin versions.

