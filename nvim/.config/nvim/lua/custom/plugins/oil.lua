return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup {
      default_file_explorer = false,
      columns = {
        'icon',
      },
      buf_options = {
        buflisted = false,
        bufhidden = 'hide',
      },
      delete_to_trash = true,
      confirm = {
        default = true,
      },
      prompt_save_on_select_new_entry = false,
      cleanup_delay_ms = 2000,
      lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = true,
      },
      constrain_cursor = 'editable',
      watch_for_changes = true,
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['<CR>'] = 'actions.select',
        ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = { 'actions.close', mode = 'n' },
        ['<C-l>'] = 'actions.refresh',
        ['H'] = { 'actions.parent', mode = 'n' },
        ['L'] = 'actions.select',
        ['-'] = { 'actions.parent', mode = 'n' },
        ['_'] = { 'actions.open_cwd', mode = 'n' },
        ['`'] = { 'actions.cd', mode = 'n' },
        ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
        ['gs'] = { 'actions.change_sort', mode = 'n' },
        ['gx'] = 'actions.open_external',
        ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
        ['<c-e>'] = 'actions.close',
        ['q'] = 'actions.close',
        ['<ESC>'] = 'actions.close',
      },
      use_default_keymaps = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      float = {
        padding = 2,
        max_width = 0.5,
        max_height = 0.5,
        border = 'rounded',
      },
      preview = {
        max_width = 0.5,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = 'rounded',
        win_options = {
          winblend = 0,
        },
        update_on_cursor_moved = true,
      },

      win_options = {
        wrap = true,
        signcolumn = 'no',
        cursorcolumn = false,
        foldcolumn = '0',
        spell = false,
        list = false,
        conceallevel = 2,
        concealcursor = 'nvic',
      },
    }

    vim.api.nvim_set_hl(0, 'NormalFloat', {
      bg = 'NONE'
    })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
      pattern = 'oil://*',
      callback = function()
        vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
      end,
    })

    vim.keymap.set('n', '<C-e>', function()
      require('oil').toggle_float()
    end, { desc = 'Toggle Oil float with cursor on current file' })
  end,
}
