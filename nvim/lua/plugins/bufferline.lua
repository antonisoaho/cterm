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
