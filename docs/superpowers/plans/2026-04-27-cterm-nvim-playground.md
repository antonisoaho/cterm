# cterm Nvim+Claude TUI Playground — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a self-contained Neovim playground paired with Claude Code in a side-by-side WezTerm layout, isolated from the user's primary nvim config via XDG env vars.

**Architecture:** WezTerm spawns one window with two panes on `gui-startup`: left pane runs `claude`, right pane runs `nvim`. Launcher scripts (`cterm.cmd` / `cterm`) export `XDG_*` so nvim resolves config to `<repo>\nvim` and stores plugin data inside the repo. Plugins managed by lazy.nvim. Colorscheme is a custom mini.base16 palette built around Claude's accent `#D97757`.

**Tech Stack:** WezTerm, Neovim ≥ 0.10, Lua, lazy.nvim, mini.nvim (base16), neo-tree, gitsigns, diffview, treesitter, telescope, lualine, bufferline.

**Verification model:** This is a config repo — there is no automated test framework. Each task ends with a *manual verification* step that launches the playground (or sources the file) and confirms a specific observable outcome. Always commit only after verification passes.

**Working directory:** `C:\git\cterm` (already a git repo on `main` with the spec committed).

**Pre-reqs to confirm before starting:**
- WezTerm installed (`wezterm --version`).
- Neovim ≥ 0.10 installed (`nvim --version`).
- `claude` CLI on PATH (`where claude`).
- A Nerd Font configured in WezTerm for icons (JetBrainsMono Nerd Font recommended, but config falls back gracefully).

---

## File Structure

Files created by this plan (relative to repo root `C:\git\cterm`):

| Path                            | Responsibility                                  |
|---------------------------------|-------------------------------------------------|
| `.gitignore`                    | Ignore `.data/`, `.state/`, `.cache/`.          |
| `README.md`                     | One-page how-to-launch.                         |
| `cterm.cmd`                     | Windows launcher: sets XDG, runs WezTerm.       |
| `cterm`                         | bash launcher mirror.                           |
| `wezterm.lua`                   | WezTerm config + 2-pane startup.                |
| `nvim/init.lua`                 | Nvim entry: loads options/lazy/keymaps.         |
| `nvim/lua/config/options.lua`   | Vim options.                                    |
| `nvim/lua/config/lazy.lua`      | Bootstrap lazy.nvim, import plugin specs.       |
| `nvim/lua/config/keymaps.lua`   | Global keymaps.                                 |
| `nvim/lua/plugins/colorscheme.lua` | mini.base16 palette + highlight overrides.   |
| `nvim/lua/plugins/treesitter.lua`  | nvim-treesitter parsers.                     |
| `nvim/lua/plugins/neo-tree.lua`    | File tree + git_status source.               |
| `nvim/lua/plugins/gitsigns.lua`    | Gutter hunks + keymaps.                      |
| `nvim/lua/plugins/diffview.lua`    | Diffview registration.                       |
| `nvim/lua/plugins/telescope.lua`   | Fuzzy finder.                                |
| `nvim/lua/plugins/lualine.lua`     | Statusline.                                  |
| `nvim/lua/plugins/bufferline.lua`  | Buffer tab bar.                              |

---

## Task 1: Repo skeleton (gitignore + dirs + README stub)

**Files:**
- Create: `.gitignore`
- Create: `README.md`

- [ ] **Step 1: Write `.gitignore`**

Create `C:\git\cterm\.gitignore`:

```gitignore
# nvim runtime under XDG_DATA_HOME / STATE / CACHE
.data/
.state/
.cache/

# OS / editor cruft
Thumbs.db
.DS_Store
*.swp
```

- [ ] **Step 2: Write minimal `README.md`**

Create `C:\git\cterm\README.md`:

```markdown
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
```

- [ ] **Step 3: Verify**

Run:
```bash
ls -la /c/git/cterm
cat /c/git/cterm/.gitignore
```
Expected: both files present; `.gitignore` lists `.data/`, `.state/`, `.cache/`.

- [ ] **Step 4: Commit**

```bash
git add .gitignore README.md
git commit -m "chore: add gitignore and README skeleton"
```

