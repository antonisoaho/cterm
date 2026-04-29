-- Rotates the wezterm window/tab title through silly action names.
local names = {
  'Wrangling', 'Yanking', 'Tweaking', 'Sculpting', 'Refactoring',
  'Doodling', 'Vimming', 'Pondering', 'Tinkering', 'Munging',
  'Hacking', 'Polishing', 'Crafting', 'Bikeshedding', 'Scribbling',
  'Wibbling', 'Scadoodling', 'Plonking', 'Fiddling', 'Noodling',
  'Squinting', 'Bamboozling', 'Wrenching', 'Hoisting', 'Gallivanting',
  'Rummaging', 'Gnashing', 'Bumbling', 'Whittling', 'Scheming',
}

math.randomseed(os.time() + vim.fn.getpid())

local function pick()
  return names[math.random(#names)] .. '...'
end

vim.opt.title = true
vim.opt.titlestring = pick()

local timer = vim.uv.new_timer()
timer:start(6000, 6000, vim.schedule_wrap(function()
  vim.opt.titlestring = pick()
end))
