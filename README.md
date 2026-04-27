# cterm

Neovim + Claude Code TUI playground. WezTerm splits one window into two
panes: Claude Code on the left, Neovim on the right.

## Requirements

- WezTerm
- Neovim ≥ 0.10
- `claude` CLI on PATH
- A Nerd Font configured in WezTerm (recommended: JetBrainsMono Nerd Font)

## Launch

Windows:

    cterm.cmd

bash (git-bash, WSL):

    ./cterm

## What's inside

- WezTerm config: `wezterm.lua` — 2-pane startup.
- Neovim config: `nvim/` — fully isolated via XDG env vars set by the launcher.
- Plugins (managed by lazy.nvim): mini.nvim (custom Claude-themed base16),
  neo-tree, gitsigns, diffview, treesitter, telescope, lualine, bufferline.

## Keymaps (leader = Space)

| Keys              | Action                              |
|-------------------|-------------------------------------|
| `<leader>e`       | Toggle file tree                    |
| `<leader>ge`      | Toggle git status tree              |
| `<leader>gd`      | Open Diffview                       |
| `<leader>gh`      | File history                        |
| `<leader>gq`      | Close Diffview                      |
| `]c` / `[c`       | Next / prev git hunk                |
| `<leader>hp/s/r/b`| Hunk preview / stage / reset / blame|
| `<leader>ff/g/b/h`| Telescope files / grep / buffers / help |
| `<C-h/j/k/l>`     | Window navigation (incl. terminal)  |
| `<Esc>` (term)    | Terminal to normal mode             |
| `<leader>w/q`     | Save / quit                         |

## Isolation

The launcher exports:

    XDG_CONFIG_HOME = <repo>
    XDG_DATA_HOME   = <repo>/.data
    XDG_STATE_HOME  = <repo>/.state
    XDG_CACHE_HOME  = <repo>/.cache

Plugin state lives entirely under `<repo>/.data/` (git-ignored). Your
primary `~/.config/nvim` (or `%LOCALAPPDATA%\nvim`) is untouched.

## Updating plugins

Inside the playground nvim:

    :Lazy sync

Commit the resulting `nvim/lazy-lock.json` to pin versions.

## Design

See `docs/superpowers/specs/2026-04-27-cterm-nvim-playground-design.md`.
