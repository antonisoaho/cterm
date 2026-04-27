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