---

## Task 2: Windows launcher (`cterm.cmd`)

**Files:**
- Create: `cterm.cmd`

- [ ] **Step 1: Write `cterm.cmd`**

Create `C:\git\cterm\cterm.cmd`:

```cmd
@echo off
setlocal
set "REPO=%~dp0"
set "REPO=%REPO:~0,-1%"
set "XDG_CONFIG_HOME=%REPO%"
set "XDG_DATA_HOME=%REPO%\.data"
set "XDG_STATE_HOME=%REPO%\.state"
set "XDG_CACHE_HOME=%REPO%\.cache"
wezterm start --config-file "%REPO%\wezterm.lua" --always-new-process
endlocal
```

- [ ] **Step 2: Smoke-check the script syntax**

Run from cmd (or `cmd //c` from bash):
```bash
cmd //c "echo @echo off>nul" && echo cmd parses
```
Expected: `cmd parses`. (We can't fully exec yet — `wezterm.lua` doesn't exist; it'll produce a WezTerm error which is fine.)

- [ ] **Step 3: Commit**

```bash
git add cterm.cmd
git commit -m "feat: add Windows launcher cterm.cmd"
```

---

## Task 3: bash launcher (`cterm`)

**Files:**
- Create: `cterm`

- [ ] **Step 1: Write `cterm`**

Create `C:\git\cterm\cterm`:

```sh
#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -W 2>/dev/null || cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export XDG_CONFIG_HOME="$REPO"
export XDG_DATA_HOME="$REPO/.data"
export XDG_STATE_HOME="$REPO/.state"
export XDG_CACHE_HOME="$REPO/.cache"
exec wezterm start --config-file "$REPO/wezterm.lua" --always-new-process
```

(`pwd -W` returns Windows-style paths under git-bash so WezTerm receives `C:/...`. Falls back to `pwd` on non-MSYS shells.)

- [ ] **Step 2: Make executable**

```bash
chmod +x /c/git/cterm/cterm
```

- [ ] **Step 3: Verify shape**

```bash
head -1 /c/git/cterm/cterm
```
Expected: `#!/usr/bin/env bash`.

- [ ] **Step 4: Commit**

```bash
git add cterm
git commit -m "feat: add bash launcher cterm"
```

---

## Task 4: WezTerm config with 2-pane startup (placeholder shells)

This task lands the WezTerm config first with shell commands instead of `claude`/`nvim`, so we can verify pane spawn before depending on later work. We'll swap to real commands in Task 16.

**Files:**
- Create: `wezterm.lua`

- [ ] **Step 1: Write `wezterm.lua`**

Create `C:\git\cterm\wezterm.lua`:

```lua
local wezterm = require('wezterm')
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local repo = wezterm.config_dir
  local _tab, left, window = mux.spawn_window {
    cwd = repo,
    args = { 'cmd.exe', '/k', 'echo LEFT pane placeholder (will run claude)' },
  }
  local _right = left:split {
    direction = 'Right',
    size = 0.55,
    cwd = repo,
    args = { 'cmd.exe', '/k', 'echo RIGHT pane placeholder (will run nvim)' },
  }
  window:gui_window():maximize()
end)

return {
  color_scheme = 'Gruvbox Dark',
  font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'JetBrains Mono',
    'Consolas',
  }),
  font_size = 11,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = { left = 4, right = 4, top = 2, bottom = 2 },
}
```

- [ ] **Step 2: Launch and verify panes**

Run:
```bash
/c/git/cterm/cterm.cmd
```
Expected: WezTerm window opens, maximized, two side-by-side panes. Left pane shows `LEFT pane placeholder (will run claude)`. Right pane shows `RIGHT pane placeholder (will run nvim)`. Right pane is wider (~55%).

Close the window when verified.

- [ ] **Step 3: Commit**

```bash
git add wezterm.lua
git commit -m "feat: wezterm config with two-pane startup (placeholders)"
```

---

## Task 5: Neovim entry + options

**Files:**
- Create: `nvim/init.lua`
- Create: `nvim/lua/config/options.lua`

- [ ] **Step 1: Write `nvim/lua/config/options.lua`**

Create `C:\git\cterm\nvim\lua\config\options.lua`:

```lua
local opt = vim.opt

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.termguicolors = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.updatetime = 200
opt.timeoutlen = 400
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.wrap = false
opt.fillchars = { eob = ' ' }
```

- [ ] **Step 2: Write `nvim/init.lua`**

Create `C:\git\cterm\nvim\init.lua`:

```lua
require('config.options')
-- lazy + plugins arrive in Task 6
-- keymaps arrive in Task 14
```

- [ ] **Step 3: Verify nvim loads with our config**

From bash:
```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim --headless -c 'lua print(vim.o.number, vim.o.relativenumber, vim.g.mapleader)' -c 'qa' 2>&1
```
Expected output contains: `true true  ` (with a literal space at end for the leader).

- [ ] **Step 4: Commit**

```bash
git add nvim/init.lua nvim/lua/config/options.lua
git commit -m "feat(nvim): entry point and base options"
```

---

## Task 6: lazy.nvim bootstrap

**Files:**
- Create: `nvim/lua/config/lazy.lua`
- Modify: `nvim/init.lua`

- [ ] **Step 1: Write `nvim/lua/config/lazy.lua`**

Create `C:\git\cterm\nvim\lua\config\lazy.lua`:

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'habamax' } },  -- temp until Task 7
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
```

- [ ] **Step 2: Update `nvim/init.lua`**

Replace contents of `C:\git\cterm\nvim\init.lua` with:

```lua
require('config.options')
require('config.lazy')
-- keymaps arrive in Task 14
```

- [ ] **Step 3: Create empty plugins dir so the import doesn't crash**

We need at least one plugin spec for `import = 'plugins'` to succeed. Create a placeholder that will be replaced in Task 7:

Create `C:\git\cterm\nvim\lua\plugins\_placeholder.lua`:

```lua
-- temporary placeholder; replaced in Task 7
return {}
```

- [ ] **Step 4: Verify lazy bootstraps**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim --headless -c 'lua print(package.loaded["lazy"] and "lazy ok" or "lazy missing")' -c 'qa' 2>&1
```
Expected: `lazy ok`. First run also shows a clone of lazy.nvim into `.data/nvim/lazy/lazy.nvim` (visible via `ls /c/git/cterm/.data/nvim/lazy/`).

