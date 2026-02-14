-- Omarchy theme hot-reload integration
-- Reads the colorscheme from ~/.config/omarchy/current/theme/neovim.lua
-- and applies it on startup and when themes change (via LazyReload)
return {
  {
    name = "omarchy-theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 999,
    config = function()
      local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

      -- Parse the omarchy theme file to extract the colorscheme name
      local function get_omarchy_colorscheme()
        if vim.fn.filereadable(theme_file) ~= 1 then
          return nil
        end
        -- The file returns a table; find the LazyVim spec with opts.colorscheme
        local ok, specs = pcall(dofile, theme_file)
        if not ok or type(specs) ~= "table" then
          return nil
        end
        for _, spec in ipairs(specs) do
          if type(spec) == "table" and spec.opts and spec.opts.colorscheme then
            return spec.opts.colorscheme
          end
        end
        return nil
      end

      -- Apply the omarchy colorscheme
      local function apply_omarchy_theme()
        local colorscheme = get_omarchy_colorscheme()
        if colorscheme then
          -- Load the colorscheme plugin via lazy
          pcall(function()
            require("lazy.core.loader").colorscheme(colorscheme)
          end)
          vim.schedule(function()
            pcall(vim.cmd.colorscheme, colorscheme)
          end)
        end
      end

      -- Apply on startup
      apply_omarchy_theme()

      -- Re-apply when lazy reloads (triggered by omarchy-theme-set)
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          vim.schedule(apply_omarchy_theme)
        end,
      })
    end,
  },
}
