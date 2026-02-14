return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      -- Colorscheme is set by omarchy-theme-hotreload.lua
      -- Fallback if omarchy theme is not available
      if vim.fn.filereadable(vim.fn.expand('~/.config/omarchy/current/theme/neovim.lua')) ~= 1 then
        vim.cmd.colorscheme 'tokyonight'
      end

      -- Color palette
      local colors = {
        border = '#0000ff',
        none = 'NONE',
      }

      -- Highlight groups that use border color
      local border_groups = {
        'WinSeparator',
        'FloatBorder',
        'TelescopeBorder',
        'TelescopePromptBorder',
        'TelescopeResultsBorder',
        'TelescopePreviewBorder',
      }

      local function set_custom_highlights()
        for _, group in ipairs(border_groups) do
          vim.api.nvim_set_hl(0, group, { fg = colors.border, bg = colors.none })
        end
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = colors.none })
      end

      set_custom_highlights()

      -- Persist highlights after colorscheme changes
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = set_custom_highlights,
      })

      -- Re-apply after window/buffer changes
      vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'CmdlineLeave' }, {
        callback = set_custom_highlights,
      })
    end,
  },
  {
    'loctvl842/monokai-pro.nvim',
  },
}
