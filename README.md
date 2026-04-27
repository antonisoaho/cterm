# cterm

Neovim + Claude Code TUI playground.

## Launch

Windows:

    cterm.cmd

bash (git-bash):

    ./cterm

Layout: WezTerm window — Claude Code on the left, Neovim on the right.

The Neovim config under `nvim/` is fully isolated from your primary nvim
setup via `XDG_CONFIG_HOME`/`XDG_DATA_HOME` set by the launcher. Plugin
data lives in `.data/` (git-ignored).

See `docs/superpowers/specs/2026-04-27-cterm-nvim-playground-design.md`
for the full design.
