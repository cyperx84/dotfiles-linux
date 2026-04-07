return {
  'benomahony/uv.nvim',
  config = function()
    require('uv').setup({
      auto_activate_venv = true,
      auto_commands = true,
      picker_integration = true,
      keymaps = {
        prefix = "<leader>u",
        commands = true,
        run_file = true,
        run_selection = true,
        run_function = true,
        venv = true,
        init = true,
        add = true,
        remove = true,
        sync = true,
        sync_all = true,
      },
      execution = {
        run_command = "uv run python",
        notify_output = true,
        notification_timeout = 10000,
      },
    })
  end,
}
