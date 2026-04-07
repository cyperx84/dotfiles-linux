return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        ensure_installed = {
          -- Core languages
          'c',
          'cpp',
          'lua',
          'vim',
          'vimdoc',
          'query',

          -- Web development
          'javascript',
          'typescript',
          'tsx',
          'html',
          'css',
          'scss',
          'astro',
          'vue',
          'svelte',

          -- Backend & Systems
          'python',
          'rust',
          'go',
          'java',
          'kotlin',
          'ruby',
          'php',
          'elixir',
          'erlang',
          'zig',
          'c_sharp',

          -- Shell & DevOps
          'bash',
          'fish',
          'dockerfile',
          'terraform',

          -- Data & Config
          'json',
          'jsonc',
          'yaml',
          'toml',
          'xml',
          'sql',
          'graphql',
          'jq',

          -- Markup & Documentation
          'markdown',
          'markdown_inline',
          'latex',
          'regex',

          -- Other useful
          'git_config',
          'git_rebase',
          'gitcommit',
          'gitignore',
          'diff',
        },
        auto_install = true,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