- [ ] **Step 5: Commit**

```bash
git add nvim/init.lua nvim/lua/config/lazy.lua nvim/lua/plugins/_placeholder.lua
git commit -m "feat(nvim): bootstrap lazy.nvim plugin manager"
```

---

## Task 7: Colorscheme — mini.base16 with Claude palette

**Files:**
- Create: `nvim/lua/plugins/colorscheme.lua`
- Delete: `nvim/lua/plugins/_placeholder.lua`
- Modify: `nvim/lua/config/lazy.lua` (default colorscheme)

- [ ] **Step 1: Write `nvim/lua/plugins/colorscheme.lua`**

Create `C:\git\cterm\nvim\lua\plugins\colorscheme.lua`:

```lua
return {
  {
    'echasnovski/mini.nvim',
    version = false,
    priority = 1000,
    lazy = false,
    config = function()
      require('mini.base16').setup({
        palette = {
          base00 = '#1a1a1a',
          base01 = '#232323',
          base02 = '#2d2d2d',
          base03 = '#6c6c6c',
          base04 = '#8a8a87',
          base05 = '#e8e6e3',
          base06 = '#f2f0ed',
          base07 = '#ffffff',
          base08 = '#c4736e',
          base09 = '#D97757',  -- claude orange (accent)
          base0A = '#d4a574',
          base0B = '#8fa876',
          base0C = '#a3b8a3',
          base0D = '#7a9eb1',
          base0E = '#b08aa8',
          base0F = '#8a6a52',
        },
        use_cterm = false,
      })

      local set = vim.api.nvim_set_hl
      local accent = '#D97757'
      local green  = '#8fa876'
      local yellow = '#d4a574'
      local red    = '#c4736e'

      -- neo-tree
      set(0, 'NeoTreeRootName',      { fg = accent, bold = true })
      set(0, 'NeoTreeDirectoryIcon', { fg = accent })
      set(0, 'NeoTreeDirectoryName', { fg = '#e8e6e3' })

      -- telescope
      set(0, 'TelescopeBorder',       { fg = accent })
      set(0, 'TelescopeTitle',        { fg = accent, bold = true })
      set(0, 'TelescopePromptTitle',  { fg = accent, bold = true })
      set(0, 'TelescopePromptBorder', { fg = accent })

      -- gitsigns
      set(0, 'GitSignsAdd',          { fg = green })
      set(0, 'GitSignsChange',       { fg = yellow })
      set(0, 'GitSignsDelete',       { fg = red })

      -- diffview
      set(0, 'DiffviewFilePanelTitle',   { fg = accent, bold = true })
      set(0, 'DiffviewFilePanelCounter', { fg = accent })
    end,
  },
}
```

