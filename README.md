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

You need WezTerm, Neovim ≥ 0.10, Node.js (for the npm-based agent CLIs),
a Nerd Font, and at least one agent CLI. Setup can install the font for you.

### Windows (winget)

    winget install --id=wez.wezterm
    winget install --id=Neovim.Neovim
    winget install --id=OpenJS.NodeJS
    winget install --id=GitHub.cli

JetBrainsMono Nerd Font — download from https://www.jetbrains.com/lp/mono/ and install the `.ttf` files, or let `cterm --setup` install it for you.

### macOS (Homebrew)

    brew install --cask wezterm
    brew install neovim node gh

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
    node --version
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

## First run

The first time you launch `cterm` it runs an interactive setup that asks for
your default agent, font, font size, whether to use your own nvim config, and
(if claude is the default) whether to install the caveman plugin (which sets
caveman ultra as the global default mode).
The answers are written to `cterm.local` (and `cterm.local.cmd` on Windows) —
both gitignored. Re-run anytime:

    cterm --setup

## Launch

From any directory:

    cterm              # uses your CTERM_DEFAULT_AGENT (claude unless changed)
    cterm copilot      # override: GitHub Copilot CLI
    cterm codex        # override: Codex
    cterm gemini       # override: Gemini
    cterm <bin>        # any binary on PATH

The `cterm` working directory becomes the agent's working directory.

## User-local overrides

Settings in `cterm.local` (managed by `cterm --setup`):

| Variable               | Effect                                          |
|------------------------|-------------------------------------------------|
| `CTERM_DEFAULT_AGENT`  | Agent used when no CLI arg given                |
| `CTERM_FONT`           | Primary font in WezTerm                         |
| `CTERM_FONT_SIZE`      | WezTerm font size                               |
| `CTERM_USE_USER_NVIM`  | `1` skips the bundled nvim and uses your normal config (`~/.config/nvim` or `%LOCALAPPDATA%\nvim`) |

Nvim-side overrides: drop a file at `nvim/lua/config/local.lua` (gitignored).
`init.lua` will `pcall(require, 'config.local')` on startup, so anything you
put there layers on top of the bundled config.

## Pane navigation

| Keys     | Action                  |
|----------|-------------------------|
| `Alt+h`  | Focus left pane (agent) |
| `Alt+l`  | Focus right pane (nvim) |
| `Shift+Enter` | Newline in agent prompt (no submit) |
| `Ctrl+Shift+C` / `Ctrl+Insert` | Copy selection to clipboard |
| `Ctrl+Shift+V` / `Shift+Insert` / right-click | Paste from clipboard |
| Drag with mouse | Select; releasing copies to clipboard |

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

## Statusline

cterm sessions get a minimal Claude Code statusline (`scripts/statusline.sh`)
showing model and current directory. It's scoped to cterm via `--settings`, so
your global statusline remains in effect for sessions outside cterm.

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

