local wezterm = require('wezterm')
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local repo = wezterm.config_dir
  local cwd = os.getenv('CTERM_CWD') or repo
  local _tab, left, window = mux.spawn_window {
    cwd = cwd,
    args = { 'claude' },
  }
  local _right = left:split {
    direction = 'Right',
    size = 0.55,
    cwd = cwd,
    args = { 'nvim', '--listen', '127.0.0.1:6666' },
  }
  window:gui_window():maximize()
end)

return {
  color_scheme = 'Gruvbox Dark (Gogh)',
  colors = {
    background = '#1a1a1a',
  },
  font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'JetBrains Mono',
    'Consolas',
  }),
  font_size = 11,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = { left = 4, right = 4, top = 2, bottom = 2 },
  keys = {
    { key = 'h', mods = 'ALT', action = wezterm.action.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'ALT', action = wezterm.action.ActivatePaneDirection('Right') },
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b\r') },
  },
}