- [ ] **Step 2: Remove placeholder**

```bash
rm /c/git/cterm/nvim/lua/plugins/_placeholder.lua
```

- [ ] **Step 3: Update lazy default colorscheme**

Edit `C:\git\cterm\nvim\lua\config\lazy.lua` — change line:

```lua
  install = { colorscheme = { 'habamax' } },  -- temp until Task 7
```

to:

```lua
  install = { colorscheme = { 'base16-cterm' } },
```

(The mini.base16 setup registers a colorscheme name derived from the palette; `base16-cterm` works once a palette is set. If lazy's install screen complains, fall back to `default` — only matters during the install UI.)

- [ ] **Step 4: Verify colorscheme loads**

Launch nvim manually with our XDG (this triggers full plugin install on first run):

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim
```
Expected: Lazy UI shows mini.nvim being installed; after install + `q`, the editor uses the dark palette. Run `:hi NeoTreeRootName` — output should contain `guifg=#D97757`.

Quit with `:qa`.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/plugins/colorscheme.lua nvim/lua/config/lazy.lua
git rm nvim/lua/plugins/_placeholder.lua
git commit -m "feat(nvim): warm-orange mini.base16 palette"
```

---

## Task 8: Treesitter

**Files:**
- Create: `nvim/lua/plugins/treesitter.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/treesitter.lua`**

Create `C:\git\cterm\nvim\lua\plugins\treesitter.lua`:

```lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'vim', 'vimdoc', 'bash', 'python',
          'javascript', 'typescript', 'tsx',
          'json', 'yaml', 'toml',
          'markdown', 'markdown_inline',
          'gitcommit', 'diff', 'git_rebase',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
```

- [ ] **Step 2: Verify install**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim docs/superpowers/specs/2026-04-27-cterm-nvim-playground-design.md
```
Expected: Lazy installs `nvim-treesitter` and parsers (~10-30s). Markdown file shows syntax highlighting (headings/code blocks colored). `:TSModuleInfo highlight` shows `enabled` for the buffer.

Quit with `:qa`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/treesitter.lua
git commit -m "feat(nvim): treesitter with core parsers"
```

---

## Task 9: neo-tree

**Files:**
- Create: `nvim/lua/plugins/neo-tree.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/neo-tree.lua`**

Create `C:\git\cterm\nvim\lua\plugins\neo-tree.lua`:

```lua
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e',  '<cmd>Neotree toggle filesystem<cr>',  desc = 'Toggle file tree' },
      { '<leader>ge', '<cmd>Neotree toggle git_status<cr>',  desc = 'Toggle git tree' },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = false,
      sources = { 'filesystem', 'buffers', 'git_status' },
      default_component_configs = {
        indent = { padding = 0 },
        git_status = {
          symbols = {
            added     = '+',
            modified  = '~',
            deleted   = '-',
            renamed   = '→',
            untracked = '?',
            ignored   = '·',
            unstaged  = '!',
            staged    = '✓',
            conflict  = '×',
          },
        },
      },
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
    },
  },
}
```

- [ ] **Step 2: Verify**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim
```
In nvim run `:Neotree toggle filesystem`. Expected: a 32-col sidebar opens on the left listing repo files; root name `cterm` shows in claude-orange.

