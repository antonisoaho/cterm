return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = (function()
      local t = {
        { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
        { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      }
      for i = 1, 9 do
        t[#t + 1] = { '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<cr>', desc = 'Buffer ' .. i }
      end
      return t
    end)(),
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
