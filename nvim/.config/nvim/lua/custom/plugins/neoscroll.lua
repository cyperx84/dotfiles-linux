return {
  'karb94/neoscroll.nvim',
  event = 'VeryLazy',
  config = function()
    require('neoscroll').setup {
      mappings = {},
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = true,
      cursor_scrolls_alone = true,
      easing_function = 'sine',
      pre_hook = nil,
      post_hook = function(info)
        if info == 'up' or info == 'down' then
          local at_top = vim.fn.line 'w0' == 1
          local at_bottom = vim.fn.line 'w$' >= vim.fn.line '$'
          if not at_top and not at_bottom then
            vim.cmd 'normal! zz'
          end
        end
      end,
    }

    local neoscroll = require 'neoscroll'

    local keymap = {
      ['<C-u>'] = function()
        neoscroll.ctrl_u { duration = 100, info = 'up' }
      end,
      ['<C-d>'] = function()
        neoscroll.ctrl_d { duration = 100, info = 'down' }
      end,
      ['<C-b>'] = function()
        neoscroll.ctrl_b { duration = 250, info = 'up' }
      end,
      ['<C-f>'] = function()
        neoscroll.ctrl_f { duration = 250, info = 'down' }
      end,
    }

    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