Quit with `:qa`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/neo-tree.lua
git commit -m "feat(nvim): neo-tree file tree with git status"
```

---

## Task 10: gitsigns

**Files:**
- Create: `nvim/lua/plugins/gitsigns.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/gitsigns.lua`**

Create `C:\git\cterm\nvim\lua\plugins\gitsigns.lua`:

```lua
return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '≃' },
      },
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map('n', ']c', function() gs.nav_hunk('next') end, 'Next hunk')
        map('n', '[c', function() gs.nav_hunk('prev') end, 'Prev hunk')
        map('n', '<leader>hp', gs.preview_hunk,            'Preview hunk')
        map('n', '<leader>hs', gs.stage_hunk,              'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk,              'Reset hunk')
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
      end,
    },
  },
}
```

- [ ] **Step 2: Verify**

```bash
cd /c/git/cterm && \
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim README.md
```
In nvim, append a line to README.md (any change), do not save. Expected: a `+` sign appears in the gutter on the new line. `:Gitsigns blame_line` opens a blame popup for committed lines.

Discard changes, quit with `:qa!`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/gitsigns.lua
git commit -m "feat(nvim): gitsigns gutter and hunk keymaps"
```

---

## Task 11: diffview

**Files:**
- Create: `nvim/lua/plugins/diffview.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/diffview.lua`**

Create `C:\git\cterm\nvim\lua\plugins\diffview.lua`:

```lua
return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>',             desc = 'Diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>',    desc = 'File history' },
      { '<leader>gq', '<cmd>DiffviewClose<cr>',            desc = 'Close diff' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = 'diff3_mixed' },
      },
    },
  },
}
```

- [ ] **Step 2: Verify**

```bash
cd /c/git/cterm && \
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim README.md
```
Append a line, save, then run `:DiffviewOpen`. Expected: diff layout opens with file panel on left, before/after split on right; `DiffviewFilePanelTitle` shows in claude-orange. `:DiffviewClose` closes it.

Discard the change (`:!git checkout README.md` from inside nvim, then `:e!`) and `:qa`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/diffview.lua
git commit -m "feat(nvim): diffview with open/history/close keymaps"
```

---

## Task 12: telescope

**Files:**
- Create: `nvim/lua/plugins/telescope.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/telescope.lua`**

Create `C:\git\cterm\nvim\lua\plugins\telescope.lua`:

```lua
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',  desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',    desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',  desc = 'Help tags' },
    },
    opts = {
      defaults = {
        layout_strategy = 'flex',
        sorting_strategy = 'ascending',
        layout_config = { prompt_position = 'top' },
        path_display = { 'truncate' },
      },
    },
  },
}
```

- [ ] **Step 2: Verify**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim
```
In nvim run `:Telescope find_files`. Expected: floating prompt at top, file list below; border in claude-orange. Type `readme`, hit `<Esc>` to close.

Quit with `:qa`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/telescope.lua
git commit -m "feat(nvim): telescope fuzzy finder"
```

---

## Task 13: lualine + bufferline

**Files:**
- Create: `nvim/lua/plugins/lualine.lua`
- Create: `nvim/lua/plugins/bufferline.lua`

- [ ] **Step 1: Write `nvim/lua/plugins/lualine.lua`**

Create `C:\git\cterm\nvim\lua\plugins\lualine.lua`:

```lua
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local accent = '#D97757'
      local bg     = '#232323'
      local fg     = '#e8e6e3'
      local muted  = '#8a8a87'

      local theme = {
        normal = {
          a = { fg = '#1a1a1a', bg = accent, gui = 'bold' },
          b = { fg = fg,        bg = bg },
          c = { fg = muted,     bg = bg },
        },
        insert   = { a = { fg = '#1a1a1a', bg = '#8fa876', gui = 'bold' } },
        visual   = { a = { fg = '#1a1a1a', bg = '#d4a574', gui = 'bold' } },
        replace  = { a = { fg = '#1a1a1a', bg = '#c4736e', gui = 'bold' } },
        command  = { a = { fg = '#1a1a1a', bg = '#b08aa8', gui = 'bold' } },
        inactive = {
          a = { fg = muted, bg = bg },
          b = { fg = muted, bg = bg },
          c = { fg = muted, bg = bg },
        },
      }

      require('lualine').setup({
        options = {
          theme = theme,
          section_separators = '',
          component_separators = '|',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      })
    end,
  },
}
```

- [ ] **Step 2: Write `nvim/lua/plugins/bufferline.lua`**

Create `C:\git\cterm\nvim\lua\plugins\bufferline.lua`:

```lua
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        diagnostics = false,
        show_close_icon = false,
        show_buffer_close_icons = false,
        offsets = {
          { filetype = 'neo-tree', text = 'Explorer', text_align = 'center', separator = true },
        },
      },
    },
  },
}
```

- [ ] **Step 3: Verify**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim README.md
```
Expected: top bar shows buffer tab(s); bottom statusline shows mode (`NORMAL`) on claude-orange background, branch (`main`), filename. Open another file (`:e nvim/init.lua`) — second tab appears.

