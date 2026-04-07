return {
  {
    'vhyrro/luarocks.nvim',
    priority = 1001,
    opts = {
      rocks = { 'magick' },
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    keys = {
      { '<leader>pi', '<cmd>PasteImage<CR>', desc = 'Paste Image' },
    },
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = '[Image]($FILE_PATH)',
          use_absolute_path = true,
        },
      },
    },
  },
}
