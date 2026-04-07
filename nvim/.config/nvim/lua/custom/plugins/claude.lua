-- Custom function to toggle Claude Code without moving cursor focus
local function toggle_claude_no_focus()
  local current_win = vim.api.nvim_get_current_win()

  local success, err = pcall(vim.cmd, 'ClaudeCode')
  if not success then
    vim.notify('Error toggling Claude Code: ' .. (err or 'Unknown error'), vim.log.levels.ERROR)
    return
  end

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(current_win) then
      local current_focus = vim.api.nvim_get_current_win()
      if current_focus ~= current_win then
        vim.api.nvim_set_current_win(current_win)
      end
    end
  end, 50)
end

-- Custom function to add current buffer to Claude Code (handles spaces in paths)
local function add_current_buffer()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end
  local claudecode = require("claudecode")
  local success, err = pcall(claudecode.send_at_mention, bufname, nil, nil, "add_buffer")
  if success then
    vim.notify('Added buffer to Claude Code', vim.log.levels.INFO)
  else
    vim.notify('Error adding buffer: ' .. (err or 'Unknown error'), vim.log.levels.ERROR)
  end
end

-- Custom function to send all open buffers to Claude Code
local function send_all_buffers()
  local buffers = vim.api.nvim_list_bufs()
  local valid_buffers = {}

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname ~= '' and not bufname:match('^term://') then
        table.insert(valid_buffers, buf)
      end
    end
  end

  if #valid_buffers == 0 then
    vim.notify('No valid buffers to send to Claude Code', vim.log.levels.WARN)
    return
  end

  local claudecode = require("claudecode")
  for _, buf in ipairs(valid_buffers) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    local success, err = pcall(claudecode.send_at_mention, bufname, nil, nil, "send_all_buffers")
    if not success then
      vim.notify('Error adding buffer ' .. bufname .. ': ' .. (err or 'Unknown error'), vim.log.levels.ERROR)
    end
  end

  vim.notify('Added ' .. #valid_buffers .. ' buffer(s) to Claude Code', vim.log.levels.INFO)
end

-- Custom function to launch Claude Code with normal Anthropic configuration
local function launch_claude_normal()
  -- Clear all provider environment variables to ensure normal operation
  vim.fn.setenv('ANTHROPIC_BASE_URL', '')
  vim.fn.setenv('ANTHROPIC_AUTH_TOKEN', '')
  vim.fn.setenv('API_TIMEOUT_MS', '')
  vim.fn.setenv('ANTHROPIC_MODEL', '')
  vim.fn.setenv('ANTHROPIC_SMALL_FAST_MODEL', '')
  vim.fn.setenv('ANTHROPIC_DEFAULT_SONNET_MODEL', '')
  vim.fn.setenv('ANTHROPIC_DEFAULT_OPUS_MODEL', '')
  vim.fn.setenv('ANTHROPIC_DEFAULT_HAIKU_MODEL', '')
  vim.fn.setenv('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC', '')

  local success, err = pcall(vim.cmd, 'ClaudeCode')
  if not success then
    vim.notify('Error launching Claude Code (normal): ' .. (err or 'Unknown error'), vim.log.levels.ERROR)
    return
  end
end

return {
  'coder/claudecode.nvim',
  lazy = false,
  priority = 1000,
  dependencies = {
    'folke/snacks.nvim',
  },
  opts = {
    -- Use Linux path for claude binary
    terminal_cmd = '/usr/bin/claude --dangerously-skip-permissions',

    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = 'warn',

    terminal = {
      split_side = 'right',
      provider = 'snacks',
      auto_close = true,
      split_width_percentage = 0.35,
      cwd_provider = function(ctx)
        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(ctx.file_dir) .. ' rev-parse --show-toplevel')[1]
        if vim.v.shell_error == 0 and git_root then
          return git_root
        end
        return ctx.file_dir
      end,
    },

    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
      keep_terminal_focus = true,
    },
  },
  config = function(_, opts)
    require('claudecode').setup(opts)

    vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
      callback = function()
        if vim.fn.mode() ~= 'c' then
          vim.cmd('checktime')
        end
      end,
      desc = 'Auto-reload buffers when changed externally by Claude Code',
    })

    vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
      pattern = { 'term://*claude*', '*ClaudeCode*' },
      callback = function()
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_width(win, 60)
        vim.wo.winfixwidth = true
        vim.wo.winfixheight = true

        if vim.fn.exists(':NoiceDismiss') == 2 then
          vim.cmd('NoiceDismiss')
        elseif vim.fn.exists(':lua') == 2 and pcall(require, 'notify') then
          vim.schedule(function()
            vim.cmd('echo ""')
          end)
        end
      end,
      desc = 'Fix Claude Code terminal window size at 60 columns',
    })

    vim.opt.autoread = true
  end,
  keys = {
    -- Core Claude Code commands
    { "<M-;>", launch_claude_normal, desc = "Toggle Claude (normal)" },
    { "<M-;>", toggle_claude_no_focus, desc = "Toggle Claude (close)", mode = "t" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },

    -- Session management
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },

    -- File/content management
    { "<leader>cb", add_current_buffer, desc = "Add current buffer" },
    { "<leader>cB", send_all_buffers, desc = "Add all buffers to Claude" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>cS", "<cmd>.ClaudeCodeSend<cr>", mode = "n", desc = "Send current line to Claude" },

    -- Tree/file explorer integration
    {
      "<leader>ca",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file from tree",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },

    -- Quick actions
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
    { "<leader>c?", "<cmd>help claudecode<cr>", desc = "Claude Code help" },
    { "<leader>cq", "<cmd>ClaudeCode --quit<cr>", desc = "Quit Claude Code" },

    -- Claude Code with normal config
    { "<leader>ccc", launch_claude_normal, desc = "Claude Code (original)" },
  },
}
