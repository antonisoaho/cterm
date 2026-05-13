local wezterm = require('wezterm')
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local repo = wezterm.config_dir
  local cwd = os.getenv('CTERM_CWD') or repo
  local agent = os.getenv('CTERM_AGENT') or 'claude'
  local is_windows = wezterm.target_triple:find('windows') ~= nil
  local agent_args = is_windows and { 'cmd', '/c', agent } or { agent }
  if agent == 'claude' then
    local repo_fwd = repo:gsub('\\', '/')
    local settings_tmp = repo .. '/.claude/settings.tmp.json'
    local function json_str(s) return s:gsub('\\', '\\\\'):gsub('"', '\\"') end
    local sl_cmd = json_str('bash "' .. repo_fwd .. '/scripts/statusline.sh"')
    local hook_cmd = json_str('bash "' .. repo_fwd .. '/scripts/nvim-open.sh"')
    local json = string.format(
      '{"statusLine":{"type":"command","command":"%s","refreshInterval":5},' ..
      '"hooks":{"PostToolUse":[{"matcher":"Write|Edit|EnterPlanMode",' ..
      '"hooks":[{"type":"command","command":"%s"}]}]}}',
      sl_cmd, hook_cmd)
    local f = assert(io.open(settings_tmp, 'w'))
    f:write(json)
    f:close()
    table.insert(agent_args, '--settings')
    table.insert(agent_args, settings_tmp)
  end
  local add_dirs = {}
  local extras_file = os.getenv('CTERM_EXTRAS_FILE')
  if extras_file then
    local ef = io.open(extras_file, 'r')
    if ef then
      local prev = nil
      for line in ef:lines() do
        local trimmed = line:gsub('\r$', '')
        if trimmed ~= '' then
          table.insert(agent_args, trimmed)
          if prev == '--add-dir' or prev == '-d' then
            table.insert(add_dirs, trimmed)
          end
          prev = trimmed
        end
      end
      ef:close()
    end
  end
  local nvim_args = { 'nvim', '--listen', os.getenv('CTERM_NVIM_ADDR') or '127.0.0.1:6666' }
  for _, dir in ipairs(add_dirs) do
    local d = dir:gsub('\\', '/'):gsub("'", "''")
    table.insert(nvim_args, '-c')
    table.insert(nvim_args, "tabnew | exe 'tcd ' . fnameescape('" .. d .. "') | Neotree show")
  end
  if #add_dirs > 0 then
    table.insert(nvim_args, '-c')
    table.insert(nvim_args, 'tabfirst')
  end
  local _tab, left, window = mux.spawn_window {
    cwd = cwd,
    args = agent_args,
  }
  local _right = left:split {
    direction = 'Right',
    size = 0.55,
    cwd = cwd,
    args = nvim_args,
  }
  window:gui_window():maximize()
end)

return {
  color_scheme = 'Gruvbox Dark (Gogh)',
  colors = {
    background = '#1a1a1a',
  },
  font = wezterm.font_with_fallback({
    os.getenv('CTERM_FONT') or 'JetBrainsMono Nerd Font',
    'JetBrains Mono',
    'Consolas',
  }),
  font_size = tonumber(os.getenv('CTERM_FONT_SIZE')) or 11,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = { left = 4, right = 4, top = 2, bottom = 2 },
  keys = {
    { key = 'h', mods = 'ALT', action = wezterm.action.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'ALT', action = wezterm.action.ActivatePaneDirection('Right') },
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b\r') },
    { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom('Clipboard') },
    { key = 'Insert', mods = 'SHIFT', action = wezterm.action.PasteFrom('Clipboard') },
    { key = 'Insert', mods = 'CTRL', action = wezterm.action.CopyTo('Clipboard') },
  },
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.CompleteSelection('Clipboard'),
    },
    {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = wezterm.action.PasteFrom('Clipboard'),
    },
  },
}