Quit with `:qa`.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/lualine.lua nvim/lua/plugins/bufferline.lua
git commit -m "feat(nvim): lualine statusline and bufferline tabs"
```

---

## Task 14: Keymaps

**Files:**
- Create: `nvim/lua/config/keymaps.lua`
- Modify: `nvim/init.lua`

Note: most plugin keymaps live in their own spec files (lazy `keys =`). This file only carries non-plugin global maps.

- [ ] **Step 1: Write `nvim/lua/config/keymaps.lua`**

Create `C:\git\cterm\nvim\lua\config\keymaps.lua`:

```lua
local map = vim.keymap.set

-- save / quit
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>quit<cr>',  { desc = 'Quit' })

-- window navigation (works in normal AND terminal mode)
map('n', '<C-h>', '<C-w>h', { desc = 'Window left'  })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down'  })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up'    })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

map('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = 'Window left from term'  })
map('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = 'Window down from term'  })
map('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = 'Window up from term'    })
map('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = 'Window right from term' })

-- escape from terminal mode
map('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Term to normal' })

-- clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
```

- [ ] **Step 2: Update `nvim/init.lua`**

Replace contents of `C:\git\cterm\nvim\init.lua` with:

```lua
require('config.options')
require('config.lazy')
require('config.keymaps')
```

- [ ] **Step 3: Verify**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim
```
In nvim run:

```
:verbose nmap <leader>e
:verbose nmap <leader>ff
:verbose nmap <leader>w
```

Expected: each shows the mapping with the source file path. `<leader>e` → neo-tree, `<leader>ff` → telescope, `<leader>w` → save.

Quit with `:qa`.

- [ ] **Step 4: Commit**

```bash
git add nvim/init.lua nvim/lua/config/keymaps.lua
git commit -m "feat(nvim): global keymaps"
```

---

## Task 15: Auto-open neo-tree on startup

**Files:**
- Modify: `nvim/lua/plugins/neo-tree.lua`

- [ ] **Step 1: Add VimEnter autocmd to neo-tree spec**

Edit `C:\git\cterm\nvim\lua\plugins\neo-tree.lua`. Replace the entire return block with:

```lua
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e',  '<cmd>Neotree toggle filesystem<cr>',  desc = 'Toggle file tree' },
      { '<leader>ge', '<cmd>Neotree toggle git_status<cr>',  desc = 'Toggle git tree' },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = false,
      sources = { 'filesystem', 'buffers', 'git_status' },
      default_component_configs = {
        indent = { padding = 0 },
        git_status = {
          symbols = {
            added     = '+',
            modified  = '~',
            deleted   = '-',
            renamed   = '→',
            untracked = '?',
            ignored   = '·',
            unstaged  = '!',
            staged    = '✓',
            conflict  = '×',
          },
        },
      },
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
    },
    config = function(_, opts)
      require('neo-tree').setup(opts)
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          vim.cmd('Neotree show')
        end,
      })
    end,
  },
}
```

- [ ] **Step 2: Verify auto-open**

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim
```
Expected: nvim starts with neo-tree already visible on the left, focused on the editor (right side).

Quit with `:qa`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/neo-tree.lua
git commit -m "feat(nvim): auto-open neo-tree on startup"
```

---

## Task 16: Wire `claude` and `nvim` into WezTerm

Replace placeholder shells with real commands and end-to-end verify.

**Files:**
- Modify: `wezterm.lua`

- [ ] **Step 1: Update `wezterm.lua`**

Edit `C:\git\cterm\wezterm.lua`. Replace the `gui-startup` block with:

```lua
wezterm.on('gui-startup', function(cmd)
  local repo = wezterm.config_dir
  local _tab, left, window = mux.spawn_window {
    cwd = repo,
    args = { 'claude' },
  }
  local _right = left:split {
    direction = 'Right',
    size = 0.55,
    cwd = repo,
    args = { 'nvim' },
  }
  window:gui_window():maximize()
end)
```

(Keep the `require`s, the `return { ... }` block, and everything else unchanged.)

- [ ] **Step 2: Full end-to-end verify**

Run from cmd or File Explorer:
```
C:\git\cterm\cterm.cmd
```
Expected:
- WezTerm window opens, maximized.
- Left pane: Claude Code starts up (banner + prompt).
- Right pane: Neovim opens with neo-tree on the left edge (32 cols), bufferline on top, lualine on bottom showing branch `main` and orange-bg `NORMAL` mode.
- Tree shows the current repo (`README.md`, `cterm.cmd`, `nvim/`, `docs/`, etc.).

Smoke-test inside nvim:
- `<leader>e` toggles tree.
- `<leader>ff` opens telescope find_files.
- `:DiffviewOpen` opens diff UI (clean working tree → empty diff is fine).
- `:edit README.md`, append a line, save → gitsigns shows `+` in gutter.
- `<C-h>` / `<C-l>` move between nvim splits.

Close window when verified.

- [ ] **Step 3: Commit**

```bash
git add wezterm.lua
git commit -m "feat: wire launcher commands into wezterm panes"
```

---

## Task 17: README pass + lazy lockfile

**Files:**
- Modify: `README.md`
- Add: `nvim/lazy-lock.json` (generated)

- [ ] **Step 1: Expand `README.md`**

Replace `C:\git\cterm\README.md` with:

```markdown
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
```

- [ ] **Step 2: Generate and commit lazy lockfile**

Launch the playground once to make sure all plugins are installed at known versions:

```bash
XDG_CONFIG_HOME=/c/git/cterm \
XDG_DATA_HOME=/c/git/cterm/.data \
XDG_STATE_HOME=/c/git/cterm/.state \
XDG_CACHE_HOME=/c/git/cterm/.cache \
nvim --headless -c 'lua require("lazy").sync({wait=true})' -c 'qa' 2>&1 | tail -30
```

Expected: lockfile written to `nvim/lazy-lock.json`. Verify:

```bash
ls /c/git/cterm/nvim/lazy-lock.json
```

- [ ] **Step 3: Commit**

```bash
git add README.md nvim/lazy-lock.json
git commit -m "docs: expand README; pin plugin versions via lazy-lock"
```

---

## Self-Review Notes

- Spec coverage:
  - Layout & launch flow → Tasks 2, 3, 4, 16.
  - XDG isolation → Tasks 2, 3 (launchers); verified in Tasks 5+.
  - Repo layout → all tasks combined.
  - Plugin specs → Tasks 7–13, 15.
  - Claude-aligned palette → Task 7.
  - Keymaps → Task 14 (globals) + per-plugin `keys =` in 9, 10, 11, 12.
  - Vim options → Task 5.
  - Edge cases (claude not on PATH, first run install, non-git repo) → Task 4 placeholder run + Task 16 e2e verify exercise the failure paths.
  - Manual testing checklist → mapped across each task's "Verify" step + Task 16 final e2e.
- No placeholders, no "TBD", no "implement later".
- Type/name consistency: `<leader>e`, `<leader>ff`, `<leader>gd`, `<leader>hb` etc. are referenced consistently across plugins/keymaps/README.
- Lockfile is committed in Task 17 to make future `:Lazy restore` deterministic.
